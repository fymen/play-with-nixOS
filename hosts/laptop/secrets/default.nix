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

    # Decrypted file will be mount to
    name = ".private.org";
    path = "/home/oscar/";
    mode = "600";
    owner = "oscar";
    group = "users";
  };
}