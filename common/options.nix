# 机器可调选项（my.*）：共享配置只消费这些选项，仓库本身不含机器痕迹。
# 每台机器在自己的 machine.nix 里设置（见 machine.nix.example）。

{ lib, ... }:

{
  options.my = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "主用户用户名（machine.nix 里改成你自己的）";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "机器 hostname（machine.nix 里改成你自己的）";
    };

    graphicsDriver = lib.mkOption {
      type = lib.types.enum [ "nvidia" "amd" "intel" "none" ];
      default = "none";
      description = "显卡驱动类型（nvidia / amd / intel / none）";
    };
  };
}
