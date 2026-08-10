# home-manager 入口：导入所有子模块

{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./i18n.nix    # fcitx5 + rime
    ./niri.nix    # niri/waybar/fuzzel 等桌面配置部署
    ./theme.nix   # 全局 catppuccin（GTK/Qt/光标/图标）
    ./shell.nix   # zsh + p10k
    ./lazygit.nix # lazygit + catppuccin 主题
    ./clash.nix   # clash 代理
  ];

  home.username = "zhouc_yu";
  home.homeDirectory = "/home/zhouc_yu";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Zhou Chenyu";
      email = "zhouc_yu@foxmail.com";
    };
  };

  # github-cli：git 操作走 https（跟随 http.proxy 代理，无需额外 SSH 代理）
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  home.packages = (with pkgs; [
    neovim
    vscode
    fastfetch
    localsend

    # 压缩/解压
    zip
    xz
    unzip
    p7zip

    yazi

    # 命令行工具
    ripgrep
    fd
    fzf
    btop
    iotop
    iftop

    # misc
    file
    which
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix 相关
    nix-output-monitor

    # 写作/阅读
    hugo
    glow

    # 系统监控/调试
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

    # nvim (lazy.nvim/treesitter) 需要编译器
    gcc

    # 开发环境（hwb / pi 等）
    nodejs_22
    yarn

    jq
  ]) ++ [
    # pi 编码助手（来自 unstable）
    pkgs-unstable.pi-coding-agent
  ];

  home.stateVersion = "26.05";
}
