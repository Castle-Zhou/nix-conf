# 显卡驱动（多机通用版）
#
# 驱动类型由 my.graphicsDriver 决定（machine.nix 里设置）：
#   "nvidia" —— NVIDIA 独显
#              注意：50 系必须 open = true；40 系及以前建议 open = false（closed 更稳）
#   "amd"    —— AMD 核显/独显（内核自带 amdgpu）
#   "intel"  —— Intel 核显（modesetting，现代推荐）
#   "none"   —— 不装专有驱动，modesetting 兜底
#
# 笔记本核显 + NVIDIA 独显的 hybrid（prime offload）暂未配置，
# 需要时参考 https://nixos.wiki/wiki/Nvidia#Laptop_GPUs 补 hardware.nvidia.prime。

{ config, lib, pkgs, ... }:

let
  videoDrivers = {
    nvidia = [ "nvidia" ];
    amd = [ "amdgpu" ];
    intel = [ "modesetting" ];
    none = [ "modesetting" ];
  }.${config.my.graphicsDriver};
in
{
  # 基础图形（所有驱动通用）
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/32 位游戏需要
  };

  services.xserver.videoDrivers = videoDrivers;

  # NVIDIA 专有配置
  hardware.nvidia = lib.mkIf (config.my.graphicsDriver == "nvidia") {
    modesetting.enable = true;
    open = true; # 50 系只能用 open kernel modules；40 系及以前改 false
    nvidiaSettings = true;
    # 如遇驱动问题可指定更新的版本：
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
