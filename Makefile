all:
	sudo nixos-rebuild test --flake . |& nom

install:
	sudo nixos-rebuild switch --flake .

debug:
	sudo nixos-rebuild test --flake . --show-trace

update:
	nix flake update
	sudo nixos-rebuild switch --flake .

cleanup:
	sudo nix profile wipe-history --older-than 7d --profile  /nix/var/nix/profiles/system
	sudo nix store gc --debug
	sudo nixos-rebuild switch --flake .

clean:
	sudo nix-collect-garbage -d # System
	nix-collect-garbage -d # User
	sudo nixos-rebuild switch --flake .

list-generations:
	nix profile history --profile /nix/var/nix/profiles/system

list-packages:
	nix-env -qa

test_deploy:
	  nixos-rebuild test --flake .#racknerd --target-host root@racknerd --build-host localhost --verbose |& nom
deploy:
	  nixos-rebuild switch --flake .#racknerd --target-host root@racknerd --build-host localhost --verbose

.PHONY: all debug install update cleanup clean list-generations list-packages deploy test_deploy
