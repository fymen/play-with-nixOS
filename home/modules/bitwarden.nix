{
  pkgs,
  config,
  ...
}: {
  systemd.user.services.bitwarden-session = {
    Unit = {
      Description = "bitwarden-session";
      After = "graphical-session.target";
    };
    # Install = {
    # WantedBy = [ "graphical-session.target" ];
    # };
    Service = {
      # Type = "oneshot";
      Type = "idle";
      ExecStart = let
        bw = "${pkgs.bitwarden-cli}/bin/bw";
        script = pkgs.writeShellScript "bw-session" ''
          source ${config.home.homeDirectory}/.secrets/bw
          ${bw} login --apikey --nointeraction > /dev/null
        '';
      in
        script;
    };
  };

  home.packages = [
    pkgs.bitwarden
    pkgs.bitwarden-cli
    (pkgs.writeShellScriptBin "bwget" ''
      # From: https://www.drumm.sh/blog/2021/08/25/bw-cli/
      set -e
      copy_uname_and_passwd () {
        # Print the name of the selected login
        echo "Name: $(printf "%s" "$1" | jq -r ".name")"
        echo "> Copying Username"
        # Copy the username to the clipboard
        printf "%s" "$1" | jq -r ".login.username" | wl-copy
        echo "> Press any key to copy password..."
        # Wait for user input before coping the password
        read
        echo "> Copying Password"
        # Copy the password to the clipboard
        printf "%s" "$1" | jq -r ".login.password" | wl-copy
      }

      # Search for passwords using the search term
      logins="$(bw list items --search $1)"

      if [ $(printf "%s" "$logins" | jq ". | length") -eq 1  ]
      then
        login="$(printf "%s" "$logins" | jq ".[0]")"
      else
        name="$(printf "%s" "$logins" | jq -r ".[].name" | fzf --reverse)"
        login="$(printf "%s" "$logins" | jq ".[] | select(.name == \"$name\")")"
      fi

      copy_uname_and_passwd "$login"

    '')
  ];
}
