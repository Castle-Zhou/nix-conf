# clash 代理
#
# 私人配置（订阅 config.yaml、二进制、geoip 库）不入库，走 slot 模式：
#   1. 机器上准备一个本地目录（~/slot/clash，见下面 clashSlot），
#      放入 clash 二进制、Country.mmdb、订阅导出的 config.yaml；
#   2. home-manager 激活时把它 rsync 成 ~/.config/clash 的可写副本；
#   3. slot 目录不存在（机器上没准备 clash）就整体不启用：
#      不同步、不启动服务、不设代理变量/alias，rebuild 不会报错。
#
# 准备方法（机器上执行一次）：
#   mkdir -p ~/slot/clash
#   cp clash 二进制 Country.mmdb config.yaml ~/slot/clash/   # 从旧机器/订阅导出

{ config, pkgs, lib, ... }:

let
  clashDir = "${config.home.homeDirectory}/.config/clash";
  # 机器本地 slot（不入库，git/flake 都碰不到），统一放 ~/slot 下
  clashSlot = "${config.home.homeDirectory}/slot/clash";
  # 求值发生在机器本机（nixos-rebuild 在目标机跑），判断是准的
  hasClash = builtins.pathExists clashSlot;
in
lib.mkIf hasClash {
  home.activation.clash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${clashDir}"
    run ${pkgs.rsync}/bin/rsync -rlpt --chmod=u+rwX \
      --exclude cache.db \
      "${clashSlot}/" "${clashDir}/"
    run chmod +x "${clashDir}/clash" 2>/dev/null || true
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
