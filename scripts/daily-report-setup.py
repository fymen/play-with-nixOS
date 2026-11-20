#!/usr/bin/env python3
"""Install physical Hermes cron scripts and idempotently register the two jobs."""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

JOBS = (
    ("技术早报·采集", "50 8 * * *", "daily-report-collect.sh"),
    ("技术早报·微信投递", "0 9 * * *", "daily-report-send.sh"),
)
LEGACY_NAME = "每日新闻报告"


def read_jobs(home):
    path = home / "cron/jobs.json"
    if not path.exists():
        return []
    try:
        value = json.loads(path.read_text())
    except (ValueError, OSError) as exc:
        raise RuntimeError("cannot read Hermes cron registry; no jobs changed") from exc
    if not isinstance(value, dict) or not isinstance(value.get("jobs"), list):
        raise RuntimeError("unsupported Hermes cron registry; no jobs changed")
    return value["jobs"]


def find_job(jobs, name, legacy=False):
    names = {name, LEGACY_NAME} if legacy else {name}
    matches = [job for job in jobs if job.get("name") in names]
    if len(matches) > 1:
        raise RuntimeError(f"ambiguous existing jobs for {name}; resolve duplicates first")
    return matches[0] if matches else None


def matches_definition(job, name, schedule, script, workdir):
    return (
        job.get("name") == name
        and job.get("schedule", {}).get("expr") == schedule
        and job.get("script") == script
        and job.get("no_agent") is True
        and job.get("timezone") == "Asia/Shanghai"
        and job.get("catch_up") is True
        and job.get("grace_minutes") == 1440
        and job.get("deliver") in ("local", ["local"])
        and job.get("failure_deliver") in ("local", ["local"])
        and job.get("wrap_response") is False
        and not job.get("prompt")
        and not job.get("skills")
        and not job.get("context_from")
        and not job.get("model")
        and not job.get("monitor_script")
        and not job.get("monitor_url")
        and job.get("workdir") == str(workdir)
    )


def install_script(source, destination):
    destination.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if destination.exists() and destination.read_bytes() == source.read_bytes():
        return
    backup = destination.with_suffix(".sh.before-migration")
    if destination.exists() and not backup.exists():
        shutil.copyfile(destination, backup)
    temp = destination.with_suffix(".tmp")
    # Replace any existing symlink rather than following it into the Nix store.
    temp.unlink(missing_ok=True)
    shutil.copyfile(source, temp)
    temp.chmod(0o700)
    temp.replace(destination)


def configure(home, hermes, collect_script, send_script, activate=False):
    os.umask(0o077)
    jobs = read_jobs(home)
    # Preflight all names before modifying anything.
    existing = [find_job(jobs, name, legacy=(index == 1)) for index, (name, _, _) in enumerate(JOBS)]
    old_registry = home / "cron/jobs.json"
    backup = home / "cron/daily-report.before-migration.json"
    if old_registry.exists() and not backup.exists():
        shutil.copyfile(old_registry, backup)
    for source, (_, _, script) in zip((collect_script, send_script), JOBS, strict=True):
        install_script(source, home / "scripts" / script)

    env = dict(os.environ, HERMES_HOME=str(home))
    def cli(*arguments):
        result = subprocess.run([hermes, "cron", *arguments], env=env,
                                capture_output=True, text=True, timeout=90)
        if result.returncode:
            raise RuntimeError(f"Hermes cron {arguments[0]} failed; inspect hermes cron status")

    ids = {}
    for (name, schedule, script), job in zip(JOBS, existing, strict=True):
        common = ["--name", name, "--script", script, "--no-agent", "--deliver", "local",
                  "--failure-deliver", "local", "--no-wrap-response", "--timezone", "Asia/Shanghai",
                  "--catch-up", "on", "--grace-minutes", "1440", "--workdir", str(home.parent)]
        if job is None:
            cli("create", schedule, "--paused", *common)
            job = find_job(read_jobs(home), name)
            if job is None:
                raise RuntimeError(f"created job not found: {name}")
        elif not matches_definition(job, name, schedule, script, home.parent):
            # Disable the old agent-based job while changing its definition. Preserve an
            # explicit user pause on ordinary rebuilds; --activate resumes after migration.
            was_enabled = job.get("enabled", False)
            cli("pause", job["id"])
            cli("edit", job["id"], "--schedule", schedule, "--prompt", "", "--unpin",
                "--clear-skills", "--no-continuity", "--monitor-script", "", "--monitor-url", "", *common)
            if was_enabled and job.get("name") != LEGACY_NAME:
                cli("resume", job["id"])
        if activate:
            cli("resume", job["id"])
        ids[name] = job["id"]
    return ids


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", type=Path, required=True)
    parser.add_argument("--hermes", required=True)
    parser.add_argument("--collect-script", type=Path, required=True)
    parser.add_argument("--send-script", type=Path, required=True)
    parser.add_argument("--activate", action="store_true", help="explicitly resume both jobs")
    args = parser.parse_args()
    ids = configure(args.home, args.hermes, args.collect_script, args.send_script, args.activate)
    for name, job_id in ids.items():
        print(f"{name}: {job_id}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"daily-report setup failed: {exc}", file=sys.stderr)
        sys.exit(1)
