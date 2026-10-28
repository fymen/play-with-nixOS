---
name: hyprland-desktop
description: 维护本仓库通过 Home Manager 管理的 Hyprland 桌面，包括显示器、缩放、快捷键、Waybar、启动器、通知、锁屏和配套脚本。用于 desktop 或 laptop 的 Wayland 桌面行为与外观修改。
---

# Hyprland 桌面配置

从 `hosts/<host>/home.nix` 的 imports 和 `hosts/<host>/variables.nix` 确认目标主机。桌面模块由 `desktop`、`laptop` 共用；修改共享文件前检查是否会同时影响两台机器。

## 修改位置

- `hosts/<host>/variables.nix`：`extraMonitorSettings`、`keyboardLayout`、`wallpaper`、`terminal`、`browser`、`clock24h`。只改一台机器的分辨率、缩放或默认应用时优先修改这里。
- `config/hyprland.nix`：通过 `wayland.windowManager.hyprland.extraConfig` 中的 Nix 字符串生成 Hyprland 配置，含按键、窗口规则、自启动、环境变量；同一文件还配置 Hyprlock、Hypridle、壁纸链接和截图设置。
- `config/waybar.nix`：Waybar 模块、事件命令和样式。
- `config/rofi.nix`、`config/swaync.nix`、`config/wlogout.nix`、`config/ibus.nix`：启动器、通知、注销与输入法。
- `scripts/*.nix`：以 `pkgs.writeShellScriptBin` 等方式打包的辅助命令；是否安装取决于调用方，新增脚本需要接入 `home.packages` 或其他实际使用处。

## 保持配置联动

新增或修改快捷键时，查找同一组合是否重复，检查绑定使用的命令是否已安装。`terminal` 可能是带参数的命令（当前为 `kitty -e tmux`），不要无意间当成单个可执行文件路径引用。

`scripts/list-hypr-bindings.nix` 是手工维护的帮助窗口，与实际快捷键可能存在旧差异。以 `config/hyprland.nix` 为事实来源，同步本次涉及的帮助条目，不顺带改动无关快捷键。

修改 Nix 多行字符串中的 shell 时区分 Nix 插值 `${...}` 和 shell 插值；在 Nix 缩进字符串中，shell 的 `${var}` 通常需写成 `''${var}`。检查传给 launcher、Waybar 的引号和参数边界。

Stylix 在系统层启用，但部分应用在主机 `home.nix` 中通过 `stylix.targets.<app>.enable = false` 使用手工主题。先读对应应用和主机设置，再决定主题归属，不套用统一颜色策略。

显卡差异来自系统配置：desktop 启用 NVIDIA，laptop 启用 AMD。涉及驱动、输出端口或渲染故障时查看 `hosts/<host>/configuration.nix` 和实际驱动开关；不从导入了哪些驱动模块推断实际启用状态。

## 验证与会话应用

先验证 Nix 语法、生成配置和命令依赖，再按需要求值或构建目标主机。共享改动检查 desktop、laptop 的实际影响。以下命令仅构建、不激活，替换主机名后使用：

```sh
nix build --no-update-lock-file --no-link .#nixosConfigurations.desktop.config.system.build.toplevel
```

`make` 会临时激活系统，`make build` 会更新私有输入锁；普通桌面修改不应顺带更新依赖。

运行中的桌面不一定加载了新配置。仅在任务授权的范围内重载或重启相关组件；本任务若只是编辑配置，交付文件与验证结果即可。不要直接改写 Home Manager 管理的生成文件来代替持久修改。

如果执行了运行时验证，区分配置错误、缺失命令、服务失败和不存在 Wayland 会话的环境限制。说明哪些结果来自静态检查或构建，哪些来自实际桌面观察。
