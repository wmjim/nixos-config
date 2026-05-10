{ pkgs, ... }:

{
  # Rust 环境
  home.packages = with pkgs; [
    # Rust 工具链
    rustc          # Rust 编译器
    cargo          # Rust 包管理器和构建工具
    rustfmt        # Rust 代码格式化工具

    # Rust 增强工具
    cargo-edit     # cargo 扩展，添加 cargo upgrade 等命令
    cargo-watch    # 自动重新编译和测试
    cargo-audit    # 安全审计工具
    cargo-outdated # 检查依赖更新
    cargo-nextest  # 更快的测试运行器

    # Rust 交叉编译工具
    cargo-cross    # 交叉编译工具
    rust-analyzer  # Rust LSP
  ];
}
