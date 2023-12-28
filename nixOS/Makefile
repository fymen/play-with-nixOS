all:
	sudo nixos-rebuild test --flake .

switch:
	sudo nixos-rebuild switch --flake .

clone:
	git clone git@github.com:fymen/.emacs.d.git	~/.emacs.d
	mkdir -p ~/org/ && git clone git@github.com:fymen/roaming.git ~/org/roam

clean:
	sudo nix-collect-garbage -d
