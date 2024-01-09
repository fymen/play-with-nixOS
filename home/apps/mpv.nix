{
  programs.mpv.enable = true;

  xdg.configFile."mpv/mpv.conf".text = ''
    vo=gpu
    hwdec=auto
    profile=gpu-hq

    scale=ewa_lanczossharp
    cscale=ewa_lanczossharp
    video-sync=display-resample
    interpolation
    tscale=oversample
    '';
}
