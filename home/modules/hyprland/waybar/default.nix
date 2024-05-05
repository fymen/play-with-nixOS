{ pkgs, config, lib, ... }:

{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [{
      layer = "top";
      position = "top";

      modules-left = [ "hyprland/workspaces" "tray"];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "custom/vpn" "idle_inhibitor" "backlight" "pulseaudio" "battery" "network" "clock" "custom/power"];
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "0" = "0";

            urgent = "";
            active = "";
            default = "";
        };
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock" = {
        format-alt = "{: %I:%M %p}";
        tooltip = false;
      };
      "hyprland/window" = {
        max-length = 80;
        separate-outputs = false;
      };
      "memory" = {
        interval = 5;
        format = " {}%";
        tooltip = true;
      };
      "cpu" = {
        interval = 5;
        format = " {usage:2}%";
        tooltip = true;
      };
      "disk" = {
        format = "  {free}";
        tooltip = true;
      };
      "backlight" = {
		    tooltip = false;
		    format = " {}%";
		    interval = 1;
        on-scroll-up = "brightnessctl  s +5";
		    on-scroll-down = "brightnessctl  s 5-";
	    };
      "network" = {
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        format-ethernet = ": {bandwidthDownOctets}";
        format-wifi = "{icon} {signalStrength}%";
        format-disconnected = "󰤮";
        tooltip = false;
      };
      "tray" = {
        spacing = 12;
      };
      "pulseaudio" = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = ["" "" ""];
        };
      on-click = "pavucontrol";
    };
    "custom/themeselector" = {
      tooltip = false;
      format = "";
      on-click = "theme-selector";
    };
    "custom/startmenu" = {
      tooltip = false;
      format = "";
      on-click = "rofi -show drun";
    };
    "custom/power" = {
        format = "";
        on-click = "wlogout";
    };
    "custom/vpn" = {
      format = "vpn{icon}";
      format-icons = [ "" "" ];
      tooltip-format = "{icon}";
      exec = "tailscale_stats.sh";
      return-type = "json";
      interval = 5;
      on-click = "tailscale.sh";
    };
    "idle_inhibitor" = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
      tooltip = "true";
    };
    "custom/notification" = {
      tooltip = false;
      format = "{icon} {}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "task-waybar";
      escape = true;
    };
    "battery" = {
      states = {
        good = 80;
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%";
      format-plugged = " {capacity}%";
      format-icons = ["" "" "" "" ""];
      on-click = "";
      tooltip = false;
    };
  }];
  style = ''
	* {
	  border: none;
  	border-radius: 2px;
		font-size: 20px;
		font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
    font-weight: bold;
	}
	window#waybar {
  	background: transparent;
	}
	#workspaces {
		    background: linear-gradient(180deg, #${config.colorScheme.colors.base00}, #${config.colorScheme.colors.base01});
    		margin: 2px;
    		padding: 0px 1px;
    		border-radius: 10px;
    		border: 0px;
    		font-style: normal;
    		color: #${config.colorScheme.colors.base04};
	      }
	#workspaces button {
    		padding: 0px 5px;
    		margin: 4px 3px;
    		border-radius: 10px;
    		border: 0px;
    		color: #${config.colorScheme.colors.base04};
    		background-color: #${config.colorScheme.colors.base00};
    		opacity: 1.0;
    		transition: all 0.3s ease-in-out;
	}
	#workspaces button.active {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base04};
    		border-radius: 10px;
    		min-width: 40px;
    		transition: all 0.3s ease-in-out;
    		opacity: 1.0;
	}
	#workspaces button:hover {
    		color: #${config.colorScheme.colors.base00};
    		background: #${config.colorScheme.colors.base05};
    		border-radius: 10px;
    		opacity: 1.0;
	}
	tooltip {
  		background: #${config.colorScheme.colors.base00};
  		border: 1px solid #${config.colorScheme.colors.base04};
  		border-radius: 10px;
	}
	tooltip label {
  		color: #${config.colorScheme.colors.base07};
	}
	#window {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius:10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#memory {
    		color: #${config.colorScheme.colors.base0F};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#clock {
    		color: #${config.colorScheme.colors.base0B};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#cpu {
    		color: #${config.colorScheme.colors.base07};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#disk {
    		color: #${config.colorScheme.colors.base03};
    		background: #${config.colorScheme.colors.base00};
    		border-radius:10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#battery {
    		color: #${config.colorScheme.colors.base07};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
  #battery.charging, #battery.plugged {
	      color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
  }
  #battery.critical:not(.charging) {
    		color: #${config.colorScheme.colors.base08};
    		background: #${config.colorScheme.colors.base00};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
  }
  #backlight {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
  }
	#network {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#tray {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#pulseaudio {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#custom-notification {
    		color: #${config.colorScheme.colors.base0C};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
    #custom-themeselector {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
    }
	#custom-startmenu {
    		color: #${config.colorScheme.colors.base03};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
  #custom-power {
    		color: #${config.colorScheme.colors.base0F};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
  }
	#custom-vpn {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
	#idle_inhibitor {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 10px;
    		margin: 2px;
    		padding: 2px 20px;
	}
    '';
  };
}
