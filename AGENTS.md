# Repository Guidelines

Read [agents.org](agents.org) for detailed project guidance. Consult the relevant
guide under `skills/` for NixOS, Emacs, or Hyprland work; use the current
configuration and `Makefile` when older documentation differs.

## Project Structure & Module Organization

This flake manages `desktop`, `laptop`, `vps`, and `vm` hosts. `flake.nix`
connects their NixOS and Home Manager modules; `flake.lock` pins dependencies.

- `hosts/<hostname>/`: system configuration, hardware settings, and user packages.
- `config/`: shared user configuration and desktop assets; Emacs uses literate
  configuration in `config/emacs/emacs.org`.
- `system/` and `modules/`: system packages, services, and reusable hardware modules.
- `packages/` and `scripts/`: custom derivations and packaged helper scripts.
- `samples/`: example configurations, including a Python development shell.

Connect new modules through the appropriate imports.

## Build, Test, and Development Commands

Run commands from the repository root. For non-activating validation:

```sh
nix eval --no-update-lock-file .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix build --no-update-lock-file --no-link .#nixosConfigurations.desktop.config.system.build.toplevel
```

Replace `desktop` with the affected host. `make` only shows help.
`make eval HOST=desktop` and `make build HOST=desktop` validate without activation
or lock updates. `make test` temporarily activates; `make install` permanently
switches (both accept `HOST`). `make update` only updates inputs;
`make update-secrets` updates only `mysecrets`. Cleanup targets do not activate.

## Coding Style & Naming Conventions

Use two-space Nix indentation and follow nearby module conventions. Use descriptive
filenames such as `modules/nvidia-drivers.nix`. Alejandra and Statix are available
for formatting and linting; limit changes to relevant files. Declare desktop Python
libraries through `python3.withPackages` in `hosts/desktop/home.nix`.

## Testing Guidelines

There is no central unit-test suite or coverage threshold. Evaluate and build
affected hosts; shared modules may require multiple host builds. Report commands
run and distinguish build success from activation and runtime validation. Activate
or deploy only within the task's authorization.

## Commit & Pull Request Guidelines

History contains short descriptive commits; `agents.org` recommends Conventional
Commits such as `fix: correct desktop scaling`. Keep commits focused. PRs should
describe affected hosts, behavior changes, validation, and activation requirements;
link relevant issues and include screenshots for visible desktop changes.

## Security & Configuration Tips

Preserve existing uncommitted changes. Keep secrets in agenix/private `mysecrets`,
never plaintext or API keys. Avoid unrelated lock updates and do not change
`system.stateVersion` or `home.stateVersion` during routine upgrades.
