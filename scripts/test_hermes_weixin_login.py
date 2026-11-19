"""Offline tests; never import Hermes or request a real QR login."""

import contextlib
import importlib.util
import io
import os
import stat
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "weixin_login", Path(__file__).with_name("hermes-weixin-login.py")
)
assert SPEC is not None and SPEC.loader is not None
login = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(login)


class LoginTests(unittest.TestCase):
    def setUp(self):
        self.credentials = {
            "account_id": "test@im.bot",
            "token": "secret-test-token",
            "base_url": "https://ilinkai.weixin.qq.com",
        }

    def test_private_export_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "private/login.env"
            login.write_credentials(output, self.credentials)
            self.assertEqual(stat.S_IMODE(output.stat().st_mode), 0o600)
            self.assertEqual(stat.S_IMODE(output.parent.stat().st_mode), 0o700)
            self.assertIn("WEIXIN_TOKEN=secret-test-token\n", output.read_text())
            before = output.read_bytes()
            with self.assertRaises(FileExistsError):
                login.write_credentials(output, self.credentials)
            self.assertEqual(output.read_bytes(), before)
            self.assertEqual(list(output.parent.iterdir()), [output])

    def test_dangling_symlink_is_not_followed(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "login.env"
            target = Path(directory) / "missing"
            output.symlink_to(target)
            with self.assertRaises(FileExistsError):
                login.write_credentials(output, self.credentials)
            self.assertFalse(target.exists())

    def test_unsafe_values_rejected_without_writes(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "login.env"
            for value in ["", "bad\nKEY=value", "$EXPAND", "quote'", "bad\x00"]:
                with self.subTest(value=value), self.assertRaises(ValueError):
                    login.write_credentials(output, {**self.credentials, "token": value})
            with self.assertRaises(ValueError):
                login.write_credentials(output, {**self.credentials, "base_url": "http://example.com"})
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_check_has_no_login_or_file_writes(self):
        def forbidden_login(_home):
            self.fail("--check must never start QR login")

        adapter = types.SimpleNamespace(
            qr_login=forbidden_login, check_weixin_requirements=lambda: True
        )
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory) / "not-created"
            with (
                patch.dict(os.environ),
                patch.object(login.os, "umask", return_value=0o077),
                patch.object(login.sys, "argv", ["login", "--check", "--home", str(home)]),
                patch.object(login.importlib, "import_module", return_value=adapter),
                contextlib.redirect_stdout(io.StringIO()),
            ):
                self.assertEqual(login.main(), 0)
            self.assertFalse(home.exists())


if __name__ == "__main__":
    unittest.main()
