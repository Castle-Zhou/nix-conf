# 系统级共享配置（机器无关）：桌面/网络/字体/声音/SSH 等通用部分
# 机器差异（引导/内核/显卡/主机名/服务开关）在 machine.nix 里表达，见 machine.nix.example

{ config, lib, pkgs, ... }:

{
  imports = [
    ./common/options.nix    # my.* 机器可调选项
    ./common/graphics.nix   # 显卡驱动（由 my.graphicsDriver 决定）
    ./users.nix             # 用户账号（用户名由 my.username 决定）
  ];

  # ========== 引导 ==========
  # 引导器（GRUB 双启 Windows / systemd-boot）与内核版本是机器差异，
  # 在 machine.nix 里配置（见 machine.nix.example），这里不设置用 NixOS 默认。

  boot.plymouth.enable = false;

  # 睡眠/休眠由系统默认行为管理（niri 里不再有 swayidle 超时触发）
  # 注意：hibernate 需要 swap ≥ 内存（内存大的机器要注意），
  # 休眠在内存占用高时会失败；suspend（S3 挂起）不受影响。

  # ========== 网络 ==========
  networking = {
    hostName = config.my.hostName;   # 机器名在 machine.nix 里设置
    networkmanager.enable = true;
  };

  # ========== 时区与区域 ==========
  time.timeZone = "Asia/Shanghai";   # 其他时区可在 machine.nix 里 mkForce 覆盖
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [ "zh_CN.UTF-8/UTF-8" ];

  # ========== 桌面：ly（TUI 登录管理器）+ niri ==========
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    # --- 黑客帝国主题 ---
    animation = "matrix";          # 绿色字符雨
    animation_frame_delay = 8;      # 雨速（默认 5ms/帧，调大更舒缓）
    bg = 536870912;                 # 纯黑背景（0x20000000, TB_HI_BLACK）
    cmatrix_fg = 65280;             # 经典矩阵绿（0x0000FF00）
    cmatrix_head_col = 33554431;    # 白色“雨头”（0x01FFFFFF）
    cmatrix_min_codepoint = 33;     # 0x21，ASCII 可打印字符（英文+数字，不要片假名）
    cmatrix_max_codepoint = 123;    # 0x7B
    hide_borders = true;            # 去掉主框边框，更干净
    hide_key_hints = true;          # 隐藏底部 F1~F7 提示（按键仍生效）
    clock = "%H:%M:%S | %Y-%m-%d %a"; # 右上角时钟：时:分:秒 | 年-月-日 星期

    # --- vim 模式 ---
    vi_mode = true;
    vi_default_mode = "normal";     # normal: j/k 移动、i 输入、Esc 返回；也可改 "insert"

    # --- 去掉 F5/F6 亮度快捷键（登录界面用不到）---
    brightness_up_key = "null";
    brightness_down_key = "null";
  };

  # niri 会话（模块会自动配置 polkit、swaylock PAM、xdg portal、gnome-keyring）
  programs.niri.enable = true;

  # ========== 声音 ==========
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 蓝牙 / Steam / gamemode 等按机器需要的服务在 machine.nix 里开启（见 machine.nix.example）

  programs.zsh.enable = true;
  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 镜像源：SJTU/USTC 为主，官方源兜底（TUNA 的 store 被 WAF 风控 403，先不用）
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];

  # ========== 字体 ==========
  fonts = {
    packages = with pkgs; [
      maple-mono.NF-CN     # Maple Mono NF CN（终端/编辑器主字体，来自 nixpkgs）
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      wqy_microhei
      wqy_zenhei
      lxgw-wenkai
      sarasa-gothic
      # source-han-sans / source-han-serif 与 noto CJK 内容重复，按需开启：
      # source-han-sans
      # source-han-serif
    ];

    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
      monospace = [ "Maple Mono NF CN" "Noto Sans Mono CJK SC" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ========== 系统软件 ==========
  environment.systemPackages = with pkgs; [
    neovim
    vim
    wget
    curl
    git

    # niri 会话所需（spawn-at-startup 里用到的）
    waybar
    fuzzel
    dunst
    swaylock
    swaybg
    swayidle
    xwayland-satellite   # X11 应用（Steam）支持
    polkit_gnome         # polkit 认证代理
    libnotify            # notify-send
    brightnessctl        # waybar 背光模块 / brightness-notify.sh
    pulseaudio           # pactl（volume-notify.sh / waybar）
    wireplumber          # wpctl
    mpc                  # mpd 控制（waybar/fuzzel-music 使用）
    ncmpcpp              # waybar mpd 模块点击打开
    ymuse                # waybar mpd 模块右键打开

    copyq                # 剪贴板历史
    thunar               # 文件管理器
    pavucontrol
  ];

  # Electron/Chromium 系应用走 Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ========== SSH ==========
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
    openFirewall = true;
    ports = [ 22 ];
  };

  system.stateVersion = "26.05";
}
