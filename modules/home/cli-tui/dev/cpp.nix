{ pkgs, lib, ... }:

{
  # C/C++ 开发环境
  home.packages = with pkgs; [
    # 编译器工具链（只用 clang，避免与 gcc 冲突）
    clang # c/c++ lsp
    cmake # 跨平台构建系统生成器
    cmake-language-server # cmake lsp
    gnumake
    ninja # 快速构建工具

    # C++ 包管理器和依赖管理
    vcpkg # C++ 包管理器
    xmake # 跨平台构建工具和包管理器
    ccache # 编译缓存，加速重复编译

    # 调试和分析工具
    lldb # LLVM 调试器
    valgrind # 内存泄漏和性能分析工具

    # 代码质量和静态分析
    cppcheck # C++ 静态分析工具
    clang-tools # 包含 clang-format, clang-tidy, clangd

    # 构建依赖管理
    pkg-config # 编译时依赖配置工具
  ] ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    # Linux 专属性能分析工具
    perf-tools # Linux 性能分析工具
    strace # 系统调用追踪
    ltrace # 库调用追踪
  ]);
}
