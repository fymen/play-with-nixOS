"""Offline regression tests; no model calls or messages are sent."""

import importlib.util
import json
import tempfile
import unittest
from datetime import UTC, datetime, timedelta
from pathlib import Path
from unittest.mock import patch

from defusedxml.common import EntitiesForbidden

SPEC = importlib.util.spec_from_file_location("daily_report", Path(__file__).with_name("daily-report.py"))
assert SPEC is not None and SPEC.loader is not None
report = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(report)


class DailyReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.state = Path(self.temp.name)
        self.now = datetime.now(UTC)
        self.item = {
            "id": "known", "category": "NixOS", "source": "test", "title": "A release",
            "url": "https://example.org/release", "published": self.now.isoformat(), "excerpt": "Fixes",
        }

    def test_rss_dates_and_content(self):
        body = b'''<rss><channel><item><title>A &amp; B</title><link>https://example.org/a</link>
        <pubDate>Fri, 20 Nov 2026 00:00:00 GMT</pubDate><description>&lt;b&gt;Fix&lt;/b&gt;</description>
        </item></channel></rss>'''
        now = datetime(2026, 11, 20, 1, tzinfo=UTC)
        items = report.parse_feed(body, "NixOS", "test", now - timedelta(days=1), now)
        self.assertEqual(items[0]["title"], "A & B")
        self.assertEqual(items[0]["excerpt"], "Fix")

    def test_atom_future_undated_and_unsafe_links_excluded(self):
        body = b'''<feed xmlns="http://www.w3.org/2005/Atom">
        <entry><title>OK</title><link href="https://example.org/a"/><updated>2026-11-20T00:00:00Z</updated></entry>
        <entry><title>Future</title><link href="https://example.org/b"/><updated>2027-01-01T00:00:00Z</updated></entry>
        <entry><title>Undated</title><link href="https://example.org/c"/></entry>
        <entry><title>Unsafe</title><link href="file:///etc/passwd"/><updated>2026-11-20T00:00:00Z</updated></entry>
        </feed>'''
        now = datetime(2026, 11, 20, 1, tzinfo=UTC)
        self.assertEqual(len(report.parse_feed(body, "Hermes", "test", now - timedelta(days=1), now)), 1)

    def test_xml_entities_rejected(self):
        with self.assertRaises(EntitiesForbidden):
            report.parse_feed(b'<!DOCTYPE x [<!ENTITY a "unsafe">]><rss>&a;</rss>', "NixOS", "test", self.now, self.now)

    def test_file_url_rejected(self):
        with self.assertRaises(ValueError):
            report.request("file:///etc/passwd")

    def test_unknown_model_ids_rejected(self):
        response = {"choices": [{"message": {"content": json.dumps([
            {"id": "invented", "summary": "fake", "impact": "fake"}])}}]}
        with (
            patch.object(report, "request", return_value=json.dumps(response).encode()),
            self.assertRaises(ValueError),
        ):
            report.model_digest([self.item], {"url": "http://localhost/v1", "model": "test"})

    def test_reports_separate_from_runtime_state(self):
        output = self.state / "workspace/reports"
        with (
            patch.object(report, "request", return_value=b"<rss><channel/></rss>"),
            patch.object(report, "parse_feed", return_value=[self.item]),
            patch.object(report, "model_digest", return_value={"known": {"summary": "更新", "impact": "关注"}}),
        ):
            report.collect(self.state, {}, output)
        day = datetime.now(report.BEIJING).strftime("%Y-%m-%d")
        for extension in ("md", "org", "json"):
            self.assertTrue((output / f"{day}.{extension}").exists())
            self.assertFalse((self.state / f"{day}.{extension}").exists())
        self.assertTrue((self.state / "latest.json").exists())
        self.assertTrue((self.state / "collection.json").exists())

    def test_balanced_selection(self):
        items = [dict(self.item, id=str(i), category=cat) for cat in report.CATEGORIES for i in range(5)]
        selected = report.select_balanced(items)
        self.assertEqual(len(selected), 10)
        for cat in report.CATEGORIES:
            self.assertEqual(sum(x["category"] == cat for x in selected), 2)

    def test_failure_is_not_reported_as_no_updates(self):
        text = report.render([], {}, ["OpenAI"], self.now, self.now, False)
        self.assertIn("抓取失败：OpenAI", text)
        self.assertIn("不代表全网没有更新", text)

    def test_all_sources_failed_leaves_no_report(self):
        with (
            patch.object(report, "request", side_effect=RuntimeError("offline")),
            self.assertRaises(RuntimeError),
        ):
            report.collect(self.state, {})
        self.assertFalse((self.state / "latest.json").exists())

    def prepare_delivery(self):
        today = datetime.now(report.BEIJING).strftime("%Y-%m-%d")
        report.atomic_json(self.state / "latest.json", {"day": today, "text": "test MEDIA:/private/file"})
        target = self.state / "target"
        target.write_text("weixin:test-contact")
        return target

    def test_send_idempotency_and_media_injection_blocked(self):
        target = self.prepare_delivery()
        with patch.object(report.subprocess, "run") as run:
            run.return_value.returncode = 0
            report.deliver(self.state, target, "hermes", {})
            report.deliver(self.state, target, "hermes", {})
        self.assertEqual(run.call_count, 1)
        self.assertNotIn("MEDIA:", run.call_args.kwargs["input"])
        self.assertTrue((self.state / "sent.json").exists())

    def test_failed_send_does_not_mark_delivered(self):
        target = self.prepare_delivery()
        with patch.object(report.subprocess, "run") as run:
            run.return_value.returncode = 1
            with self.assertRaises(RuntimeError):
                report.deliver(self.state, target, "hermes", {})
        self.assertFalse((self.state / "sent.json").exists())

    def test_stale_report_collected_before_send(self):
        target = self.prepare_delivery()
        report.atomic_json(self.state / "latest.json", {"day": "2000-01-01", "text": "old"})
        def collect(*args):
            self.prepare_delivery()
        with (
            patch.object(report, "collect", side_effect=collect) as gather,
            patch.object(report.subprocess, "run") as run,
        ):
            run.return_value.returncode = 0
            report.deliver(self.state, target, "hermes", {})
        gather.assert_called_once()
        self.assertNotEqual(run.call_args.kwargs["input"], "old")


if __name__ == "__main__":
    unittest.main()
