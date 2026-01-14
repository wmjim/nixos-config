# Clash Verge Rev 配置指南

## 简介

Clash Verge Rev 是一个基于 Tauri 的 Clash 图形化客户端,支持:
- ✅ 图形化界面管理订阅
- ✅ 规则编辑器
- ✅ 代理分组
- ✅ TUN 模式(全局代理)
- ✅ 实时流量监控
- ✅ 订阅自动更新

## 快速开始

### 1. 启用 Clash Verge Rev 模块

在 `home/common/default.nix` 中添加:

```nix
imports = [
  ./terminal.nix
  ./editors.nix
  ./devel.nix
  ./shell.nix
  ./helix.nix
  ./clash.nix  # 添加这一行
];
```

### 2. 重建系统

```bash
sudo nixos-rebuild switch --flake /home/mengw/nixos-config#nixos
```

### 3. 启动 Clash Verge Rev

在 Hyprland 中:
- 按 `SUPER + D` 打开应用启动器
- 搜索 `clash-verge` 或 `Clash Verge`
- 回车启动

或者在终端中:
```bash
clash-verge
```

## 配置步骤

### 1. 导入订阅

首次启动后:

1. **点击左侧"配置文件"(Profiles)标签**
2. **点击"新建"(New)或"导入"(Import)**
3. **粘贴你的订阅链接**:
   ```
   https://your-provider.com/link/your-token
   ```
4. **点击"下载"**
5. **选择刚导入的配置**,点击"启用"

### 2. 配置 TUN 模式(推荐)

TUN 模式可以实现真正的全局代理:

1. **点击左侧"设置"(Settings)**
2. **找到"TUN 模式"部分**
3. **启用以下选项**:
   - ✅ 启用 TUN 模式
   - ✅ 自动路由
   - ✅ 自动配置 DNS
   - ✅ DNS 直接使用(可选)

4. **应用设置**

### 3. 设置系统代理

#### 方法 1: 通过 Clash Verge Rev 设置

1. **点击左侧"设置"(Settings)**
2. **找到"系统代理"部分**
3. **启用"开启系统代理"**
4. **端口设置**(默认):
   - HTTP: 7890
   - SOCKS5: 7891

#### 方法 2: 手动设置环境变量

在 `~/.config/fish/config.fish` 中添加:

```fish
# 代理开关
function proxy-on
    set -gx http_proxy http://127.0.0.1:7890
    set -gx https_proxy http://127.0.0.1:7890
    set -gx all_proxy socks5://127.0.0.1:7891
    set -gx no_proxy localhost,127.0.0.1,::1
    echo "✅ Proxy enabled"
end

function proxy-off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e no_proxy
    echo "❌ Proxy disabled"
end

function proxy-test
    curl -I https://www.google.com
end
```

使用:
```bash
proxy-on    # 启用代理
proxy-off   # 禁用代理
proxy-test  # 测试连接
```

### 4. 配置开机自启

在 Clash Verge Rev 中:

1. **点击左侧"设置"(Settings)**
2. **找到"杂项"(Misc)部分**
3. **启用"开机自启"(Auto Start)**
4. **启用"静默启动"(Start Minimized)**

### 5. 配置规则

Clash Verge Rev 内置了常用规则,你也可以自定义:

1. **点击左侧"规则"(Rules)**
2. **查看当前规则列表**
3. **可以添加自定义规则**,例如:
   ```
   DOMAIN,example.com,DIRECT
   IP-CIDR,192.168.1.0/24,DIRECT
   DOMAIN-SUFFIX,google.com,Proxy
   ```

## 高级配置

### 1. 订阅增强配置

编辑订阅配置,添加以下内容以获得更好的体验:

```yaml
# 在订阅 URL 后添加参数
https://your-provider.com/link?target=clash&new_name=true

# 或在配置文件中添加:
rules:
  # 国内直连
  - GEOIP,CN,DIRECT
  - DOMAIN-SUFFIX,cn,DIRECT
  # 代理
  - MATCH,Proxy
```

### 2. 分流配置

在 `~/.config/clash-verge/config/` 中编辑配置文件:

