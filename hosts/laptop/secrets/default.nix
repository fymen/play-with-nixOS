{
  pkgs,
  flake,
  config,
  ...
}: {
  environment.systemPackages = [
    pkgs.age
    flake.inputs.agenix.packages."x86_64-linux".default
  ];

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  age.secrets."private.org" = {
    symlink = true;
    file = "${flake.inputs.mysecrets}/private.age";

    name = ".private.org";
    path = "/home/oscar";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  age.secrets."misc.org" = {
    file = "${flake.inputs.mysecrets}/misc.age";
    mode = "600";
    owner = "oscar";
  };

  age.secrets."bw" = {
    file = "${flake.inputs.mysecrets}/bw.age";
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
