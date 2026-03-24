{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [ "git" "z" "fzf" "docker" "kubectl" ];
    };

    # 加载 p10k 主题和配置
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      eval "$(zoxide init zsh)"
    '';
    
    autocd = true;
    setOptions = [ "EXTENDED_GLOB" "HIST_IGNORE_ALL_DUPS" ];
    defaultKeymap = "emacs";
    history = {
      save = 100000;
      share = true;
      path = "$HOME/.zsh_history";
    };
    sessionVariables = {
      MINIMAX_API_KEY="sk-cp-C50uCNVW3BV9M7pxiWz7ugIp2lE3q45yAjlwBAKMO6rRGN0npJ2dmrhHqCkqsqYpKuKgeuOP-uuK-ateDjFCI722SXBJbd2h91rUPGYTIkvBo0iVUu7gWU8";
      # Wayland 环境变量
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
    };
    # 别名
    shellAliases = {
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -lah --icons --git";
      cat = "bat";
      vim = "nvim";
      vi = "nvim";
      nv = "nvim";
    };

  };


  # 现代 CLI 替代工具
  home.packages = with pkgs; [
    zsh-powerlevel10k    # 主题
    eza                  # ls 替代
    bat                  # cat 替代
    fd                   # find 替代
    ripgrep              # grep 替代
    fzf                  # 模糊搜索
    zoxide               # cd 替代
    delta                # git diff 美化
  ];
}