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
      # Keep local-content conversations and their summaries on the local server.
      model = {
        default = "inkling";
        provider = "custom";
        base_url = "http://${localLlama.host}:${toString localLlama.port}/v1";
        api_mode = "chat_completions";
        api_key = localLlama.api-key;
        # The server retains 64K capacity; normal agent sessions compact earlier.
        context_length = 32768;
        streaming = true;
      };

      # Inkling and MiniCPM share the local llama.cpp router.
      # 在 Hermes 里用 /model inkling 切换；context_length 由 Hermes 探测本地端点得到。
      model_aliases.inkling = {
        model = "inkling";
        provider = "custom";
        base_url = "http://${localLlama.host}:${toString localLlama.port}/v1";
        api_key = localLlama.api-key;
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
        executable_path = "${pkgs.chromium}/bin/chromium";
        headed = true;
        inactivity_timeout = 600;
      };

      # Disable entries retained by Hermes' settings merge, including its legacy key.
      mcp_servers."computer-use-linux".enabled = false;
      mcpServers."computer-use-linux".enabled = false;

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
        threshold_tokens = 12000;
        target_ratio = 0.2;
        proactive_prune_tokens = 4096;
        # idle_compact_after_seconds = 600;
      };

      auxiliary.compression = {
        provider = "custom";
        model = "inkling";
        base_url = "http://${localLlama.host}:${toString localLlama.port}/v1";
        api_key = localLlama.api-key;
        timeout = 300;
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
