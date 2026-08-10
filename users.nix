# 用户配置：账号 / shell / 用户组
# （从 configuration.nix 拆出，单独管理）

{ config, lib, pkgs, ... }:

{
  # 账号已创建且密码已修改，此处只做声明式管理（shell/用户组）。
  # 若以后重装系统，可临时加 initialPassword 或 hashedPassword。
  # SSH 公钥不再入库（私人信息），需要时在机器上手动加入
  # /home/zhouc_yu/.ssh/authorized_keys 或临时在配置里加。
  users.users.zhouc_yu = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };
}
