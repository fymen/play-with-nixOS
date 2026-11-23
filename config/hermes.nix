{ config, inputs, lib, osConfig, pkgs, ... }:
let
  localLlama = osConfig.services.llama-cpp.settings;
  # Audio/CTranslate2 wheels use dlopen. Keep these paths local to Hermes.
  audioLibraries = "${lib.makeLibraryPath [ pkgs.portaudio pkgs.cudaPackages_12.libcublas pkgs.cudaPackages_12.cudnn ]}:/run/opengl-driver/lib";
  hermesWithAudio =
    # 避免将来更新输入后继续使用过时的版本标记。
    assert inputs.hermes-agent.rev ==
      "3371c03df62106a4c93a545787a471e328883d08";

    (inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      version = "0.23.2";
      distance = 1041;
    }).overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        wrapProgram "$out/bin/hermes" \
          --prefix LD_LIBRARY_PATH : "${audioLibraries}"
      '';
    });

  # Hermes Desktop 的独立包（Electron app），用于生成 .desktop 入口。
  hermesDesktop = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop;
in
{
  imports = [
    inputs.hermes-agent.homeManagerModules.default
    inputs.hypruse.homeModules.default
  ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };

  programs.hypruse = {
    enable = true;
    # GUI/systemd callers may not inherit the compositor's PATH.
    package = (inputs.hypruse.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      withHyprctl = true;
    }).overrideAttrs (old: {
      # Upstream's source filter omits this file, but its metadata test needs it.
      postPatch = (old.postPatch or "") + ''
        cp ${inputs.hypruse}/uv.lock uv.lock
      '';
    });
  };

  home.file = {
    ".local/bin/hypruse".source = lib.getExe config.programs.hypruse.package;
    # Provider discovery requires this exact directory name; extraPlugins
    # would instead create a nix-managed-* entry.
    "hypruse-hermes-provider" = {
      target = "${config.services.hermes-agent.hermesHome}/plugins/hypruse";
      source = "${inputs.hypruse}/integrations/hermes/hermes_hypruse";
    };
  };

  home.packages = [
    (import ../scripts/hermes-weixin-login.nix {
      inherit pkgs;
      hermesPackage = config.programs.hermes-agent.package;
    })
  ];

  services.hermes-agent = {
    enable = true;

    package = hermesWithAudio;
    extraPackages = [ config.programs.hypruse.package ];
    gateway.enable = true;
    backend.mode = "dashboard";
    backend.port = 9119;

    # Real secrets stay in agenix, never in settings or the Nix store.
    environmentFiles = [ osConfig.age.secrets.hermes-weixin-env.path
                         osConfig.age.secrets.deepseek-api-key.path
                       ];

    # Deep-merge stable preferences; leave onboarding, OAuth and session state alone.
    settings = {
      model = {
        default = "deepseek-v4-flash"; # 或 "deepseek-v4-pro"
        provider = "deepseek";
        base_url = "https://api.deepseek.com/v1";
            
        
        # default = "minicpm-v-4.7-35b-a3b";
        # # "llamacpp" selects Hermes' own managed server, not our NixOS service.
        # provider = "custom";
        # base_url = "http://${localLlama.host}:${toString localLlama.port}/v1";
        # api_mode = "chat_completions";
        # # Existing non-secret loopback credential shared with the local llama.cpp service.
        # # Explicitly replace the previous provider's inline key during the deep merge.
        # api_key = localLlama.api-key;
        # context_length = localLlama.ctx-size;
        # streaming = true;
      };

      # computer_use providers are selected separately, not generic plugins.
      plugins.enabled = [ "memory-wiki" ];

      computer_use = {
        backend = "hypruse";

        hypruse = {
          command = lib.getExe config.programs.hypruse.package;
          delivery = "background";
          timeout = 60;
        };
      };

      agent = {
        max_turns = 30;
        tool_use_enforcement = true;
        service_tier = "auto";
        verify_on_stop = true;
      };

      terminal = {
        backend = "local";
        cwd = "${config.home.homeDirectory}/hworkspace";

        timeout = 120;
      };

      browser = {
        executable_path = "${pkgs.google-chrome}/bin/chromium";
        headed = true;
        inactivity_timeout = 600;
      };

      mcp_servers."computer-use-linux" = {
        enabled = true;

        # 使用已安装包的固定 Nix 路径，不依赖 PATH。
        command = toString
          config.home.file.".local/bin/computer-use-linux".source;
        args = [ "mcp" ];

        env = {
          COMPUTER_USE_LINUX_ENABLE_SHELL = "0";
          WAYLAND_DISPLAY = "\${WAYLAND_DISPLAY}";
          HYPRLAND_INSTANCE_SIGNATURE = "\${HYPRLAND_INSTANCE_SIGNATURE}";
          DBUS_SESSION_BUS_ADDRESS = "\${DBUS_SESSION_BUS_ADDRESS}";
        };


        tools.include = [
          "doctor"
          "list_windows"
          "focused_window"
          "list_apps"
          "get_app_state"
          "get_tree_page"
          "screenshot"
          "activate_window"
          "type_text"
          "press_key"
          "click"
        ];
      };

      # INT8 GPU weights and a short idle timeout leave headroom for MiniCPM.
      stt = {
        enabled = false;
        provider = "local";
        language = "zh";
        local = {
          model = "turbo";
          language = "zh";
          device = "cuda";
          compute_type = "int8_float16";
          vad = true;
          condition_on_previous_text = false;
          unload_after_idle_seconds = 60;
        };
      };

      voice = {
        record_key = "ctrl+b";
        max_recording_seconds = 60;
        silence_duration = 2.0;
        auto_tts = false;
        stop_phrases = [ "停止语音" "结束语音" "stop" ];
      };

      compression = {
        enabled = true;
        threshold = 0.5;
        target_ratio = 0.2;
      };

      display = {
        language = "zh-CN";
        show_reasoning = false;
        show_cost = false;
        skin = "mono";  # 可选: "default", "dark", "light"
      };

      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };

      platforms.weixin = {
        enabled = true;
        extra = {
          dm_policy = "pairing";
          group_policy = "disabled";
        };
      };
    };
  };

  # rofi(drun) 里启动原生 Wayland 版 Hermes Desktop。
  # 模块生成的 com.nousresearch.hermes.desktop 不带 --ozone-platform=wayland，
  # 会落到 XWayland；此同名入口写进 ~/.local/share/applications/，优先级更高。
  xdg.desktopEntries."com.nousresearch.hermes" = {
    name = "Hermes";
    genericName = "Hermes Desktop";
    comment = "Launch Hermes Desktop";
    exec = "${hermesDesktop}/bin/hermes-desktop --ozone-platform=wayland";
    icon = "${hermesDesktop}/share/icons/hicolor/1024x1024/apps/hermes.png";
    terminal = false;
    categories = [ "Utility" ];
    settings = {
      StartupNotify = "true";
      StartupWMClass = "com.nousresearch.hermes";
    };
  };
}
