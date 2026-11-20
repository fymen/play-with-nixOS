# 本机每日技术早报（Hermes 管理）

`hosts/desktop/home.nix` 导入 `config/daily-report.nix`。调度统一交给现有 Hermes 网关的
原生 cron，不再使用 systemd 日报定时器。北京时间的两个任务如下：

| 任务 | cron | 时区 | 执行内容 |
| --- | --- | --- | --- |
| 技术早报·采集 | `50 8 * * *` | `Asia/Shanghai` | RSS/Atom 采集、本地模型摘要与归档 |
| 技术早报·微信投递 | `0 9 * * *` | `Asia/Shanghai` | 检查当日报告，通过 Hermes 发微信 |

两者均使用 `--no-agent`：Hermes 调度确定性脚本，记录执行状态、日志和故障；不再另开
带工具权限的代理自由搜索。摘要仍由本机 llama.cpp 生成。

## 为什么任务的 Deliver 显示 local？

**日报由投递脚本内的 `hermes send` 发往微信。** cron 的 `deliver=local` 只保存脚本的
状态输出，不再把这份输出发送一次。这保留了发送成功后才写入标记、同日不重复发送、
失败自动重试的逻辑，也无需把私人收件人标识写入 cron 任务定义。

每个脚本最多执行三次，每次最长 10 分钟，失败间隔两分钟。微信发送失败会使脚本最终
以非零状态退出，Hermes cron 将任务记为失败，可通过 `runs`/`incidents` 检查。失败通知
只保存在本地，不保证微信故障时能收到微信告警。

## 准点和补跑

时区固定为 `Asia/Shanghai`。Hermes ticker 轮询、网络、模型和微信 API 都可能带来延迟，
不是 09:00:00 精确送达保证。采集提前到 08:50 以减少等待。

两个任务均设置 `catch_up=on`、`grace_minutes=1440`，网关恢复后在最近日程的 24 小时窗口
内补跑，由 Hermes 原生调度器决定补跑时机。投递若发现当日报告不存在，会先采集；即使
补跑时两个任务乱序，也由文件锁和当日标记防止重复。电脑关机/休眠、网关关闭时无法准点
发送；不主动唤醒电脑。网关用户管理器需持续运行，本机已启用 linger。

## 仓库配置与部署

`config/daily-report.nix` 提供 `daily-report`、`daily-report-setup` 命令。Home Manager 激活时
执行 setup：

- 把采集、发送包装脚本作为**普通文件**复制到 `~/.hermes/scripts/`。Hermes 拒绝解析到
  scripts 目录外的 store 符号链接，因此不能用 `home.file` 的默认链接方式部署它们。
- 通过 Hermes CLI 注册或更新两个任务，不直接改写 cron 数据库。
- 复用旧的“每日新闻报告”任务作为投递任务；发现同名重复任务则停止，不猜测。
- 第一次注册的新任务保持暂停，需显式执行 `daily-report-setup --activate`。以后普通重建
  保留操作者的暂停/恢复选择；定义未变化则不重新计算下一次执行时间。
- 修改前备份旧任务注册表到 `~/.hermes/cron/daily-report.before-migration.json`；不把备份
  直接覆盖回运行中的注册表，恢复应通过 Hermes CLI 完成。

本次已局部构建并执行 setup、启用两个 Hermes 任务；未全系统 switch。旧的两个用户级
systemd 定时器已停用，旧用户 unit 链接已清理。`~/.local/state/daily-report/nix-roots/hermes-setup`
是间接 GC root，保留脚本引用的构建产物。

仓库的 `system/daily-report.service` 和 `.timer` 是旧草稿，本次不修改、不启用它们。
新文件尚未纳入 Git 时，普通 Git flake 会忽略它们，验证需用 `path:.`：

```sh
nix eval --no-update-lock-file path:.#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
```

纳入 Git 后可沿用 `make eval HOST=desktop`、`make install HOST=desktop`。首次全量部署后
使用 `daily-report-setup --activate` 启用；本机这次已经启用，无需再次操作。

## 私有运行配置

`~/.config/daily-report/target`：权限 0600，单行 `weixin:chat_id`，不得提交仓库。
接收人沿用已经验证的现有 Hermes 会话。账号凭据继续由 Hermes/agenix 管理，不重新扫码。
微信会话过期时沿用 `hermes-weixin-login` 恢复；必要时给 Hermes 微信联系人发送一条消息
刷新上下文，不应擅自替换成其他人的会话。

`~/.config/daily-report/model.json` 由 Home Manager 生成，复用本机 llama.cpp；其中的
loopback key 与 `config/hermes.nix` 一样是非秘密的本地占位凭据。换外部模型时，真实密钥
必须改用运行时秘密，不能写进 `xdg.configFile.*.text`。

## 内容与数据

固定来源包括 OpenAI、Hugging Face、Google DeepMind、NixOS 博客/社区公告、GNU Emacs
公告、Sacha Chua 的 Emacs 社区文章、Hermes/Pi 官方 GitHub Releases。
不是全网搜索，也不覆盖所有模型厂商、论文、插件。未收录不能等同于没有更新。

首次覆盖过去 24 小时，之后按每个来源的成功水位增量抓取，故障恢复最多回看 7 天。
按 URL 去重，模型从每类最多五条候选中选最多十条；模型失败则每类最多两条原始标题降级，
明确标注未生成中文分析。未选中的候选不形成待发送队列。失败来源明确列出，全部来源失败
不生成新日报。空板块不编造消息。

外部文章只作为模型输入，无工具权限；引用从采集数据生成，不信任模型生成的链接。
XML 用 defusedxml 解析，响应体限制 2MB；发送前禁用 Hermes 的 `MEDIA:` 附件标记。
中文摘要仍需以原文为准。

报告目录：`~/hworkspace/daily-report/`，每天生成 `YYYY-MM-DD.md`、`YYYY-MM-DD.org` 和
来源 `YYYY-MM-DD.json`。已有归档复制到此目录，不覆盖同目录下的其他旧报告或脚本。
运行状态仍在 `~/.local/state/daily-report/`，包括最新报告缓存、水位、去重和当日投递标记。
档案不自动删除。微信远端已接受、本机尚未写入标记时崩溃仍有重复风险，不承诺 exactly-once。

## 管理命令

```sh
hermes cron list
hermes cron status
hermes cron doctor
hermes cron runs --limit 10
hermes cron incidents

# 先从 list 找到对应 ID；手动触发仍遵守当日防重复规则。
hermes cron run <采集任务ID>
hermes cron run <投递任务ID>
hermes cron pause <任务ID>
hermes cron resume <任务ID>
```

离线测试需要有 requests、defusedxml 的 Python（生产 Nix 包装器已提供）：

```sh
python3 -B -m unittest discover -s scripts -p 'test_daily_report*.py' -v
```
