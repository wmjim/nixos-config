{ config, pkgs, ... }:

{
  # home.packages = with pkgs; [ helix ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "meng.wang";
      user.email = "meng.w1016@outlook.com";
      init.defaultBranch = "main";
      core.editor = "hx";
    };
  };
}
