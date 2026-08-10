# clash 代理
#
# clash 目录（二进制 + config.yaml）在 ../clash，
# 运行时需要可写目录（cache.db、外部 UI 缓存等），
# 所以激活时 rsync 一份可写副本到 ~/.config/clash。
# 二进制是静态链接的 linux x86-64 ELF，可直接在 NixOS 上跑。

{ config, pkgs, lib, ... }:

let
  clashDir = "${config.home.homeDirectory}/.config/clash";
in
{
  home.activation.clash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${clashDir}"
    run ${pkgs.rsync}/bin/rsync -rlpt --chmod=u+rwX \
      --exclude cache.db \
      "${../clash}/" "${clashDir}/"
    run chmod +x "${clashDir}/clash"
  '';

  systemd.user.services.clash = {
    Unit = {
      Description = "Clash Daemon";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${clashDir}/clash -d ${clashDir}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # 代理环境变量（niri config.kdl 的 environment 块对 GUI 也设了小写版本）
  home.sessionVariables = {
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    ALL_PROXY = "socks5://127.0.0.1:7891";
    NO_PROXY = "localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
  };

  # git 走代理
  programs.git.settings = {
    http.proxy = "http://127.0.0.1:7890";
    https.proxy = "http://127.0.0.1:7890";
  };

  programs.zsh.shellAliases = {
    clash-start = "systemctl --user start clash";
    clash-stop = "systemctl --user stop clash";
    clash-restart = "systemctl --user restart clash";
    clash-status = "systemctl --user status clash";
    clash-log = "journalctl --user -u clash -f";
    proxy-on = "export HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 ALL_PROXY=socks5://127.0.0.1:7891";
    proxy-off = "unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy";
  };
}
