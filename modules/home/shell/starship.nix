# Starship 提示符配置
{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = "🌱 ";
      };
      golang = {
        symbol = "🐹 ";
      };
      rust = {
        symbol = "🦀 ";
      };
      nodejs = {
        symbol = "⬢ ";
      };
      python = {
        symbol = "🐍 ";
      };
    };
  };
}
