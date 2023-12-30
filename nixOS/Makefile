all:
	sudo nixos-rebuild test --flake .

switch:
	sudo nixos-rebuild switch --flake .

update:
# Update flake.lock
	nix flake update
# Apply the updates
	sudo nixos-rebuild switch --flake .

wipe:
	sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system
	sudo nix store gc --debug
clean:
	sudo nix-collect-garbage -d

history:
	nix profile history --profile /nix/var/nix/profiles/system

clone:
	git clone git@github.com:fymen/.emacs.d.git	~/.emacs.d
	mkdir -p ~/org/ && git clone git@github.com:fymen/roaming.git ~/org/roam
