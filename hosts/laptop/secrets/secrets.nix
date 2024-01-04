let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjK6DOt7/zGUdDUpKTf1oB37+nZp8fiIBYcGAeDxS5y oscar@laptop";
in
{
  "private_org.age".publicKeys = [ laptop ];
}
