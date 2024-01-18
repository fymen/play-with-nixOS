{pkgs, system, inputs, mysecrets, config, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.age
    inputs.agenix.packages."${system}".default
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."private.org" = {
    symlink = true;
    file = "${mysecrets}/private.age";

    name = ".private.org";
    path = "/home/oscar";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  age.secrets."misc.org" = {
    file = "${mysecrets}/misc.age";
    mode = "600";
    owner = "oscar";
  };

  age.secrets."bw" = {
    file = "${mysecrets}/bw.age";
    name = "bw";
    path = "/home/oscar/.secrets/";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  environment.etc = {
    "agenix/misc.org" = {
      source = config.age.secrets."misc.org".path;
      mode = "0600";
      user = "oscar";
    };
  };

}
