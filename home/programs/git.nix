{ config, pkgs, ... }:

{

  programs.git = {
    enable = true;
    settings = {
      user.name = "meng.wang";
      user.email = "meng.w1016@outlook.com";
      init.defaultBranch = "main";
      core.editor = "hx";
      http.proxy = "http://127.0.0.1:7897";
      https.proxy = "http://127.0.0.1:7897";
    };
  };
}
