{ config, pkgs, ... }:

{
  # Wofi 配置
  xdg.configFile."wofi/config".text = ''
    # 显示模式
    mode=drun
    # 大小
    width=450
    height=400
    # 终端
    term=kitty
    # 字体
    font=Maple Mono NF CN 13px
    # 图标主题
    icon-theme=Papirus-Dark
    # 图标大小
    icon-size=28
    # 字段
    fields=name,generic,comment,categories,filename,keywords
    # 过滤
    filter_rate=100
    # 允许镜像
    allow_images=true
    # 允许标记
    allow_markup=true
    # 图标填充
    image_size=28
    # 行数
    rows=8
    # 列数
    columns=1
    # 动态行数
    dynamic_lines=true
    # 隐藏滚动条
    hide_scroll=true
    # 包装
    wrap=true
    # 延迟
    delay=0
    # 无延迟
    no_delay=false
    # 模糊匹配
    fuzzy_match=true
    # 区分大小写
    insensitive=true
    # 多行
    multi_line=false
    # 预览
    pre_display=
    # 显示所有
    show_all=false
    # 显示单列
    single_column=false
    # 去重
    hide_search=false
    # 不显示默认应用标记
    show_default=false
    # 键盘绑定
    key_up=Control_L+Shift_L+Tab
    key_down=Tab
    # 延迟条目
    deferred_entries=
  '';

  xdg.configFile."wofi/style.css".text = ''
    * {
      font-family: "Maple Mono NF CN", "Font Awesome 6 Free", "Material Design Icons", sans-serif;
      font-size: 13px;
      font-weight: 600;
    }

    /* Catppuccin Mocha 主题色 */
    @define-color rosewater #f5e0dc;
    @define-color flamingo #f2cdcd;
    @define-color pink #f5c2e7;
    @define-color mauve #cba6f7;
    @define-color red #f38ba8;
    @define-color maroon #eba0ac;
    @define-color peach #fab387;
    @define-color yellow #f9e2af;
    @define-color green #a6e3a1;
    @define-color teal #94e2d5;
    @define-color sky #89dceb;
    @define-color sapphire #74c7ec;
    @define-color blue #89b4fa;
    @define-color lavender #b4befe;
    @define-color text #cdd6f4;
    @define-color subtext1 #bac2de;
    @define-color subtext0 #a6adc8;
    @define-color overlay2 #9399b2;
    @define-color overlay1 #7f849c;
    @define-color overlay0 #6c7086;
    @define-color surface2 #585b70;
    @define-color surface1 #45475a;
    @define-color surface0 #313244;
    @define-color base #1e1e2e;
    @define-color mantle #181825;
    @define-color crust #11111b;

    window {
      background: transparent;
    }

    #window {
      background: @mantle;
      border: 2px solid @surface0;
      border-radius: 8px;
      padding: 8px;
    }

    #outer-box {
      padding: 0px;
    }

    #input {
      background: @base;
      border: 1px solid @surface0;
      border-radius: 6px;
      color: @text;
      margin: 8px 8px 12px 8px;
      padding: 8px 12px;
      outline: none;
    }

    #input:focus {
      border-color: @lavender;
    }

    #input image {
      color: @lavender;
    }

    #scroll {
      margin: 0px;
    }

    #inner-box {
      margin: 0px;
      border: none;
    }

    #text {
      color: @text;
      margin: 4px 8px;
    }

    #text:selected {
      color: @base;
    }

    #img {
      margin: 4px 8px 4px 4px;
    }

    #entry {
      background: transparent;
      border-radius: 6px;
      margin: 2px 4px;
      padding: 6px 8px;
    }

    #entry:hover {
      background: @surface0;
    }

    #entry:selected {
      background: @lavender;
    }

    #entry:selected #text {
      color: @base;
    }

    #expander {
      margin: 4px 8px;
    }

    #expander:hover {
      color: @lavender;
    }

    #input label {
      color: @overlay1;
    }

    /* 隐藏默认应用标记 */
    #default {
      opacity: 0;
    }

    #entry #default {
      opacity: 0;
    }
  '';
}
