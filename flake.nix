# 9800X3D + RTX 5080 台式机 / niri + catppuccin
#
# 用法：
#   sudo nixos-rebuild switch --flake /path/to/output#nixos
#
# 注意：flake 会把整个 output/ 目录复制进 nix store，
# 若以后把 output/ 放进了 git 仓库，新文件必须 `git add` 后才会被 flake 看到。

{
  description = "NixOS on 9800X3D + RTX 5080 (niri, catppuccin, fcitx5-rime, clash)";

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

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # 已存在的 ~/.config 文件冲突时备份为 *.hm-bak
          home-manager.backupFileExtension = "hm-bak";
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          home-manager.sharedModules = [
            pi-catppuccin.homeManagerModules.default
          ];
          home-manager.users.zhouc_yu = import ./home/default.nix;
        }
      ];
    };
  };
}
