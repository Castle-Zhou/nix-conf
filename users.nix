# 用户配置：账号 / shell / 用户组（用户名来自 my.username，machine.nix 里设置）
# （从 configuration.nix 拆出，单独管理）

{ config, lib, pkgs, ... }:

{
  # 账号需手动创建（重装系统时可临时加 initialPassword），此处只做声明式管理。
  # 用户级软件按机器需要加在 machine.nix：
  #   users.users.${config.my.username}.packages = [ pkgs.steam ];
  users.users.${config.my.username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };
}
