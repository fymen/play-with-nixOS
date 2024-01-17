{

  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      profile = "gpu-hq";
      hwdec = "auto-safe";
      gpu-context = "wayland";
      # force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      volume-max = 200;
      fs = true;
      screen = 0;
      # save-position-on-quit = true;
      osc = false;

      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale="oversample";
    };
  };

  # xdg.configFile."mpv/mpv.conf".text = ''
  #   vo=gpu
  #   hwdec=auto
  #   profile=gpu-hq

  #   scale=ewa_lanczossharp
  #   cscale=ewa_lanczossharp
  #   video-sync=display-resample
  #   interpolation
  #   tscale=oversample
  #   '';
}
