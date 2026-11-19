{ pkgs, hermesPackage }:
pkgs.writeShellApplication {
  name = "hermes-weixin-login";
  text = ''
    exec ${hermesPackage.hermesVenv}/bin/python3 -B ${./hermes-weixin-login.py} "$@"
  '';
}
