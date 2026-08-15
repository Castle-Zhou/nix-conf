# NixOS 配置：niri + catppuccin（多机通用，公开仓库）

niri（Wayland）+ 全局 catppuccin（深 mocha / 浅 latte）+ fcitx5-rime + clash 代理。

**仓库内零机器痕迹**：多台机器共用一套配置，每台机器的差异通过
`machine.nix`（Nix 代码层）和 `~/slot/`（机器本地数据层）表达，见下文「个性化机制」。

## 快速开始

```bash
# 1. 克隆并准备机器配置
git clone https://github.com/Castle-Zhou/nix-conf.git && cd nix-conf
cp machine.nix.example machine.nix        # 按注释填写（用户名/主机名/显卡/引导…）

# 2. 在目标 NixOS 机器上生成硬件配置（root 执行）
#    注意：生成到临时目录，避免覆盖仓库里的 configuration.nix！
sudo nixos-generate-config --root / -d /tmp/hwgen   # 生成 hardware-configuration.nix 与 configuration.nix
cp /tmp/hwgen/hardware-configuration.nix .          # 只拷硬件配置

# 3. 让 flake 看到这两个被 gitignore 的文件（flake 只打包 git 跟踪的文件）
git add -f machine.nix hardware-configuration.nix
# 可选（推荐）：之后 git status 不再显示它们，也防手滑误提交
git update-index --skip-worktree machine.nix hardware-configuration.nix

# 4. 部署（首次使用 flake 前需先开 flakes，见下方「首次注意」）
sudo nixos-rebuild switch --flake "$PWD"#nixos
```

> `machine.nix` / `hardware-configuration.nix` 是本机文件，**不要提交**
> （.gitignore 已忽略；`git add -f` 只是让 flake 可见，暂存即可，无需 commit）。

## 个性化机制

仓库是通用的，个性化分两层，都留在仓库外：

### machine.nix —— Nix 代码层（每台机器自己写，不入库）

身份、引导、内核、显卡、服务开关等**结构性差异**：

| 项目 | 写法 |
| --- | --- |
| 用户名/主机名 | `my.username = "alice"; my.hostName = "nixos";` |
| 显卡驱动 | `my.graphicsDriver = "nvidia";`（nvidia/amd/intel/none） |
| 引导 | GRUB 双启 Windows / systemd-boot，按机器写 `boot.loader.*` |
| 内核 | `boot.kernelPackages = pkgs.linuxPackages_latest;` |
| 服务 | 蓝牙 / Steam / gamemode 等按需开启 |
| 覆盖共享默认值 | `lib.mkForce`（如时区、ly 主题） |
| home 补丁 | `home-manager.users.${config.my.username}.imports` 追加模块 |

### ~/slot/ —— 数据层（机器本地私有文件，git 完全碰不到）

| 文件 | 作用 | 缺失时行为 |
| --- | --- | --- |
| `~/slot/git-identity` | git 姓名/邮箱（两行） | 不设 git 身份 |
| `~/slot/clash/` | clash 二进制 + Country.mmdb + 订阅 config.yaml | clash 整套（服务/代理/alias）不启用 |
| `~/slot/niri.kdl` | niri 配置 patch | 用仓库默认 niri 配置 |
| `~/slot/wallpaper.jpg` | 机器壁纸 | 用仓库默认壁纸 |
| `~/slot/rime/` | 整套 rime 配置（不想用默认五笔时整目录替换） | 用仓库默认五笔方案 |
| `~/slot/waybar.jsonc` | waybar 配置整文件覆盖（如笔记本加 battery 模块） | 用仓库默认 waybar |

### niri 个性化（重点）

niri 25.11+ 支持配置 `include`。主配置末尾会追加
`include "~/.config/niri/niri-machine.kdl"`（niri ≥ 26.04 支持 `~` 展开），
该文件由 `~/slot/niri.kdl` 生成，与主配置**共用同一套主题色占位符**。

include 是合并语义：**后写覆盖前写、binds 冲突键覆盖、output/window-rule 追加**，
所以 slot 文件里可以：

```kdl
// 例：追加自己的显示器配置（接口名用 `niri msg outputs` 查）
output "eDP-1" {
  scale 1.0
  // ...
}

// 例：覆盖默认快捷键
binds {
  Mod+T { spawn "foot"; }
}
```

可用占位符（与主模板同一套）：
`@focus-active@` `@focus-inactive@` `@border-active@` `@border-inactive@`
`@border-urgent@` `@overview-bg@` `@home@` `@username@`。

## 目录结构

