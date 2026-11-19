# Hermes 微信一次性扫码

此辅助工具针对当前锁定 Hermes 的内部 `qr_login` API；升级 Hermes 后先运行
`hermes-weixin-login --check`。它使用同一个 Nix 包的 Python，不需要 pip，也不取消
Home Manager 托管标记。

## 使用

完成 desktop 配置的求值、构建和授权激活后：

```sh
hermes-weixin-login --check
hermes-weixin-login
```

在交互终端中确认后，用手机微信扫码并确认登录。二维码和账号标识会显示在终端，
不要录屏或分享；token 不会被辅助脚本打印。脚本不会启动或重启 Gateway。

默认使用 `$HERMES_HOME`，未设置时使用 `~/.hermes`。可指定：

```sh
hermes-weixin-login --home ~/.hermes --output ~/.hermes/weixin/login-new.env
```

输出：

- `~/.hermes/weixin/accounts/<account_id>.json`：Hermes 自身保存的账号缓存。
- `~/.hermes/weixin/login.env`：权限为 `0600` 的环境文件，包含账号、token 和 API URL。

环境文件已存在时会在扫码前拒绝继续；重登时使用新的 `--output`，不会覆盖已有导出。
扫码仍可能更新 Hermes 对应账号的缓存。如果导出失败，成功扫码产生的缓存仍在。
辅助工具不修改 `.env`、`config.yaml`，也不自动安装秘密配置。

## 持久化到 agenix

1. 将生成的环境文件通过你现有的 agenix 流程加密到私有 `mysecrets` 仓库。
   **不要把明文复制到本仓库或写进 Nix 配置。**
2. 在 `hosts/desktop/secrets/default.nix` 声明 `hermes-weixin-env`，沿用现有秘密的
   owner/group 模式，确保 desktop 用户可读取解密文件。
3. `config/hermes.nix` 的 `services.hermes-agent` 已通过以下声明读取秘密：

   ```nix
   environmentFiles = [ osConfig.age.secrets.hermes-weixin-env.path ];
   ```

4. 求值、构建并授权激活后，重启 Gateway：

   ```sh
   systemctl --user restart hermes-agent
   journalctl --user -u hermes-agent -f
   ```

Home Manager 在激活时通过 `environmentFiles` 生成 `~/.hermes/.env`。只运行扫码脚本
不会使 Gateway 自动读取导出文件，也不会完成微信接入。

当前配置使用 `dm_policy = "pairing"`。向 **iLink 机器人联系人**发消息后，按配对提示
使用 `hermes pairing approve` 批准；具体参数可查 `hermes pairing --help`。
普通微信群通常无法通过 iLink 接收消息，保持群聊关闭。

确认加密秘密及重启后收发正常，再按需删除明文导出；账号缓存同样含有敏感 token。
不要公开 `.env`、账号缓存或完整日志。模型认证及实际回复能力需要另行验证。

## 离线验证

```sh
python3 -B -m unittest discover -s scripts -p 'test_hermes_weixin_login.py' -v
```

这些测试不会访问微信、显示真实二维码或修改现有 Hermes 数据。
