{ config, inputs, lib, osConfig, pkgs, ... }:
let
  localLlama = osConfig.services.llama-cpp.settings;
  # Audio/CTranslate2 wheels use dlopen. Keep these paths local to Hermes.
  audioLibraries = "${lib.makeLibraryPath [ pkgs.portaudio pkgs.cudaPackages_12.libcublas pkgs.cudaPackages_12.cudnn ]}:/run/opengl-driver/lib";
  hermesWithAudio = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      wrapProgram "$out/bin/hermes" \
        --prefix LD_LIBRARY_PATH : "${audioLibraries}"
    '';
  });
in
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent.enable = true;

  home.packages = [
    (import ../scripts/hermes-weixin-login.nix {
      inherit pkgs;
      hermesPackage = config.programs.hermes-agent.package;
    })
  ];

  services.hermes-agent = {
    enable = true;
    package = hermesWithAudio;
    gateway.enable = true;
    backend.mode = "dashboard";
    backend.port = 9119;

    # Real secrets stay in agenix, never in settings or the Nix store.
    environmentFiles = [ osConfig.age.secrets.hermes-weixin-env.path ];

    # Deep-merge stable preferences; leave onboarding, OAuth and session state alone.
    settings = {
      model = {
        default = "minicpm-v-4.7-35b-a3b";
        # "llamacpp" selects Hermes' own managed server, not our NixOS service.
        provider = "custom";
        base_url = "http://${localLlama.host}:${toString localLlama.port}/v1";
        api_mode = "chat_completions";
        # Existing non-secret loopback credential shared with the local llama.cpp service.
        # Explicitly replace the previous provider's inline key during the deep merge.
        api_key = localLlama.api-key;
        context_length = localLlama.ctx-size;
        streaming = true;
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
}