```
nix-conf/
├── flake.nix                     # 入口：nixosConfigurations.nixos（通用输出）
├── machine.nix.example           # 机器配置模板（复制为 machine.nix 使用）
├── configuration.nix             # 共享系统配置（读 config.my.*，无机器痕迹）
├── common/
│   ├── options.nix               # my.* 机器可调选项
│   └── graphics.nix              # 显卡驱动（由 my.graphicsDriver 决定）
├── users.nix                     # 用户账号（用户名由 my.username 决定）
├── home/                         # home-manager 共享模块
│   ├── default.nix               # 入口 + 用户软件 + git
│   ├── shell.nix                 # zsh + powerlevel10k
│   ├── i18n.nix                  # fcitx5 + rime + catppuccin 主题
│   ├── niri.nix                  # 桌面配置部署（niri/waybar/dunst/fuzzel/…模板）
│   ├── catppuccin.nix            # 主题单一数据源（flavor + 四套官方色板）
│   ├── theme.nix / lazygit.nix / clash.nix
├── config/                       # ~/.config 的模板/素材（niri/waybar/dunst/…）
├── rime/                         # rime 输入方案
└── wallpaper.jpg                 # 默认壁纸（个人壁纸放 ~/slot/wallpaper.jpg）
```

## 部署

```bash
# 仓库即活配置，直接指路径构建（不用拷到 /etc/nixos，flake 路径随意）：
sudo nixos-rebuild switch --flake /path/to/nix-conf#nixos
```

### git 与 flake 快照（重要）

本仓库已纳入 git，flake 从 **git 跟踪的文件** 生成快照，而不是复制整个目录：

- **新增文件必须 `git add`**，否则 flake 看不到（rebuild 报 "path does not exist"）。
- **被 .gitignore 忽略的文件不会进快照**，需要入库就得 `git add -f`：
  - `machine.nix` / `hardware-configuration.nix`：**每个使用者本地生成**，
    强制添加后 flake 才可见（见「快速开始」）。
  - `wallpaper.jpg`：仓库默认壁纸已入库；个人壁纸放 `~/slot/wallpaper.jpg`，
    不要覆盖仓库文件。
- 想彻底绕开 git 规则（例如在机器上直接拷目录部署）：删掉目录里的 `.git`，
  此时 flake 打包整个目录。

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

1. 用户需手动创建（或在 machine.nix 里临时加 initialPassword），密码不受 rebuild 影响。
2. 首次启动 zsh 会进入 p10k configure 向导，配一次即可。
3. 进 niri 后运行 `niri msg outputs` 看显示器接口名，把显示器块写进 `~/slot/niri.kdl`。
4. nvim 首次启动 lazy.nvim 会自动拉取插件（需网络，代理已在环境变量里）。

## 主题切换（浅色 latte ⇄ 深色 mocha，frappe/macchiato 备用）

主开关在 `home/catppuccin.nix` 顶部的 `flavor = "latte"`，一行改完 GTK / Qt(kvantum) /
图标 / 明暗偏好 / waybar / dunst / fuzzel / alacritty / btop / swaylock /
niri focus-ring / fcitx5 皮肤全部自动切换。剩余手动项：

| 组件 | 切换方式 |
| --- | --- |
| 光标 | `home/theme.nix` 里 Bibata 主题（只有 Ice/Classic 两色，与 catppuccin 无关） |
| 壁纸 | 静态图片，不跟随（`~/slot/wallpaper.jpg`） |
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
  `services.displayManager.ly.settings`（机器想换风格在 machine.nix 里 mkForce）。
- 显卡驱动在 `common/graphics.nix`：`my.graphicsDriver` 一行切换
  （nvidia/amd/intel/none）；NVIDIA 遇驱动问题可把 nvidia package 改成
  `nvidiaPackages.latest`。
- `maple-mono` 直接来自 nixpkgs（26.05 里是 v7.9，带 NF-CN/NF-CN-unhinted 等变体），
  升级随频道走，不再自打包。
- 代理默认全局注入（shell + niri 环境）；临时开关用 `proxy-on` / `proxy-off`。
- niri 的机器 patch（include）需要 niri ≥ 25.11；`~` 展开需要 ≥ 26.04
  （nixos-26.05 频道及以上）。

## 高级用法：作为模块库嵌入自己的 flake

```nix
# 你的 flake 里
nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
  modules = [
    input.nix-conf.nixosModules.default
    ./hardware-configuration.nix
    { my.username = "alice"; my.hostName = "myhost"; ... }
    home-manager.nixosModules.home-manager
    { home-manager.extraSpecialArgs.username = "alice"; ... }
  ];
};
```

（home-manager 部分同理：`homeManagerModules.default` 需要 `username` 特殊参数。）
