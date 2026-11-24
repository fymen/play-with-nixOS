let
  # Re-encrypt for the replacement host key when recreating the instance.
  oracleVps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7jTvtpTUVCpTw/DmZ3S815GGlTKAtgzRB4Z2T8uCBj";
  oscar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjK6DOt7/zGUdDUpKTf1oB37+nZp8fiIBYcGAeDxS5y";
in
{
  "xray.age".publicKeys = [ oracleVps oscar ];
}
