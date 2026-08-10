# NixOS 配置：9800X3D + RTX 5080

niri（Wayland）+ 全局 catppuccin（深 mocha / 浅 latte）+ fcitx5-rime + clash 代理。

本仓库已纳入 git 管理：flake 打包的是 **git 跟踪的文件**（不是整个目录），
详见下方「git 与 flake 快照」一节。

## 目录结构

```
~/nix-conf/                   # 仓库即活配置（git 仓库）
├── flake.nix                     # nixpkgs 26.05 + home-manager release-26.05
├── configuration.nix             # 系统配置（GRUB 双启 / ly 登录管理器 / niri / 字体 / 系统级游戏配置）
├── hardware-configuration.nix    # 安装器生成，勿改
├── hardware/graphics.nix         # 显卡驱动（nvidia/amd/intel/none 一行切换）
├── home/                         # home-manager 模块
│   ├── default.nix               # 入口 + 用户软件 + git + steam
│   ├── shell.nix                 # zsh + powerlevel10k
│   ├── i18n.nix                  # fcitx5 + rime + catppuccin 主题
│   ├── niri.nix                  # 桌面配置部署 + waybar/dunst/fuzzel/alacritty/btop 颜色模板
│   ├── catppuccin.nix            # 主题单一数据源（flavor + 四套官方色板）
│   ├── theme.nix                 # 全局 catppuccin（GTK/kvantum/光标/图标）
│   ├── lazygit.nix               # lazygit + catppuccin 主题（跟随色板）
│   └── clash.nix                 # clash 用户服务 + 代理环境变量
├── config/                       # ~/.config 的内容（来自 fedora/arch dot-config，已适配台式机）
│   ├── niri/config.kdl.template  # 模板（focus-ring/border 颜色由 home/niri.nix 生成）；
│   │                             # 显示器块按注释自行启用
│   ├── waybar/                   # config.jsonc + scripts/gpu_stats.sh、bandwidth.sh
│   │                             # （style.css 由 home/niri.nix 模板生成）
│   ├── fuzzel/                   # fuzzel.ini.template + scripts/fuzzel-power 电源菜单
│   ├── dunst/                    # dunstrc.template（颜色占位符，由 niri.nix 替换）
│   ├── swaylock/config.template  # catppuccin latte（换风味手动同步）
│   ├── fcitx5/                   # config + profile + conf/classicui.conf
│   ├── mpd/mpd.conf、copyq/copyq.conf、Thunar/、nvim/
├── rime/                         # rime 输入方案（取自 rime_mac，词库较新）
└── clash/                        # 仅临时存放（二进制/geoip/订阅配置，不入库，
                                  # 机器上真正用的是 ~/clash slot，见 home/clash.nix）
```

## 部署

```bash
# 仓库即活配置，直接指路径构建（不用拷到 /etc/nixos，flake 路径随意）：
sudo nixos-rebuild switch --flake /home/zhouc_yu/nix-conf#nixos
```

首次使用 flake 前，如果当前系统还没开过 flakes 特性，先开一下：

```bash
sudo nixos-rebuild --option experimental-features "nix-command flakes" \
  switch --flake /home/zhouc_yu/nix-conf#nixos
```

### git 与 flake 快照（重要）

本仓库已纳入 git，flake 从 **git 跟踪的文件** 生成快照，而不是复制整个目录：

- **新增文件必须 `git add`**，否则 flake 看不到（rebuild 报 "path does not exist"）。
- **被 .gitignore 忽略的文件不会进快照**，但 home 模块里引用了它们，git 模式下会报错：
  - `wallpaper.jpg`（壁纸，964K）——`home/niri.nix` 引用 `../wallpaper.jpg`。
    解决：`git add -f wallpaper.jpg`（或从 .gitignore 删掉再 add）。
  - `clash/`——**已改 slot 模式**，不再从仓库引用：`home/clash.nix` 从机器本地
    `~/clash`（clashSlot）同步，目录里只需放 clash 二进制 + Country.mmdb +
    订阅导出的 config.yaml。**slot 不存在时 clash 及代理环境变量/alias 整体不启用**，
    rebuild 不会报错。仓库里的 `clash/` 目录只作临时存放，不入库（gitignore）。
  - git 身份同 slot 模式：`home/default.nix` 从机器本地 `~/slot/git-identity` 读
    （两行：第一行姓名、第二行邮箱），文件不存在就不设身份。
- 想彻底绕开 git 规则（例如在机器上直接拷目录部署）：删掉目录里的 `.git`，
  此时 flake 打包整个目录，wallpaper / clash 都会包含。

### nixpkgs 输入是滚动 tarball（lock 会过期）

`flake.nix` 的 nixpkgs / nixpkgs-unstable 指向 USTC 频道的 `nixexprs.tar.xz`，
内容随频道更新而变。**频道一更新，flake.lock 里的 narHash 就过期了**，rebuild 会报
`hash mismatch in file downloaded from ...`（或 nix 内部 call-flake.nix 求值错误）。
rebuild 前先更新这两个 input：

```bash
sudo nix flake update nixpkgs nixpkgs-unstable
```

（`nixos-rebuild switch --flake` 不会自动更新 lock。）

### 首次注意

1. 用户 `zhouc_yu` 已手动创建，密码不受 rebuild 影响。
2. 首次启动 zsh 会进入 p10k configure 向导，配一次即可。
3. 进 niri 后运行 `niri msg outputs` 看显示器接口名，编辑
   `config/niri/config.kdl.template` 里的 output 块启用/调整（改动后 rebuild 生效）。
4. nvim 首次启动 lazy.nvim 会自动拉取插件（需网络，代理已在环境变量里）。

## 敏感信息（推远端前过一遍）

仓库里含以下个人信息，推远端前想清楚（至少用私有仓库）：

- `clash/config.yaml`（仓库内临时副本）及机器上 `~/clash` slot 里的订阅地址/密钥：
  均不入库（gitignore / 仓库外）；注意 flake 部署会把 clash 复制进全局可读的
  nix store，介意的话不要把这台机器的 store 共享给别的用户。
- `configuration.nix`：SSH 公钥 + 用户名/主机名（`user@macbook`、
  `user@nixos`）。公钥本身可公开，但暴露了用户名和设备名。
- **git 身份（姓名/邮箱）**：已改 slot 模式，从机器本地 `~/slot/git-identity`
  读取（两行：第一行姓名、第二行邮箱），不入库；文件缺失则不设身份。
- `rime/wubi.schema.yaml`：词库作者信息（同上邮箱）。
- `config/copyq/copyq.conf`：copyq 配置（当前不含剪贴板历史）。剪贴板条目会写进该文件，
  提交前检查是否混入敏感内容；home-manager 部署的是只读符号链接，正常情况下条目写不进去。

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
- 登录管理器是 **ly**（TUI，matrix 动画主题），配置在 `configuration.nix` 的
  `services.displayManager.ly.settings`。
- 显卡驱动在 `hardware/graphics.nix`：换机器改顶部 `graphicsDriver` 一行
  （nvidia/amd/intel/none）；5080 遇驱动问题可把 nvidia package 改成
  `nvidiaPackages.latest`。
- `maple-mono` 直接来自 nixpkgs（26.05 里是 v7.9，带 NF-CN/NF-CN-unhinted 等变体），
  升级随频道走，不再自打包。
- 代理默认全局注入（shell + niri 环境）；临时开关用 `proxy-on` / `proxy-off`。
