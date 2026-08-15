# 多机通用 NixOS 配置（公开仓库，仓库内零机器痕迹）
#
# 用法：
#   1. cp machine.nix.example machine.nix，按注释填写
#   2. sudo nixos-generate-config --root / -d .     （生成 hardware-configuration.nix）
#   3. git add -f machine.nix hardware-configuration.nix   （被 gitignore，必须强制添加）
#   4. sudo nixos-rebuild switch --flake /path/to/repo#nixos
#
# 个性化分层：
#   - machine.nix  —— Nix 代码层：身份/引导/内核/显卡/服务开关（每台机器自己写）
#   - ~/slot/      —— 数据层：clash 订阅、git 身份、niri patch、壁纸等私有文件
#   详见 README「个性化机制」。

{
  description = "NixOS configuration: niri + catppuccin, multi-machine ready";

  inputs = {
    # USTC 镜像 channel tarball，国内直连，无需代理
    nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-26.05/nixexprs.tar.xz";
    # pi-coding-agent 只在 unstable 有，单独引入
    nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";
    # github 经 gh-proxy 镜像（若该代理挂了，换回 github 原始 URL 并用代理跑 rebuild）
    home-manager = {
      url = "https://gh-proxy.com/https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pi 的 catppuccin 主题（含 home-manager 模块）
    pi-catppuccin = {
      url = "https://gh-proxy.com/https://github.com/otahontas/pi-coding-agent-catppuccin/archive/refs/heads/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, pi-catppuccin, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./machine.nix   # 机器本地配置（gitignore + git add -f，见 machine.nix.example）

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # 已存在的 ~/.config 文件冲突时备份为 *.hm-bak
          home-manager.backupFileExtension = "hm-bak";
          # 共享给所有 home 模块的特殊参数（pkgs-unstable；username 由 machine.nix 注入）
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          home-manager.sharedModules = [
            pi-catppuccin.homeManagerModules.default
          ];
        }
      ];
    };

    # 给高级用户：把本仓库作为模块库嵌入自己的 flake
    # （需自行提供 machine.nix 等价物与 username 特殊参数，见 README「高级用法」）
    nixosModules.default = import ./configuration.nix;
    homeManagerModules.default = import ./home/default.nix;
  };
}
