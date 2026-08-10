# lazygit + catppuccin 主题
# 颜色从 home/catppuccin.nix 色板生成（单一数据源），
# 换 flavor/accent 后 rebuild，lazygit 自动跟随。

{ config, pkgs, ... }:

let
  catppuccin = import ./catppuccin.nix;
  c = catppuccin.palettes.${catppuccin.flavor};
in
{
  programs.lazygit = {
    enable = true;

    settings.theme = {
      # 配色对齐官方 catppuccin/lazygit 主题（用 hex 值，跟随色板）
      activeBorderColor = [ c.${catppuccin.accent} "bold" ];
      inactiveBorderColor = [ c.text ];
      optionsTextColor = [ c.blue ];
      selectedLineBgColor = [ c.surface0 ];
      cherryPickedCommitBgColor = [ c.blue ];
      cherryPickedCommitFgColor = [ c.blue ];
      unstagedChangesColor = [ c.red ];
      defaultFgColor = [ c.text ];
      searchingActiveBorderColor = [ c.peach ];
      selectedRangeBgColor = [ c.blue ];
    };
  };
}
