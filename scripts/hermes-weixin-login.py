#!/usr/bin/env python3
"""One-shot iLink QR login using the Python environment of the pinned Hermes package.

Use the hermes-weixin-login Nix wrapper. Credentials stay outside the repository;
this helper never edits .env/config.yaml or starts/restarts the gateway.
"""

import argparse
import asyncio
import importlib
import os
import sys
import tempfile
from collections.abc import Callable, Coroutine
from pathlib import Path
from typing import Any, cast
from urllib.parse import urlparse


def write_credentials(path: Path, credentials: dict[str, str]) -> None:
    """Publish a complete 0600 env file atomically, refusing any existing target."""
    values = {
        "WEIXIN_ACCOUNT_ID": credentials["account_id"],
        "WEIXIN_TOKEN": credentials["token"],
        "WEIXIN_BASE_URL": credentials["base_url"],
    }
    # Avoid dotenv expansion/quoting ambiguity and injection into the export.
    for key, value in values.items():
        if not value or any(c.isspace() or c in "\"'\\$`#\x00" for c in value):
            raise ValueError(f"Unexpected characters or empty value in {key}; export refused")
    url = urlparse(values["WEIXIN_BASE_URL"])
    if url.scheme != "https" or not url.hostname or url.username or url.password:
        raise ValueError("Expected an HTTPS iLink base URL without embedded credentials")

    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".weixin-login-", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            os.fchmod(stream.fileno(), 0o600)
            for key, value in values.items():
                stream.write(f"{key}={value}\n")
            stream.flush()
            os.fsync(stream.fileno())
        # link() is atomic and fails even for an existing dangling symlink.
        os.link(temporary, path)
    finally:
        os.unlink(temporary)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--home", type=Path,
        default=Path(os.environ.get("HERMES_HOME", "~/.hermes")).expanduser(),
        help="Hermes data directory (default: HERMES_HOME or ~/.hermes)",
    )
    parser.add_argument(
        "--output", type=Path,
        help="new private env file (default: <home>/weixin/login.env); never overwritten",
    )
    parser.add_argument(
        "--check", action="store_true",
        help="check dependencies and the pinned QR API without network or file writes",
    )
    args = parser.parse_args()
    home = args.home.expanduser().resolve()
    output = (args.output.expanduser() if args.output else home / "weixin/login.env").absolute()
    os.environ["HERMES_HOME"] = str(home)
    os.umask(0o077)

    try:
        adapter = importlib.import_module("plugins.platforms.weixin.adapter")
        importlib.import_module("qrcode")
        if not adapter.check_weixin_requirements() or not callable(adapter.qr_login):
            raise RuntimeError("This Hermes environment lacks the Weixin QR login dependencies/API")
        if args.check:
            print("Weixin QR API and dependencies are available; no login attempted.")
            return 0
        if os.path.lexists(output):
            print("Output already exists; choose another --output (never overwritten).", file=sys.stderr)
            return 1
        if not sys.stdin.isatty() or not sys.stdout.isatty():
            print("Run QR login in an interactive terminal, not a pipe or log capture.", file=sys.stderr)
            return 1

        print("This requests a WeChat iLink QR login and saves private credentials locally.")
        print("It does not connect/restart the gateway or modify your managed .env.")
        if input("Continue? [y/N] ").strip().lower() not in {"y", "yes"}:
            print("Cancelled; no login attempted.")
            return 1
        qr_login = cast(
            Callable[[str], Coroutine[Any, Any, dict[str, str] | None]], adapter.qr_login
        )
        credentials = asyncio.run(qr_login(str(home)))
        if not credentials:
            print("QR login failed or expired; no env file exported.", file=sys.stderr)
            return 1
        write_credentials(output, credentials)
        print(f"Private env file saved (0600): {output}")
        print("Account cache also saved under <home>/weixin/accounts/.")
        print("Import the env file into agenix and declare services.hermes-agent.environmentFiles.")
        print("After activation/restart, message the iLink bot and approve its pairing request.")
        return 0
    except KeyboardInterrupt:
        print("\nCancelled.", file=sys.stderr)
        return 130
    except (ImportError, OSError, ValueError, RuntimeError) as exc:
        # Do not print exception text: upstream/network errors may include credentials.
        print(f"Login/export failed ({type(exc).__name__}). Check dependencies, output path and permissions.", file=sys.stderr)
        print("If scanning succeeded, the account cache remains under <home>/weixin/accounts/.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
