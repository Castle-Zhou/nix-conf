# 全局 catppuccin 主题
#
# ┌─────────────────────────────────────────────────────┐
# │  换主题只改 home/catppuccin.nix 的 flavor           │
# │  （latte / frappe / macchiato / mocha）              │
# │  GTK / Qt / 图标 / 明暗偏好 / waybar 全部自动跟随    │
# └─────────────────────────────────────────────────────┘
# 其余手动项：
#   alacritty: 改 ~/.config/alacritty/alacritty.toml 的 import（四风味都在）
#   swaylock:  配色在 ../config/swaylock/config（已随 flavor 手动同步）
#   SDDM:      configuration.nix 里 catppuccin-sddm 的 flavor + theme
#   dunst:     配置文件里是 latte 配色，换深色才需要动

{ config, pkgs, lib, ... }:

let
  palette = import ./catppuccin.nix;
  flavor = palette.flavor;
  accent = palette.accent;
  isDark = flavor != "latte";
in
{
  home.packages = with pkgs; [
    papirus-icon-theme
    catppuccin-kvantum    # 含全部风味，kvconfig 指名即可

    # 深色主题也装着备用，切换时不用重新构建
    (catppuccin-gtk.override { variant = "mocha"; accents = [ accent ]; })
  ];

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-${flavor}-${accent}-standard";
      package = pkgs.catppuccin-gtk.override { variant = flavor; accents = [ accent ]; };
    };
    iconTheme = {
      name = if isDark then "Papirus-Dark" else "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    # HM 26.05：显式让 gtk4 跟随 gtk.theme（保持旧默认行为，消除警告）
    gtk4.theme = config.gtk.theme;
  };

  # 光标沿用 niri 配置里指定的 Bibata
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 28;   # 与 niri config.kdl 的 xcursor-size 保持一致
    gtk.enable = true;
  };

  # Qt 应用：qtct + kvantum，kvantum 加载 catppuccin
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    theme=catppuccin-${flavor}-${accent}
  '';

  # GTK4/libadwaita 明暗偏好；fcitx5 候选窗（latte-green/mocha-green）也跟随它
  dconf.settings."org/gnome/desktop/interface".color-scheme =
    if isDark then "prefer-dark" else "prefer-light";

  # pi 的 catppuccin 主题（模块由 pi-catppuccin flake 输入提供）
  programs.pi.catppuccin = {
    enable = true;
    flavor = flavor;
  };
}
