{ config, lib, pkgs, ... }:
let
  model = "${config.home.homeDirectory}/.local/share/voxtype/models/ggml-large-v3-turbo-q8_0.bin";
in
{
  services.voxtype = {
    enable = true;
    package = pkgs.voxtype-vulkan;
    # Restrict Vulkan to the NVIDIA driver, not Mesa's software implementation.
    environment.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
    settings = {
      engine = "whisper";
      # Native evdev listener: global right-Alt press/release, no compositor bridge.
      hotkey = {
        enabled = true;
        key = "RIGHTALT";
        mode = "push_to_talk";
        modifiers = [ ];
      };
      osd.enabled = false; # No separate OSD frontend is needed.
      audio = {
        device = "default";
        sample_rate = 16000;
        max_duration_secs = 60;
      };
      whisper = {
        mode = "local";
        inherit model;
        language = "zh";
        threads = 6;
        gpu_device = 0;
        flash_attention = true;
        # Keep the primary model resident between recordings, including idle time.
        on_demand_loading = false;
        gpu_isolation = false;
        max_loaded_models = 1;
        cold_model_timeout_secs = 0;
      };
      output = {
        mode = "paste";
        paste_keys = "shift+insert";
        wait_for_modifier_release = true;
        auto_submit = false;
        smart_auto_submit = false;
      };
    };
  };

  # Kitty otherwise pastes PRIMARY on Shift+Insert, not the clipboard set by Voxtype.
  programs.kitty.keybindings."shift+insert" = "paste_from_clipboard";

  # Also provides a declarative CLI entry for narrowly scoped local deployment.
  home.file.".local/bin/voxtype".source = lib.getExe config.services.voxtype.package;

  # Start with the desktop session, whose environment supplies WAYLAND_DISPLAY.
  systemd.user.services.voxtype = {
    Unit = {
      After = [ "pipewire.service" ];
      PartOf = lib.mkForce [ "graphical-session.target" ];
      ConditionPathExists = model;
    };
    Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
  };
}
