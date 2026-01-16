{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ========== 基础工具 ==========
    tree          # 目录树显示
    yazi          # 现代化终端文件管理器
    nodejs        # Node.js 运行时
    ripgrep       # 快速文本搜索工具
    net-tools     # 网络工具集
    btop          # 系统监控工具
    claude-code   # Claude Code CLI
    fastfetch     # 系统信息显示

    # ========== C++ 现代开发环境 ==========
    # 编译器工具链
    clang         # Clang 编译器（包含 clang++, clang）
    cmake         # 跨平台构建系统生成器
    ninja         # 快速构建工具

    # C++ 包管理器和依赖管理
    vcpkg         # C++ 包管理器
    xmake         # 跨平台构建工具和包管理器
    ccache        # 编译缓存，加速重复编译

    # 调试和分析工具
    lldb          # LLVM 调试器
    valgrind      # 内存泄漏和性能分析工具

    # 性能分析工具
    perf-tools    # Linux 性能分析工具
    strace        # 系统调用追踪
    ltrace        # 库调用追踪

    # 代码质量和静态分析
    cppcheck      # C++ 静态分析工具
    clang-tools   # 包含 clang-format, clang-tidy, clangd

    # 构建依赖管理
    pkg-config    # 编译时依赖配置工具

    # ========== LSP 服务器（为 Helix 提供自动补全）==========
    nil                    # Nix LSP
    rust-analyzer          # Rust LSP
    python312Packages.python-lsp-server  # Python LSP
    nodePackages.typescript-language-server  # TypeScript/JavaScript LSP
    taplo                  # TOML LSP

    # ========== 格式化工具 ==========
    nixpkgs-fmt           # Nix 格式化器
    black                 # Python 格式化器
    prettierd             # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
  ];
}
