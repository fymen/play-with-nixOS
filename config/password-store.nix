{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      # support for one-time-password (OTP) tokens
      # NOTE: Saving the password and OTP together runs counter to the purpose of secondary verification!
      # exts.pass-otp

      exts.pass-import # a generic importer tool from other password managers
      exts.pass-update # an easy flow for updating passwords
    ]);
    # See the “Environment variables” section of pass(1) and the extension man pages for more information about the available keys.
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      # Overrides the default gpg key identification set by init.
      # Hexadecimal key signature is recommended.
      # Multiple keys may be specified separated by spaces.
      PASSWORD_STORE_KEY = lib.strings.concatStringsSep " " [
        "6AA6021324A86861"
      ];

      PASSWORD_STORE_CLIP_TIME = "45";
      PASSWORD_STORE_GENERATED_LENGTH = "25";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };

  # password-store extensions for browsers
  # you need to install the browser extension for this to work
  # https://github.com/browserpass/browserpass-extension
  programs.browserpass = {
    enable = true;
    browsers = [
      "chromium"
      "firefox"
    ];
  };
}
