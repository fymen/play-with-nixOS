{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.locate;
in {
  options.services.locate = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, NixOS will periodically update the database of
        files used by the :command:`locate`  command.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "02:15";
      example = "hourly";
      description = ''
        Update the locate database at this interval. Updates by
        default at 2:15 AM every day.

        The format is described in
        systemd.time
7.
      '';
    };

    # Other options omitted for documentation
  };

  config = {
    systemd.services.update-locatedb =
      { description = "Update Locate Database";
        path  = [ pkgs.su ];
        script =
          ''
            mkdir -m 0755 -p $(dirname ${toString cfg.output})
            exec updatedb \
              --localuser=${cfg.localuser} \
              ${optionalString (!cfg.includeStore) "--prunepaths='/nix/store'"} \
              --output=${toString cfg.output} ${concatStringsSep " " cfg.extraFlags}
          '';
      };

    systemd.timers.update-locatedb = mkIf cfg.enable
      { description = "Update timer for locate database";
        partOf      = [ "update-locatedb.service" ];
        wantedBy    = [ "timers.target" ];
        timerConfig.OnCalendar = cfg.interval;
      };
  };
}
