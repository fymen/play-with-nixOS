{ config, lib, pkgs, username, ... }:
let
  xrayPort = 443;
  # Only public settings enter the Nix store; credentials are merged at startup.
  xrayTemplate = pkgs.writeText "oracle-xray-template.json" (builtins.toJSON {
    log.loglevel = "warning";
    inbounds = [ {
      tag = "vless-reality";
      listen = "0.0.0.0";
      port = xrayPort;
      protocol = "vless";
      settings.decryption = "none";
      streamSettings = {
        network = "tcp";
        security = "reality";
        realitySettings = {
          show = false;
          target = "www.bing.com:443";
          xver = 0;
          serverNames = [ "www.bing.com" ];
        };
      };
    } ];
    outbounds = [
      { protocol = "freedom"; tag = "direct"; }
      { protocol = "blackhole"; tag = "block"; }
    ];
    routing = {
      domainStrategy = "IPIfNonMatch";
      rules = [ {
        type = "field";
        ip = [
          "0.0.0.0/8" "10.0.0.0/8" "100.64.0.0/10" "127.0.0.0/8"
          "169.254.0.0/16" "172.16.0.0/12" "192.168.0.0/16"
          "224.0.0.0/4" "240.0.0.0/4"
          "::/128" "::1/128" "fc00::/7" "fe80::/10" "ff00::/8"
        ];
        outboundTag = "block";
      } ];
    };
  });
in
{
  imports = [
    ./hardware-configuration.nix
    ../../system/system.nix
  ];

  networking.hostName = "oracle-vps";
  networking.useDHCP = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 xrayPort ];
  };
  time.timeZone = "Asia/Shanghai";

  # Keep SSH access independent of the Ubuntu cloud-init/OCI image modules.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjK6DOt7/zGUdDUpKTf1oB37+nZp8fiIBYcGAeDxS5y oscar@laptop"
  ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  environment.systemPackages = with pkgs; [ curl git jq vim xray ];
  zramSwap.enable = true;
  nix.settings.max-jobs = 1;

  age.secrets.oracle-xray = {
    file = ./secrets/xray.age;
    owner = "root";
    mode = "0400";
  };

  services.xray = {
    enable = true;
    settingsFile = "/run/xray/config.json";
  };
  systemd.services.xray = {
    restartTriggers = [ xrayTemplate config.age.secrets.oracle-xray.file ];
    # DynamicUser reads the decrypted secret through systemd credentials.
    script = lib.mkForce ''
      umask 077
      ${pkgs.jq}/bin/jq --exit-status \
        --slurpfile credentials "$CREDENTIALS_DIRECTORY/credentials.json" '
          .inbounds[0].settings.clients = ($credentials[0].clients | map(. + {flow: "xtls-rprx-vision"})) |
          .inbounds[0].streamSettings.realitySettings.privateKey = $credentials[0].privateKey |
          .inbounds[0].streamSettings.realitySettings.shortIds = $credentials[0].shortIds
        ' ${xrayTemplate} > "$RUNTIME_DIRECTORY/config.json"
      ${config.services.xray.package}/bin/xray run -test -format json -config "$RUNTIME_DIRECTORY/config.json"
      exec ${config.services.xray.package}/bin/xray run -config "$RUNTIME_DIRECTORY/config.json"
    '';
    serviceConfig = {
      LoadCredential = lib.mkForce "credentials.json:${config.age.secrets.oracle-xray.path}";
      RuntimeDirectory = "xray";
      RuntimeDirectoryMode = "0700";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  system.stateVersion = "26.05";
}
