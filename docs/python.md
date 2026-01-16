# Python 开发环境配置指南

## 📦 已安装工具

### 核心工具
- **Python 3.13** - 最新稳定版 Python 解释器
- **uv** - 极速 Python 包和项目管理工具（推荐）
- **pip** - 传统 Python 包管理器（兼容性）

### 开发工具
- **virtualenv** - 虚拟环境管理
- **black** - Python 代码格式化工具
- **isort** - import 排序工具
- **ruff** - 超快速的 Python linter（替代 flake8/pylint）
- **mypy** - 静态类型检查器

### 测试工具
- **pytest** - 测试框架
- **pytest-cov** - pytest 覆盖率插件
- **pytest-asyncio** - 异步测试支持

### 调试工具
- **ipdb** - 增强的 Python 调试器
- **pdbpp** - 现代化 Python 调试器

### 代码质量
- **pylint** - Python 代码分析工具
- **bandit** - 安全漏洞扫描工具

### 文档工具
- **mkdocs** - 现代化文档生成工具
- **mkdocs-material** - Material 主题

### LSP 服务器
- **python-lsp-server** - 为 Helix 提供代码补全和智能提示

## 🚀 快速开始

### 使用 uv（推荐）

#### 创建新项目

```bash
# 创建新项目
uv init my_project

# 进入项目目录
cd my_project

# 创建虚拟环境并安装依赖
uv sync

# 运行脚本
uv run python main.py

# 添加依赖
uv add requests

# 添加开发依赖
uv add --dev pytest ruff

# 运行测试
uv run pytest

# 移除依赖
uv remove requests
```

#### 从现有项目创建

```bash
# 初始化项目
uv init

# 从 requirements.txt 安装
uv pip install -r requirements.txt

# 或从 pyproject.toml 安装
uv sync
```

### 使用传统方式

#### 创建虚拟环境

```bash
# 使用 venv
python3.13 -m venv .venv
source .venv/bin/activate

# 或使用 virtualenv
virtualenv .venv
source .venv/bin/activate
```

#### 管理依赖

```bash
# 安装包
pip install requests

# 生成 requirements.txt
pip freeze > requirements.txt

# 从 requirements.txt 安装
pip install -r requirements.txt

# 卸载包
pip uninstall requests
```

## 📝 项目结构

### 使用 uv 的现代项目结构

```
my_project/
├── .python-version      # Python 版本
├── pyproject.toml       # 项目配置
├── uv.lock              # 依赖锁定文件
├── src/
│   └── my_project/
│       ├── __init__.py
│       └── main.py
└── tests/
    ├── __init__.py
    └── test_main.py
```

### pyproject.toml 示例

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "My awesome project"
requires-python = ">=3.13"
dependencies = [
    "requests>=2.31.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.1.0",
    "mypy>=1.5.0",
]

[project.scripts]
my-app = "my_project.main:cli"

[tool.ruff]
line-length = 100
target-version = "py313"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
ignore = ["E501"]

[tool.black]
line-length = 100
target-version = ["py313"]

[tool.isort]
profile = "black"
line_length = 100

[tool.mypy]
python_version = "3.13"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "--cov=my_project --cov-report=html"
```

## 🔧 代码质量工具

### Ruff（超快速 linter）

```bash
# 检查代码
uv run ruff check .

# 自动修复问题
uv run ruff check --fix .

# 显示所有规则
uv run ruff rule --all
```

### Black（代码格式化）

```bash
# 格式化代码
uv run black .

# 检查格式（不修改）
uv run black --check .

# 只显示需要修改的文件
uv run black --diff .
```

### isort（import 排序）

```bash
# 排序 imports
uv run isort .

# 检查 import 顺序
uv run isort --check-only .
```

### mypy（类型检查）

```bash
# 类型检查
uv run mypy .

# 显示错误代码
uv run mypy --show-error-codes .

# 生成 HTML 报告
uv run mypy --html-report ./mypy-report .
```

### Bandit（安全扫描）

```bash
# 安全扫描
uv run bandit -r .

# 只显示高危问题
uv run bandit -r . -lll
```

## 🧪 测试

### pytest 基础

```bash
# 运行所有测试
uv run pytest

# 运行特定文件
uv run pytest tests/test_main.py

# 运行特定测试
uv run pytest tests/test_main.py::test_function

# 显示详细输出
uv run pytest -v

# 显示打印输出
uv run pytest -s

# 在第一个失败时停止
uv run pytest -x

# 运行覆盖率
uv run pytest --cov=my_project --cov-report=html

# 运行标记的测试
uv run pytest -m slow
```

### 编写测试

```python
# tests/test_main.py
import pytest
from my_project import main

