# NixOS 配置：9800X3D + RTX 5080

niri（Wayland）+ 全局 catppuccin（深 mocha / 浅 latte）+ fcitx5-rime + clash 代理。

## 目录结构

```
~/nix-conf/                   # 仓库即活配置
├── flake.nix                     # nixpkgs 26.05 + home-manager release-26.05
├── configuration.nix             # 系统配置（GRUB 双启 / nvidia / sddm / niri / 字体 / steam）
├── hardware-configuration.nix    # 安装器生成，勿改
├── home/                         # home-manager 模块
│   ├── default.nix               # 入口 + 用户软件 + git
│   ├── shell.nix                 # zsh + powerlevel10k
│   ├── i18n.nix                  # fcitx5 + rime + catppuccin 主题
│   ├── niri.nix                  # 桌面配置部署 + waybar/dunst/fuzzel/alacritty/btop 颜色模板
│   ├── catppuccin.nix            # 主题单一数据源（flavor + 四套官方色板）
│   ├── theme.nix                 # 全局 catppuccin（GTK/kvantum/光标/图标）
│   ├── lazygit.nix               # lazygit + catppuccin 主题（跟随色板）
│   └── clash.nix                 # clash 用户服务 + 代理环境变量
├── config/                       # ~/.config 的内容（来自 fedora/arch dot-config，已适配台式机）
│   ├── niri/config.kdl           # 已去掉笔记本配置；显示器块按注释自行启用
│   ├── waybar/                   # config.jsonc + scripts/gpu_stats.sh、bandwidth.sh
│   │                             # （style.css 由 home/niri.nix 模板生成）
│   ├── fuzzel/                   # fuzzel.ini.template + scripts/fuzzel-power 电源菜单
│   ├── dunst/                    # dunstrc.template（颜色占位符，由 niri.nix 替换）
│   ├── swaylock/config           # catppuccin latte（换风味手动同步）
│   ├── fcitx5/                   # config + profile + conf/classicui.conf
│   ├── mpd/mpd.conf、copyq/copyq.conf、Thunar/、nvim/
├── rime/                         # rime 输入方案（取自 rime_mac，词库较新）
└── clash/                        # clash 静态二进制 + config.yaml（端口 7890/7891）
```

## 部署

```bash
# 仓库本身即活配置，直接指路径构建（不用拷到 /etc/nixos，
# flake 路径随意，nix 会把整个目录快照进 store）：
sudo nixos-rebuild switch --flake /home/zhouc_yu/nix-conf#nixos
```

首次使用 flake 前，如果当前系统还没开过 flakes 特性，先开一下：

```bash
sudo nixos-rebuild --option experimental-features "nix-command flakes" \
  switch --flake /home/zhouc_yu/nix-conf#nixos
```

首次注意：

1. 用户 `zhouc_yu` 已手动创建，密码不受 rebuild 影响。
2. 首次启动 zsh 会进入 p10k configure 向导，配一次即可。
3. 进 niri 后运行 `niri msg outputs` 看显示器接口名，编辑
   `~/.config/niri/config.kdl` 里的 `/-output "DP-1"` 块启用/调整。
4. nvim 首次启动 lazy.nvim 会自动拉取插件（需网络，代理已在环境变量里）。
5. 注意：`clash/config.yaml` 里有订阅信息/密钥，flake 会将其复制进全局可读的
   nix store，介意的话不要把这台机器的 store 共享给别的用户。

## 主题切换（浅色 latte ⇄ 深色 mocha，frappe/macchiato 备用）

主开关在 `home/catppuccin.nix` 顶部的 `flavor = "latte"`，一行改完 GTK / Qt(kvantum) /
图标 / 明暗偏好 / waybar / dunst / fuzzel / alacritty / btop / swaylock /
niri focus-ring / fcitx5 皮肤全部自动切换。剩余手动项：

| 组件 | 切换方式 |
| --- | --- |
| 光标 | `theme.nix` 里 Bibata 主题（只有 Ice/Classic 两色，与 catppuccin 无关） |
| 壁纸 | 静态图片，不跟随 |
| fcitx5 皮肤细节 | 圆角半径在 nixpkgs 源包的 `panel.svg`/`highlight.svg` 的 `rx=`；候选字大小在 `config/fcitx5/conf/classicui.conf.template` 的 `Font=` |

## 已知注意事项

- **rime / clash / btop 需要可写目录**：都在 home.activation 里用 rsync 同步为
  可写副本（不是只读符号链接）。rime 同步排除了 `user.yaml`/`installation.yaml`，
  不带 `--delete`，用户词频不会被 rebuild 冲掉；btop 同理（用户自加主题保留），
  rebuild 时模板重新同步一次 conf。
- `~/.config/{niri,waybar,dunst,fuzzel,alacritty,fcitx5,nvim,...}` 是指向 nix store
  的只读符号链接，**改配置要改 config/ 里的源文件再 rebuild**；
  程序运行时写这些目录会失败（如 lazy-lock.json 更新、fcitx5-configtool 保存），
  属预期行为。想临时手改可以 `home-manager switch` 前先删掉对应符号链接。
- 若 SDDM（Wayland 模式）在 nvidia 下出问题：
  `services.displayManager.sddm.wayland.enable = false;` 退回 X11 模式。
- 5080 若遇驱动问题，`configuration.nix` 里把 nvidia package 改成
  `nvidiaPackages.latest`。
- `maple-mono` 直接来自 nixpkgs（26.05 里是 v7.9，带 NF-CN/NF-CN-unhinted 等变体），
  升级随频道走，不再自打包。
- 代理默认全局注入（shell + niri 环境）；临时开关用 `proxy-on` / `proxy-off`。
- flake 会把整个仓库目录复制进 nix store；如果仓库变成 git 仓库，
  新文件记得 `git add`，否则 flake 看不到。
