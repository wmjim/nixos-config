# GNOME 桌面

GNOME 相关配置：`modules/nixos/desktop/gnome/default.nix`（系统级）+ `modules/home-manager/gui/themes/default.nix`（扩展与主题）。

- **desktop**：GNOME 与 Niri 共存，默认登录 Niri 会话
- **laptop**：GNOME 为默认登录会话（`defaultSession = "gnome"`）

GNOME 已禁用 core-apps / games，仅保留核心组件，应用由 Home Manager 单独管理。

## 已启用的扩展

### 外观与美化

- **Blur my Shell**：顶栏、概览等界面添加毛玻璃模糊
- **Just Perfection**：高度自定义 Shell 外观与行为
- **ArcMenu**：顶栏应用菜单（类开始菜单）
- **Dash to Panel**：Dash 与顶栏整合成类 Windows 任务栏
- **Rounded Window Corners**：为窗口添加圆角
- **User Themes**：加载自定义 Shell 主题（当前为 MacTahoe-Light）

### 窗口与工作区

- **Tiling Shell**：窗口平铺与分屏增强
- **Compiz-alike Magic Lamp Effect**：窗口关闭时的"神灯"动画
- **Coverflow Alt-Tab**：Alt+Tab 横向 3D 滚动切换

### 系统与实用工具

- **AppIndicator**：传统应用托盘图标支持（微信、QQ、Steam 等）
- **Kimpanel**：输入法面板（配合 Fcitx5 使用）
- **Clipboard Indicator**：剪贴板历史管理
- **Removable Drive Menu**：可移动设备快速挂载 / 弹出

## 主题

| 项目 | 主题 |
|------|------|
| GNOME Shell / GTK | MacTahoe-Light |
| 图标 | MacTahoe-dark |
| 光标 | Bibata-Modern-Classic |

> 启用扩展的 UUID 列表在 `themes/default.nix` 的 `dconf.settings` 中维护，新增扩展时注意同步。

## 常用命令

```bash
# 图形化扩展管理
gnome-extensions-app

# 列出已启用的扩展
gnome-extensions list --enabled
```