@pytest.fixture
def sample_data():
    return {"key": "value"}

def test_function(sample_data):
    assert sample_data["key"] == "value"

@pytest.mark.asyncio
async def test_async_function():
    # 异步测试
    result = await async_function()
    assert result is not None

@pytest.mark.slow
def test_slow_operation():
    # 标记为慢速测试
    assert True
```

## 🐛 调试

### 使用 ipdb

```python
# 在代码中设置断点
import ipdb; ipdb.set_trace()

# 或使用条件断点
if condition:
    import ipdb; ipdb.set_trace()
```

### 使用 pdbpp

```bash
# 使用 pdbpp 运行脚本
uv run python -m pdbpp main.py

# 或在代码中
import pdb; pdb.set_trace()
```

### 常用调试命令

```bash
# n (next) - 执行下一行
# s (step) - 进入函数
# c (continue) - 继续执行
# p variable - 打印变量
# pp variable - 美化打印变量
# l (list) - 显示代码
# w (where) - 显示堆栈
# q (quit) - 退出调试器
```

## 📚 常用库推荐

### Web 框架

```bash
# FastAPI（现代异步框架）
uv add fastapi uvicorn

# Flask（轻量级框架）
uv add flask

# Django（全功能框架）
uv add django
```

### 数据科学

```bash
# NumPy（数值计算）
uv add numpy

# Pandas（数据分析）
uv add pandas

# Matplotlib（绘图）
uv add matplotlib

# Jupyter（交互式开发）
uv add jupyter
```

### 异步编程

```bash
# 异步 HTTP
uv add httpx aiohttp

# 异步数据库
uv add sqlalchemy[asyncio] asyncpg
```

### CLI 工具

```bash
# Typer（现代化 CLI 工具）
uv add typer

# Click（传统 CLI 工具）
uv add click

# Rich（终端美化）
uv add rich
```

## 🎯 开发工作流

### 1. 项目初始化

```bash
# 创建项目
uv init my_project
cd my_project

# 创建虚拟环境
uv venv

# 激活虚拟环境
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows
```

### 2. 开发阶段

```bash
# 添加依赖
uv add requests pydantic

# 添加开发依赖
uv add --dev pytest ruff mypy

# 运行代码
uv run python main.py

# 代码检查
uv run ruff check .
uv run mypy .
uv run black --check .
```

### 3. 测试

```bash
# 运行测试
uv run pytest

# 运行覆盖率
uv run pytest --cov=my_project --cov-report=html

# 查看覆盖率报告
xdg-open htmlcov/index.html
```

### 4. 代码格式化

```bash
# 格式化代码
uv run black .
uv run isort .

# 或使用 ruff（同时格式化和 lint）
uv run ruff check --fix .
```

## 🔗 Helix 编辑器

Python LSP (`python-lsp-server`) 已配置，在 Helix 中：
- 自动补全：`Ctrl-X` 然后输入
- 跳转到定义：`Ctrl-]`
- 查找引用：`Shift-]`
- 显示类型：`K`
- 重命名符号：`F2`

## 📖 学习资源

### 官方文档
- [Python 官方文档](https://docs.python.org/zh-cn/3.13/)
- [uv 官方文档](https://docs.astral.sh/uv/)
- [pytest 文档](https://docs.pytest.org/)
- [FastAPI 教程](https://fastapi.tiangolo.com/zh/)

### 中文资源
- [Python 中文教程](https://www.liaoxuefeng.com/wiki/1016959663602400)
- [Real Python 中文](https://realpython.com.cn/)
- [Python 进阶](https://python.usyiyi.cn/translate/python_cookbook_3rd_edition/index.html)

### 最佳实践
- [Python 代码风格指南](https://pep8.cn/)
- [Python 类型提示](https://docs.python.org/zh-cn/3/library/typing.html)
- [Effective Python](https://effective-python.com/)

## 🎯 最佳实践

1. **使用 uv 管理项目** - 比 pip 快 10-100 倍
2. **虚拟环境隔离** - 每个项目独立环境
3. **类型提示** - 使用 mypy 进行静态检查
4. **编写测试** - pytest 测试覆盖率 > 80%
5. **代码格式化** - 使用 black 和 ruff
6. **安全扫描** - 定期运行 bandit
7. **文档注释** - 使用 docstrings
8. **依赖管理** - 定期更新依赖 `uv lock --upgrade`

## 🔗 相关配置

- [Rust 开发环境](./rust.md) - Rust 开发环境配置
- [C++ 开发环境](./cpp.md) - C++ 开发环境配置
- [Helix 配置](../helix.md) - Helix 编辑器配置
- [开发工具](./devel.md) - 通用开发工具
