all:
	sudo nixos-rebuild test --flake .

install:
	sudo nixos-rebuild switch --flake .

debug:
	sudo nixos-rebuild test --flake . --show-trace --fast --option eval-cache false |& nom

build:
	nix flake lock --update-input mysecrets
	nixos-rebuild build --flake . --fast --show-trace |& nom
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


home:
	home-manager --flake .#oscar@m2



.PHONY: all debug install update cleanup clean list-generations list-packages deploy test_deploy home build
