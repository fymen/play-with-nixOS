# OpenClaw on desktop

## Emacs

`config/emacs/emacs.org` installs upstream `agent-shell`, `acp`, and `shell-maker`
using `use-package :vc` with `:rev :newest`, like the existing `codex-ide` setup.
These packages are explicitly excluded from Nix's older package selection with
`:ensure nil`. Their first installation requires network access in Emacs.

After applying the Emacs configuration, run
`M-x agent-shell-openclaw-start-agent`. It starts `openclaw --profile plus acp`
and uses the existing Gateway and credentials. Update these checkouts with
`M-x package-vc-upgrade-all`; `:newest` selects the latest revision at installation,
not an automatic update on every startup.

`config/openclaw.nix` installs the core CLI/Gateway from the official
`openclaw/nix-openclaw` flake. The input revision and `flake.lock` pin the validated
2026.10.7 release. The larger bundle of optional desktop tools is not installed.

The wrapper selects the `plus` profile, enables the local HTTP proxy at
`127.0.0.1:10808`, and keeps loopback traffic outside the proxy. It permits the
existing interactive JSON configuration and persisted official runtime plugins;
the application package itself remains managed by Nix. Home Manager initializes
missing gateway and model settings (port 18789, loopback, token authentication,
and `openai/gpt-6.1-sol`) without overwriting later interactive choices. Actual
changes receive timestamped backups; unchanged configurations are not rewritten.
The service reads its port from the profile instead of forcing a command-line port.

OAuth credentials, the gateway token, runtime plugins, and SQLite databases live
under `~/.openclaw-plus`; none belong in Git or the Nix store. Existing tokens
are preserved. A fresh installation requires authentication separately.

## Apply and transition from the manual installation

From this repository:

```sh
sudo nixos-rebuild switch --flake .#desktop
```

Home Manager takes over `openclaw-gateway.service` and archives the manual
`upgrade.conf` override. Existing unmanaged unit files may be backed up with the
configured `.hm_backup` suffix. Close foreground Gateway processes before applying.
Once the rebuild succeeds, remove the earlier user-profile installation so it
cannot shadow the managed wrapper:

```sh
nix profile remove openclaw-gateway
exec zsh -l
systemctl --user restart openclaw-gateway.service
openclaw --version
openclaw gateway health
```

The wrapper supplies `--profile plus` automatically. Check the model with
`openclaw models status`; open the UI using `openclaw dashboard`.

## First login on a fresh machine

```sh
openclaw models auth login --provider openai --device-code --set-default
openclaw models set openai/gpt-6.1-sol
openclaw doctor --generate-gateway-token --non-interactive
systemctl --user restart openclaw-gateway.service
```

The login wizard can recommend a retired model; the declarative default and
allowlist use the model verified with this account. Fresh machines must install
any missing official Codex runtime plugin matching the pinned application release
using `openclaw doctor --fix` before chatting. Back up the profile before upgrades;
database migrations can prevent older releases from reopening it.

The desktop NixOS configuration also prioritizes working DNS servers and places
Nix build workspaces under `/home/nix-build`. The proxy must already be running.
