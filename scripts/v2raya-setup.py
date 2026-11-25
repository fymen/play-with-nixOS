#!/usr/bin/env python3
"""Prepare existing v2rayA 2.5.16 SQLite state, offline and without exposing nodes.

Default: read-only preview. --apply requires root and a stopped v2rayA service.
This script does not start services, import subscriptions, or select nodes.
"""
import argparse
import datetime
import json
import os
import sqlite3
import subprocess
from pathlib import Path


def prepare(connection):
    def get(key, default):
        row = connection.execute(
            "SELECT value FROM system_config WHERE key = ?", (key,)
        ).fetchone()
        if row is None:
            return default
        try:
            return json.loads(row[0])
        except (json.JSONDecodeError, TypeError) as error:
            raise ValueError(f"Invalid JSON for {key}; state was not changed") from error

    setting = get("system:setting", {})
    setting.update(
        transparent="close", pacMode="whitelist", portSharing=False,
        dnsHijack="no",
    )
    # Deliberately leave the core stopped until the operator reviews the UI.
    return {
        "system:setting": setting,
        "system:running": False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--state-dir", type=Path, default=Path("/etc/v2raya"))
    args = parser.parse_args()
    database = args.state_dir / "v2raya.db"
    if not database.is_file():
        parser.error("Existing v2rayA SQLite database required; initialize the UI first.")
    if args.apply:
        if os.geteuid() != 0:
            parser.error("--apply requires root")
        state = subprocess.run(
            ["systemctl", "show", "v2raya.service", "--property=ActiveState", "--value"],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
        if state not in ("inactive", "failed"):
            parser.error("Stop v2raya.service before --apply")
    with sqlite3.connect(database.resolve().as_uri() + "?mode=ro", uri=True) as source:
        changes = prepare(source)
        if args.apply:
            os.umask(0o077)
            backups = Path("/var/backups/v2raya")
            backups.mkdir(mode=0o700, parents=True, exist_ok=True)
            stamp = datetime.datetime.now(datetime.UTC).strftime("%Y%m%dT%H%M%S%fZ")
            backup = backups / (stamp + ".db")
            with sqlite3.connect(backup) as target:
                source.backup(target)
            with sqlite3.connect(database) as target:
                for key, value in changes.items():
                    target.execute(
                        "INSERT INTO system_config(key,value) VALUES(?,?) "
                        "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
                        (key, json.dumps(value)),
                    )
            print("Applied offline settings; private database backup:", backup)
        else:
            print("Preview only: no state changes.")
    print("HTTP/SOCKS forwarding only; local-only proxy ports; rule HTTP port uses whitelist routing.")
    print("Transparent proxy and DNS interception disabled; core left stopped.")
    print("Existing nodes, subscriptions, accounts and selections preserved.")


if __name__ == "__main__":
    main()
