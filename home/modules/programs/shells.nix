{
  programs.bash = {
    enable = true;

    shellAliases = {
      c2p = "code2prompt . --clipboard";
    };

    initExtra = ''
      eval "$(starship init bash)"
    '';
  };

  programs.zsh = {
    enable = true;

    initContent = ''
      eval "$(starship init zsh)"
    '';
  };
}
