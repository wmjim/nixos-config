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
    impala        # 终端 WiFi 管理工具
    bluetui       # 终端蓝牙管理工具

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

    # ========== Rust 现代开发环境 ==========
    # Rust 工具链
    rustc         # Rust 编译器
    cargo         # Rust 包管理器和构建工具
    rustfmt       # Rust 代码格式化工具

    # Rust 增强工具
    cargo-edit    # cargo 扩展，添加 cargo upgrade 等命令
    cargo-watch   # 自动重新编译和测试
    cargo-audit   # 安全审计工具
    cargo-outdated # 检查依赖更新
    cargo-nextest # 更快的测试运行器

    # Rust 交叉编译工具
    cargo-cross   # 交叉编译工具

    # ========== Python 现代开发环境 ==========
    # Python 解释器
    python313     # Python 3.13 解释器（稳定且依赖完全兼容）

    # 现代 Python 包管理工具
    uv            # 极速 Python 包和项目管理工具（替代 pip/poetry）
    python313Packages.pip  # 传统包管理器（兼容性）

    # Python 开发工具
    python313Packages.virtualenv  # 虚拟环境管理
    python313Packages.black       # 代码格式化工具
    python313Packages.isort       # import 排序工具
    python313Packages.ruff        # 超快速的 Python linter

    # Python 类型检查
    python313Packages.mypy        # 静态类型检查器

    # Python 测试工具
    python313Packages.pytest      # 测试框架
    python313Packages.pytest-cov  # pytest 覆盖率插件
    python313Packages.pytest-asyncio  # 异步测试支持

    # Python 调试工具
    python313Packages.ipdb        # 增强的 Python 调试器

    # 代码质量分析
    python313Packages.pylint      # Python 代码分析工具
    python313Packages.bandit      # 安全漏洞扫描工具

    # 文档生成
    python313Packages.mkdocs      # 现代化文档生成工具
    python313Packages.mkdocs-material  # Material 主题

    # 常用库（可选，开发必备）
    python313Packages.requests    # HTTP 库
    python313Packages.httpx       # 现代异步 HTTP 库
    python313Packages.pydantic    # 数据验证库

    # ========== LSP 服务器（为 Helix 提供自动补全）==========
    nil                    # Nix LSP
    rust-analyzer          # Rust LSP
    python313Packages.python-lsp-server  # Python LSP
    nodePackages.typescript-language-server  # TypeScript/JavaScript LSP
    taplo                  # TOML LSP

    # ========== 格式化工具 ==========
    nixpkgs-fmt           # Nix 格式化器
    black                 # Python 格式化器
    prettierd             # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
  ];
}