```yaml
rules:
  # 局域网直连
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,127.0.0.0/8,DIRECT

  # 常见服务直连
  - DOMAIN-SUFFIX,cn,DIRECT
  - DOMAIN-KEYWORD,baidu,DIRECT
  - DOMAIN-KEYWORD,taobao,DIRECT
  - DOMAIN-KEYWORD,alipay,DIRECT
  - DOMAIN-KEYWORD,tmall,DIRECT
  - DOMAIN-KEYWORD,jingdong,DIRECT

  # 广告拦截
  - DOMAIN-SUFFIX,ad.com,REJECT
  - DOMAIN-KEYWORD,ad,REJECT

  # 国外网站代理
  - DOMAIN-SUFFIX,google.com,Proxy
  - DOMAIN-SUFFIX,youtube.com,Proxy
  - DOMAIN-SUFFIX,github.com,Proxy
  - DOMAIN-SUFFIX,openai.com,Proxy

  # 其他
  - MATCH,Proxy
```

### 3. TUN 模式权限配置(可选)

如果 TUN 模式无法启动,在 NixOS 配置中添加:

```nix
# nixos/configuration.nix
security.wrappers = {
  clash-verge = {
    source = "${pkgs.clash-verge-rev}/bin/clash-verge";
    capabilities = "cap_net_admin+ep";
    owner = "root";
    group = "root";
  };
};

# 或者将用户添加到 network 组
users.users.mengw.extraGroups = [ "wheel" "audio" "video" "input" "network" ];
```

然后运行:
```bash
sudo setcap cap_net_admin+ep $(which clash-verge)
```

## 故障排查

### 1. TUN 模式无法启动

**症状**: 启用 TUN 模式后报错

**解决方案**:
```bash
# 检查权限
ip link show

# 手动设置权限
sudo setcap cap_net_admin+ep ~/.nix-profile/bin/clash-verge

# 或使用 fakeroot 方式(不支持 TUN)
# 在设置中关闭 TUN,使用系统代理模式
```

### 2. 订阅更新失败

**症状**: 无法更新订阅

**解决方案**:
1. 检查网络连接
2. 检查订阅链接是否正确
3. 尝试手动下载订阅:
```bash
curl -o config.yaml "https://your-provider.com/link"
```

### 3. 速度慢

**解决方案**:
1. **选择更快的节点**: 在左侧"代理"(Proxies)中切换
2. **启用延迟测试**: 点击节点的"测试"按钮
3. **使用自动选择组**: 选择支持自动选择的组
4. **检查本地网络**: `speedtest-cli`

### 4. DNS 泄露

**解决方案**:
1. **启用 Clash DNS**:
   - 设置 → DNS → 启用"远程 DNS"
   - DNS 服务器: `https://1.1.1.1/dns-query`

2. **启用 Fake-IP**:
   - 设置 → TUN → 启用"Fake-IP"

## 管理界面

Clash Verge Rev 提供了内置的管理面板:

- **API 地址**: http://127.0.0.1:9090
- **UI**: yacd (在设置中可配置)

访问方法:
1. 安装 yacd:
```bash
git clone https://github.com/haishanh/yacd.git ~/.config/clash-verge/yacd
```

2. 在浏览器中打开: `http://127.0.0.1:9090/ui`

## 命令行操作

```bash
# 查看版本
clash-verge --version

# 查看日志
journalctl --user -u clash-verge -f

# 重启服务
systemctl --user restart clash-verge

# 检查连接
curl -x http://127.0.0.1:7890 https://api.ipify.org

# 测试 DNS
dig @127.0.0.1 -p 53 google.com
```

## 与 sing-box 的选择

### Clash Verge Rev 优势
- ✅ 图形化界面,操作简单
- ✅ 内置订阅管理
- ✅ 实时流量监控
- ✅ 规则编辑器
- ✅ 适合桌面用户

### sing-box 优势
- ✅ 更轻量,无 GUI
- ✅ 配置更灵活
- ✅ 性能略优
- ✅ 适合服务器或高级用户

## 参考资源

- [Clash Verge Rev GitHub](https://github.com/clash-verge-rev/clash-verge-rev)
- [Clash 文档](https://wiki.metacubex.one/)
- [NixOS Clash Wiki](https://nixos.wiki/wiki/Clash)
