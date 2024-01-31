{
  config,
  pkgs,
  mysecrets,
  ...
}: {
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gtk2";
  };

  home.packages = with pkgs; [
    pinentry-gtk2
  ];

  programs.gpg = {
    enable = true;

    # package = (pkgs.callPackage ../../packages/gpg.nix {});

    homedir = "${config.home.homeDirectory}/.gnupg";
    #  $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option.
    #
    # If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation.
    # Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = true;

    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option.
    #
    # If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications.
    # Thus we can only update pubring.kbx via home-manager
    mutableKeys = true;
    publicKeys = [
      # https://www.gnupg.org/gph/en/manual/x334.html
      {
        source = "${mysecrets}/gpg-keys.pub";
        trust = 5;
      } # ultimate trust, my own keys.
    ];
  };
}
