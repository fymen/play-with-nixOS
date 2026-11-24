SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

HOST ?= $(shell hostname)
DEPLOY_HOST ?= $(if $(filter oracle-vps,$(HOST)),root@130.162.149.210,root@$(HOST))
BUILD_HOST ?=
# nixos-rebuild treats --build-host localhost as SSH, not a local build.
BUILD_HOST_FLAGS = $(if $(filter-out localhost,$(strip $(BUILD_HOST))),--build-host '$(BUILD_HOST)')

help:
	@printf '%s\n' \
	  'Usage: make <target> [HOST=desktop|laptop|vps|oracle-vps|vm]' \
	  '  help / all       Show this help (default; no system changes)' \
	  '  eval             Evaluate HOST without building or changing the lock' \
	  '  build            Build HOST without activation or lock updates' \
	  '  debug            Build with tracing and nix-output-monitor' \
	  '  test             Temporarily activate HOST (sudo)' \
	  '  install          Switch to HOST permanently (sudo)' \
	  '  update           Update all inputs; do not build or activate' \
	  '  update-secrets   Update only the mysecrets input' \
	  '  archive          Archive the locked flake inputs' \
	  '  build-vm         Build the vm host VM without activation' \
	  '  list-generations Show system generation history' \
	  '  list-packages    Query available packages with nix-env' \
	  '  clean          Delete system history older than 7d and run GC' \
	  '  cleanup            Delete old system/user generations and run GC' \
	  '  test_deploy      Temporarily activate HOST on DEPLOY_HOST' \
	  '  deploy           Switch HOST on DEPLOY_HOST permanently' \
	  'HOST defaults to vps for deployment, otherwise the local hostname.' \
	  'clean / cleanup remove rollback history; neither activates a system.' \
	  'Deployment: make test_deploy HOST=oracle-vps (or make deploy HOST=oracle-vps)' \
	  'DEPLOY_HOST defaults to root@HOST (oracle-vps: root@130.162.149.210).' \
	  'BUILD_HOST empty or localhost builds locally; set user@builder for remote builds.' \
	  'Override deployment variables: DEPLOY_HOST=user@address BUILD_HOST=user@builder'

all: help

eval:
	nix eval --no-update-lock-file '.#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath'

build:
	nix build  --no-link '.#nixosConfigurations.$(HOST).config.system.build.toplevel'

debug:
	nix build --no-update-lock-file --no-link --show-trace --option eval-cache false '.#nixosConfigurations.$(HOST).config.system.build.toplevel' |& nom

test:
	sudo nixos-rebuild test --flake '.#$(HOST)' --no-update-lock-file

install:
	sudo nixos-rebuild switch --flake '.#$(HOST)' --no-update-lock-file

update:
	nix flake update

update-secrets:
	nix flake update mysecrets

archive:
	nix flake archive --no-update-lock-file

clean:
	sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system
	sudo nix store gc

cleanup:
	sudo nix-collect-garbage -d # System: removes old generations
	nix-collect-garbage -d # User: removes old generations

build-vm:
	nixos-rebuild build-vm --flake .#vm --no-update-lock-file

list-generations:
	nix profile history --profile /nix/var/nix/profiles/system

list-packages:
	nix-env -qa

# Command-line HOST takes precedence over this deployment default.
test_deploy deploy: HOST = vps

test_deploy:
	nixos-rebuild test --flake '.#$(HOST)' --no-update-lock-file --target-host '$(DEPLOY_HOST)' $(BUILD_HOST_FLAGS) --verbose |& nom

deploy:
	nixos-rebuild switch --flake '.#$(HOST)' --no-update-lock-file --target-host '$(DEPLOY_HOST)' $(BUILD_HOST_FLAGS) --verbose

.PHONY: help all eval build debug test install update update-secrets archive cleanup clean build-vm list-generations list-packages test_deploy deploy
