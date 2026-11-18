SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

HOST ?= $(shell hostname)
DEPLOY_HOST ?= root@vps
BUILD_HOST ?= localhost

help:
	@printf '%s\n' \
	  'Usage: make <target> [HOST=desktop|laptop|vps|vm]' \
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
	  '  test_deploy      Temporarily activate vps on DEPLOY_HOST' \
	  '  deploy           Switch vps on DEPLOY_HOST permanently' \
	  'HOST defaults to the local hostname; deployment always uses .#vps.' \
	  'clean / cleanup remove rollback history; neither activates a system.' \
	  'Deployment variables: DEPLOY_HOST=root@vps BUILD_HOST=localhost'

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

test_deploy:
	nixos-rebuild test --flake .#vps --no-update-lock-file --target-host '$(DEPLOY_HOST)' --build-host '$(BUILD_HOST)' --verbose |& nom

deploy:
	nixos-rebuild switch --flake .#vps --no-update-lock-file --target-host '$(DEPLOY_HOST)' --build-host '$(BUILD_HOST)' --verbose

.PHONY: help all eval build debug test install update update-secrets archive cleanup clean build-vm list-generations list-packages test_deploy deploy
