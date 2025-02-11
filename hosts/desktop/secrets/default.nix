{
  inputs,
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    pkgs.age
    inputs.agenix.packages."x86_64-linux".default
  ];

  age.identityPaths = ["/etc/ssh/id_ed25519"];
  age.secrets."private.org" = {
    symlink = false;
    file = "${inputs.mysecrets}/private.age";

    path = "/home/oscar/.private.org";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  age.secrets."misc.org" = {
    file = "${inputs.mysecrets}/misc.age";
    mode = "600";
    path = "/home/oscar/.secrets/misc.org";
    owner = "oscar";
  };

  age.secrets."bw" = {
    file = "${inputs.mysecrets}/bw.age";
    path = "/home/oscar/.secrets/bw";
    mode = "600";
    owner = "oscar";
    group = "users";
  };

  # environment.etc = {
  #   "agenix/misc.org" = {
  #     source = config.age.secrets."misc.org".path;
  #     mode = "0600";
  #     user = "oscar";
  #   };
  # };
}
