{pkgs, system, inputs, ... }:

{
  environment.systemPackages = [
    pkgs.age
    inputs.agenix.packages."${system}".default
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."private.org" = {
    symlink = true;
    file = ./private.age;

    name = ".private.org";
    path = "/home/oscar";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  age.secrets."misc.org" = {
    symlink = true;
    file = ./misc.age;

    name = "misc.org";
    path = "/home/oscar/.secrets/";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  age.secrets."bw" = {
    symlink = true;
    file = ./bw.age;

    name = "bw";
    path = "/home/oscar/.secrets/";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

}
