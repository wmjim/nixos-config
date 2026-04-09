{ pkgs, ... }:

{
  # Python 环境
  home.packages = with pkgs; [
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

    # LSP 服务器
    python313Packages.python-lsp-server  # Python LSP

    # 格式化工具
    black                 # Python 格式化器
  ];
}
