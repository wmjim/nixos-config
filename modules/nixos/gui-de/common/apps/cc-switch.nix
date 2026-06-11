# cc-switch — AI 管理工具 (Tauri v2)
# Tauri v2 在 Linux 上通过 GTK CSS Provider (APPLICATION 优先级) 注入自定义标题栏样式，
# 覆盖了系统 Adwaita 主题。用 GTK Module 在 USER 优先级注入 CSS 覆盖回来。
{ pkgs, ... }:
let
  gtkModule = pkgs.stdenv.mkDerivation {
    name = "cc-switch-gtk-module";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.gtk3 ];
    dontUnpack = true;
    buildPhase = ''
      cat > cc-switch-gtk-module.c << 'CEOF'
      #include <gtk/gtk.h>

      G_MODULE_EXPORT void gtk_module_init(gint *argc, gchar ***argv) {
        GtkCssProvider *provider = gtk_css_provider_new();
        GError *error = NULL;
        const gchar *css =
          "headerbar {"
          "  background-color: @theme_bg_color;"
          "  background-image: none;"
          "  color: @theme_fg_color;"
          "  border-bottom: none;"
          "  box-shadow: none;"
          "}"
          "headerbar:backdrop {"
          "  background-color: @theme_unfocused_bg_color;"
          "}"
          ".titlebar {"
          "  background-color: @theme_bg_color;"
          "  background-image: none;"
          "  color: @theme_fg_color;"
          "  border-bottom: none;"
          "  box-shadow: none;"
          "}"
          ".titlebar:backdrop {"
          "  background-color: @theme_unfocused_bg_color;"
          "}";

        gtk_css_provider_load_from_data(provider, css, -1, &error);
        if (error) {
          g_warning("cc-switch-gtk-module: CSS parse error: %s", error->message);
          g_error_free(error);
          g_object_unref(provider);
          return;
        }

        gtk_style_context_add_provider_for_screen(
          gdk_screen_get_default(),
          GTK_STYLE_PROVIDER(provider),
          GTK_STYLE_PROVIDER_PRIORITY_USER
        );
        g_object_unref(provider);
      }
      CEOF

      $CC -shared -fPIC \
        $(pkg-config --cflags gtk+-3.0) \
        -o cc-switch-gtk-module.so \
        cc-switch-gtk-module.c \
        $(pkg-config --libs gtk+-3.0)
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp cc-switch-gtk-module.so $out/lib/
    '';
  };

  wrapper = pkgs.symlinkJoin {
    name = "cc-switch";
    paths = [ pkgs.cc-switch ];
    postBuild = ''
      rm $out/bin/cc-switch
      cp ${pkgs.writeShellScript "cc-switch" ''
        export GTK_MODULES="${gtkModule}/lib/cc-switch-gtk-module.so''${GTK_MODULES:+,$GTK_MODULES}"
        exec ${pkgs.cc-switch}/bin/cc-switch "$@"
      ''} $out/bin/cc-switch
    '';
  };
in {
  environment.systemPackages = [ wrapper ];
}
