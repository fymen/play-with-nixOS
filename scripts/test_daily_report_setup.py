"""Offline checks for Hermes registration, migration and operator pause preservation."""

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("daily_report_setup", Path(__file__).with_name("daily-report-setup.py"))
assert SPEC is not None and SPEC.loader is not None
setup = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(setup)


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / ".hermes"
        (self.home / "cron").mkdir(parents=True)
        self.registry = self.home / "cron/jobs.json"
        self.jobs = []
        self.save()
        self.source = self.root / "source.sh"
        self.source.write_text("#!/bin/sh\nexit 0\n")

    def save(self):
        self.registry.write_text(json.dumps({"jobs": self.jobs}))

    def fake_cli(self, command, **kwargs):
        action = command[2]
        flags = command[4:] if action in {"edit", "create"} else []
        def flag(name, default=None):
            return flags[flags.index(name) + 1] if name in flags else default
        if action == "create":
            job = {"id": f"job-{len(self.jobs)}", "enabled": False}
            self.jobs.append(job)
        else:
            job = next(x for x in self.jobs if x["id"] == command[3])
        if action in {"create", "edit"}:
            job.update({
                "name": flag("--name"), "script": flag("--script"),
                "schedule": {"expr": command[3] if action == "create" else flag("--schedule")},
                "no_agent": True, "timezone": flag("--timezone"), "catch_up": True,
                "grace_minutes": int(flag("--grace-minutes") or "0"), "deliver": "local",
                "failure_deliver": "local", "wrap_response": False, "prompt": "",
                "skills": [], "context_from": [], "model": None, "monitor_script": None,
                "monitor_url": None, "workdir": flag("--workdir"),
            })
        elif action in {"pause", "resume"}:
            job["enabled"] = action == "resume"
        else:
            raise AssertionError(f"unexpected CLI action {action}")
        self.save()
        return SimpleNamespace(returncode=0)

    def configure(self, activate=False):
        return setup.configure(self.home, "hermes", self.source, self.source, activate)

    def test_new_jobs_are_paused_and_registration_idempotent(self):
        with patch.object(setup.subprocess, "run", side_effect=self.fake_cli) as cli:
            ids = self.configure()
            calls = cli.call_count
            again = self.configure()
        self.assertEqual(ids, again)
        self.assertEqual(cli.call_count, calls)
        self.assertEqual(len(self.jobs), 2)
        self.assertTrue(all(not job["enabled"] for job in self.jobs))
        self.assertTrue((self.home / "cron/daily-report.before-migration.json").exists())

    def test_activation_and_later_rebuild_preserve_user_pause(self):
        with patch.object(setup.subprocess, "run", side_effect=self.fake_cli):
            self.configure(activate=True)
            self.assertTrue(all(job["enabled"] for job in self.jobs))
            self.jobs[1]["enabled"] = False
            self.save()
            self.configure()
        self.assertFalse(self.jobs[1]["enabled"])

    def test_legacy_job_reused_not_duplicated(self):
        self.jobs = [{"id": "legacy", "name": setup.LEGACY_NAME, "enabled": True}]
        self.save()
        with patch.object(setup.subprocess, "run", side_effect=self.fake_cli):
            ids = self.configure()
        self.assertEqual(ids[setup.JOBS[1][0]], "legacy")
        self.assertEqual(len(self.jobs), 2)
        self.assertFalse(self.jobs[0]["enabled"])
        self.assertTrue(self.jobs[0]["no_agent"])

    def test_ambiguous_legacy_and_new_name_rejected_before_changes(self):
        self.jobs = [{"id": "old", "name": setup.LEGACY_NAME}, {"id": "new", "name": setup.JOBS[1][0]}]
        self.save()
        with patch.object(setup.subprocess, "run") as cli, self.assertRaises(RuntimeError):
            self.configure()
        cli.assert_not_called()
        self.assertFalse((self.home / "scripts").exists())

    def test_script_is_physical_and_replaces_symlink_without_touching_source(self):
        destination = self.home / "scripts/test.sh"
        destination.parent.mkdir()
        external = self.root / "old.sh"
        external.write_text("old source")
        destination.symlink_to(external)
        setup.install_script(self.source, destination)
        self.assertFalse(destination.is_symlink())
        self.assertEqual(destination.read_text(), self.source.read_text())
        self.assertEqual(external.read_text(), "old source")
        self.assertEqual(destination.stat().st_mode & 0o777, 0o700)


if __name__ == "__main__":
    unittest.main()
