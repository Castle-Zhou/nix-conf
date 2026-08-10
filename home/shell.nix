# zsh + powerlevel10k（沿用旧配置）
# 首次启动若没有 ~/.p10k.zsh 会进入 p10k configure 向导，按需配置一次即可

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;   # 关掉灰色影子补全（右方向键补全那个）
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
    };

    history = {
      size = 8192;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    sessionVariables = {
      PATH = "$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin";
    };

    initContent = ''
      # Powerlevel10k 主题
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # 如果 p10k 配置文件存在，则加载
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # 更好的历史搜索
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
    '';

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.zsh";
      }
    ];
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
