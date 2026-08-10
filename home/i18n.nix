# fcitx5 + rime 输入法
#
# rime 配置来自 ../rime（取自 rime_mac，词库较新），
# 注意 rime 需要可写目录来编译词典/存用户词频，
# 所以这里不用 xdg.configFile 符号链接，而是在激活时 rsync 一份可写副本。

{ config, pkgs, lib, ... }:

let
  palette = import ./catppuccin.nix;
  # fcitx5 皮肤跟随 flavor：浅色用当前风味，深色固定 mocha（最深）；
  # 明暗仍由 UseDarkTheme 跟随系统 color-scheme 自动切换
  classicuiConf = lib.replaceStrings
    [ "@light-theme@" "@dark-theme@" ]
    [ "catppuccin-${palette.flavor}-green" "catppuccin-mocha-green" ]
    (builtins.readFile ../config/fcitx5/conf/classicui.conf.template);
in

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-gtk
        # catppuccin 主题（含 latte/frappe/macchiato/mocha 全部 accent）
        # withRoundedCorners = true：包安装时自动启用主题自带的圆角
        # （panel.svg/highlight.svg，rx=8），无需本地主题副本
        (catppuccin-fcitx5.override { withRoundedCorners = true; })
      ] ++ (with pkgs.qt6Packages; [
        fcitx5-chinese-addons  # 26.05 起挪到 qt6Packages
        fcitx5-configtool
      ]);
    };
  };

  xdg.configFile = {
    # fcitx5 全局配置与输入法列表（来自 fedora/arch 的 dot-config）
    "fcitx5/config".source = ../config/fcitx5/config;
    "fcitx5/profile".source = ../config/fcitx5/profile;

    # conf/ 下有 classicui.conf（皮肤主题已模板化跟随 flavor：浅=当前风味，
    # 深=mocha-green，跟随系统明暗）、punctuation.conf 等；
    # cached_layouts 是运行时缓存，不部署，让 fcitx5 自己写
    "fcitx5/conf/classicui.conf".text = classicuiConf;   # 模板生成，跟随 flavor
    "fcitx5/conf/notifications.conf".source = ../config/fcitx5/conf/notifications.conf;
    "fcitx5/conf/punctuation.conf".source = ../config/fcitx5/conf/punctuation.conf;
  };

  # 把仓库里的 rime 配置同步到 rime 用户数据目录（可写副本）。
  # 注意 fcitx5-rime 5.1.x 的用户目录是 ~/.local/share/fcitx5/rime
  # （不是 ~/.config/fcitx5/rime！）
  # 排除 user.yaml / installation.yaml，避免覆盖 rime 运行期产生的用户数据；
  # 不带 --delete，保留 rime 自己生成的 build/ 和用户词库。
  # 注意不要用 rsync -t：store 里的 1970 时间戳会让 rime 以为"源文件没变"而跳过部署。
  home.activation.rime = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.local/share/fcitx5/rime"
    run ${pkgs.rsync}/bin/rsync -rl --chmod=u+rwX \
      --exclude user.yaml --exclude installation.yaml \
      "${../rime}/" "$HOME/.local/share/fcitx5/rime/"
  '';
}
