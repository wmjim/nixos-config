# Dolphin 文件管理器配置
{ ... }:

{
  xdg.configFile."dolphinrc" = {
    text = ''
      [General]
      AutoExpandFolders=false
      GlobalViewProps=true
      HomeUrl=file:///home/mengw
      OpenExternallyCalledFolderInNewTab=true
      RememberOpenedTabs=true
      ShowFullPathInTitlebar=true
      ShowSpaceInfo=true
      UseTabForSwitchingSplit=false
      ShowTerminalPanel=false
      TerminalApplication=ghostty
    '';
    force = true;
  };
}
