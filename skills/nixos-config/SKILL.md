---
name: nixos-config
description: 维护 play-with-nixOS 仓库的多主机 NixOS 与 Home Manager 配置，包括软件包、服务、主机接入、flake 输入和构建故障。用于系统或用户环境配置任务；纯 Emacs Lisp 或桌面交互配置优先使用对应的仓库 skill。
---

# NixOS 与 Home Manager 配置

从仓库根目录执行命令。先读 `agents.org`、`flake.nix` 和目标主机的实际 imports；文档与实现不一致时，以实现为准。检查已有 diff，保留用户正在进行的修改。

## 确定配置归属

- `flake.nix` 的 `hosts` 和 `mkHost` 决定主机能力。当前 `desktop`、`laptop` 使用用户 `oscar`，启用 Home Manager、Stylix、agenix；`vps` 使用 `hildar`，仅启用 Home Manager；`vm` 不启用这三个模块。
- 系统服务、启动、网络和系统软件包：`hosts/<host>/configuration.nix`，或其导入的 `system/*.nix`、`modules/*.nix`。
- 用户软件包和应用设置：`hosts/<host>/home.nix`，共享应用模块放在 `config/`。创建模块后要接入实际 imports，不能只创建文件。
- `system/`、`modules/`、`config/` 的文件不会自动导入；先查调用方，确认影响范围。桌面模块可能依赖 `hosts/<host>/variables.nix`，不能直接导入缺少这些变量的 VPS 或 VM。
- NixOS 模块通过 `specialArgs` 获取 `system`、`inputs`、`username`、`host`；Home Manager 通过 `extraSpecialArgs` 获取 `inputs`、`username`、`host`。Home Manager 需要架构时可沿用 `pkgs.stdenv.hostPlatform.system`。

沿用两空格 Nix 缩进和附近的模块风格。不要顺带更新 `system.stateVersion`、`home.stateVersion`、硬件探测文件或无关主机设置。

## 软件包与输入

软件包和选项应匹配 `flake.lock` 锁定的 nixpkgs/Home Manager。检查当前定义或锁定版本的源码；查询远程最新版本只用于明确需要升级的任务。包名变更时同步检查所有受影响的主机。

新增输入时，检查是否需要沿用现有 `inputs.<name>.inputs.nixpkgs.follows` 模式，并只更新任务涉及的输入。修改后检查 `flake.lock` 的 diff，避免顺带刷新其他依赖。

`mysecrets` 是私有 SSH 输入，`flake = false`。agenix 引用在 `hosts/<host>/secrets/default.nix`。保持秘密为加密文件引用，不将解密内容放进仓库或诊断输出。私有输入不可访问时，报告具体受阻步骤，不用占位 secrets 替换真实配置。

## 新增主机

在 `hosts/<name>/` 创建所需配置，向 `flake.nix` 的 `hosts` 增加条目。只在启用 Home Manager 时添加并接入 `home.nix`；只有导入桌面模块时才需要相应 `variables.nix`。硬件配置来自目标机器或用户提供的信息，不复制其他主机的磁盘 UUID、显卡总线 ID 或网络设置。

## 验证与激活

先读 `Makefile`。当前目标的实际副作用是：

- `make`、`make debug`：执行 `sudo nixos-rebuild test`，会临时激活系统。
- `make install`：执行 `switch`，会激活并更新启动默认项。
- `make build`：先更新 `mysecrets` 锁，再构建；不适合需要保持锁文件的普通验证。
- `make update`：更新全部输入并 `switch`。
- `make deploy`、`make test_deploy`：分别对 VPS 执行远程 `switch`、`test`。
- `make clean`、`make cleanup`：清理历史或 store，并再次激活系统。

普通配置修改先使用不激活、不更新锁文件的命令。以下以 `desktop` 为例，替换成目标主机：

```sh
nix eval --no-update-lock-file .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix build --no-update-lock-file --no-link .#nixosConfigurations.desktop.config.system.build.toplevel
```

共享模块影响多个主机时，验证实际导入它的主机；不需要为仅修改说明文字构建整个系统。Nix flake 可能忽略新建但未跟踪的文件；遇到路径缺失先检查 `git status`，说明原因并依照任务已有的暂存授权处理。

构建、求值、激活和远程部署是不同的结果。仅在任务已授权相应操作时激活或部署；已有授权无需再次询问。构建遇到下载、SSH 或权限限制时准确报告，不将这些限制描述成配置错误。最终说明影响的主机、实际完成的验证和仍未验证的部分。
