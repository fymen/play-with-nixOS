# Hermes 默认语音交互与 GPU 转写

已撤销右 Alt、按住说话及快捷键转接的所有启用配置。`config/hermes.nix` 不再覆盖 `voice`
配置块，运行时 `~/.hermes/config.yaml` 中此前加入的 `voice` 覆盖也已清除。
模型、微信、日报和其他配置保持不变。

## 使用 Hermes 默认交互

重新打开 Hermes CLI：

```sh
hermes --cli
```

在 Hermes 内输入：

```text
/voice on
/voice status
```

使用默认 **Ctrl+B**。当前安装版本的默认录音上限为120秒，静音3秒后自动转写，默认停止
短语为 `stop`，不自动播报 TTS。`/voice off` 关闭语音功能。
这些值来自 Hermes 自身默认设置，不再在仓库里重复固定，今后随上游默认值更新。
已有 CLI 进程请关闭后重新打开，以免保留启动时加载的旧设置。

没有全局音频快捷键，右 Alt / AltGr 不再被 Hermes 自定义绑定处理。

## 保留的 GPU 配置

- Faster-Whisper：`stt.provider = local`、`model = turbo`、语言 `zh`。
- `device = cuda`、`compute_type = int8_float16`。
- VAD、`condition_on_previous_text = false`、空闲约60秒卸载识别模型。
- PortAudio、CUDA12 cuBLAS、cuDNN9、`/run/opengl-driver/lib` 仅加入 Hermes 包装器库路径。
  不修改全局 `LD_LIBRARY_PATH`、驱动或 pip 环境。

识别模型是 `mobiuslabsgmbh/faster-whisper-large-v3-turbo`，保存在用户 Hugging Face 缓存中。
GGML 模型现由独立的 Voxtype 管理，位于
`~/.local/share/voxtype/models/ggml-large-v3-turbo-q8_0.bin`，不与 Hermes 共用。
GPU热推理、显存占用取决于音频和其他工作负载；多个 Hermes 进程同时加载模型仍可能争用显存。

## 验证与备份

已通过 desktop Nix 求值、构建和系统切换。Hyprland 已重载，自定义 Hermes 音频绑定数量为0，
配置无报错。通过 Hermes 的 `load_config()` 核实有效默认值为 Ctrl+B / 120秒 / 3秒 / `stop`，
GPU STT 设置仍为 `cuda / int8_float16`。没有主动录音或模拟快捷键。

恢复前的私有配置备份：`~/.local/state/hermes-voice/config.before-default-voice.yaml`，权限0600，
可能包含运行时凭据，不要提交或公开。

```sh
hyprctl configerrors
systemctl --user status hermes-agent
journalctl --user -u hermes-agent --since today
```
