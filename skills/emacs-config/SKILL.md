---
name: emacs-config
description: 修改或排查本仓库 config/emacs/emacs.org 中的 Org 文学化 Emacs 配置，以及 default.nix 中的 emacs-overlay 打包、依赖和 Home Manager 集成。适用于快捷键、use-package、编辑行为与 Emacs 包加载问题。
---

# Emacs 文学化配置

主要源文件是 `config/emacs/emacs.org`，Nix 入口是 `config/emacs/default.nix`。先检查这两个文件的已有 diff，保留用户的未提交改动。`Readme.org` 中旧的 `home/modules/emacs/emacs.org` 链接不是实际入口。

## 定位与编辑

- 搜索相关 Org 标题、`use-package`、函数、hook 和按键绑定，阅读相邻代码块，避免重复定义或后面的设置覆盖修改。
- 修改对应的 `emacs-lisp` 源码块，保留标题层级和 Babel header。新增有效配置通常沿用附近的 `:tangle yes`；`:tangle no` 块不会成为构建产物。
- 保留块级 `:lexical no` 等现有语义，不把局部修改扩大成全文件词法绑定迁移。
- 按附近的 `:init`、`:custom`、`:hook`、`:bind`、`:config` 风格安排设置，检查延迟加载是否会影响变量和函数可用的时机。
- 持久修改写回 Org 源文件，不直接编辑生成的 init 文件或 Nix store 中的文件。

## 包与运行时依赖

`default.nix` 使用 `pkgs.emacsWithPackagesFromUsePackage`，其 `config = ./emacs.org`、`alwaysEnsure = true`、`alwaysTangle = true`、`defaultInitFile = true`，底层是 `pkgs.emacs-pgtk`。`desktop` 和 `laptop` 在系统配置中导入 emacs-overlay，并在 Home Manager 中启用 `modules.editors.emacs`。

新增 `use-package` 时，同时考虑 Nix 的声明提取和运行时的 `use-package-always-ensure`。内置或本地库可参考附近声明明确设置 `:ensure nil`；不要仅为消除 trace 而关闭无关包的安装。

`extraEmacsPackages` 当前为空。`cursor-chg`、`popweb` 等还有手写 derivation；定义存在不代表已经进入 Emacs 的 load-path。例如 `popweb` 出现在 `home.packages`，不能仅凭这一点认定 `(require 'popweb)` 可用。排查时分别检查 Nix 包集合、生成的 load-path 与 Org 声明。

外部命令、语言服务器、字体、Python 依赖或 ACP adapter 等通常需要 Nix 提供；检查 `home.packages` 和调用方后添加到正确层级。不要假设运行中的 Emacs 已获得刚修改的 PATH 或新构建的软件包。

## 验证

按修改范围选择验证：

1. 对修改过的有效 Lisp 块检查括号、字符串和 reader 语法。可用 `emacs --batch -Q` 配合 Org 解析和 `check-parens`/`read`；跨块构成的表达式应按 tangle 顺序组合检查。
2. 需要检查生成内容时，在临时目录中处理副本，并检查所有 tangle 目标，避免写入真实用户配置。不要为了检查语法执行整份 init，也不要执行其他 Babel 代码块。
3. 改动包或 Nix 集成时，求值或构建实际使用该模块的主机，例如：

   ```sh
   nix build --no-update-lock-file --no-link .#nixosConfigurations.desktop.config.system.build.toplevel
   ```

4. 行为问题用最小相关表达式验证；语法通过、Nix 构建成功和运行时行为正确分别报告。缺少包的 trace 要结合最终错误和实际加载结果判断。

`make` 会临时激活系统，`make build` 会先更新私有 secrets 输入；不要把它们当作单纯的 Lisp 语法检查。

运行于 Emacs 会话中时，只有需要缓冲区未保存内容、point/region 或实时状态才使用可用的 Emacs MCP 工具。保存或编辑前确认磁盘与缓冲区状态，不覆盖未保存内容。只按任务已授权的范围求值配置，避免全量重载扰动会话。
