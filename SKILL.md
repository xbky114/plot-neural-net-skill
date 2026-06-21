---
name: plot-neural-net
description: 当用户要求画神经网络示意图任务时触发。
---

调用 scripts/ 的库，编写python代码，生成神经网络架构示意图（PDF）。

# 核心规则与约束

- **只读库**：`scripts/` 为 PlotNeuralNet 捆绑库（`pycore/`、`layers/`、`examples/`），禁止写入或修改。
- **产物**：所有用户 `.py`、`.tex`、`.pdf` 写在 `<skill-root>/projects/<project_name>/`。`<project_name>` 用 slug（小写、连字符），如 `resnet-18`。若 `projects/<project_name>/` 已存在，加日期后缀，如 `resnet-18-20250621`。python脚本的路径从 `__file__` 推导，不写死绝对路径。
- **接口调用**：在调用scripts/的脚本的时候，禁止编造参数。如果你不知道如何编写，查看[llm.txt](llm.txt).

# 目录结构

```
<skill-root>/                 # SKILL_ROOT，本文件所在目录
├── SKILL.md
├── llm.txt                   # Python API 参考
├── scripts/                  # SCRIPTS_DIR，只读
│   ├── pycore/
│   ├── layers/
│   ├── examples/
│   ├── tikzmake.sh           # Linux / macOS / Git Bash
│   └── tikzmake.ps1          # Windows PowerShell
└── projects/                 # 用户产物，可整体删除清理
    └── <project_name>/
        ├── <project_name>.py
        ├── <project_name>.tex # 会被复制到 <output-dir>
        └── <project_name>.pdf # 会被复制到 <output-dir>

<output-dir>/
├── <project_name>.tex
└── <project_name>.pdf
```

| 变量 | 路径 |
|------|------|
| `SKILL_ROOT` | 含 `SKILL.md` 的目录 |
| `SCRIPTS_DIR` | `SKILL_ROOT / "scripts"` |
| `PROJECT_DIR` | `SKILL_ROOT / "projects" / <project_name>` |
| `PROJECT_PATH` | `os.path.relpath(SCRIPTS_DIR, PROJECT_DIR)`，通常 `../../scripts` |

# 知识库

当你对某些接口不确定，编写 `arch` 前读取 [llm.txt](llm.txt)，包含：

- `tikzeng` 层函数、连接函数、`to_generate`
- `blocks` 复合块（`block_2ConvPool`、`block_Unconv`、`block_Res`）
- 布局约定（定位、尺寸、锚点）

纯 `.tex` 参考见 `scripts/examples/`。

# 示例代码

```python
import os
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent
SKILL_ROOT = PROJECT_DIR.parent.parent
SCRIPTS_DIR = SKILL_ROOT / "scripts"
PROJECT_PATH = os.path.relpath(SCRIPTS_DIR, PROJECT_DIR)

sys.path.insert(0, str(SCRIPTS_DIR))
from pycore.tikzeng import *

arch = [
    to_head(PROJECT_PATH),
    to_cor(),
    to_begin(),
    to_Conv("conv1", 512, 64, offset="(0,0,0)", to="(0,0,0)", height=64, depth=64, width=2 ),
    to_Pool("pool1", offset="(0,0,0)", to="(conv1-east)"),
    to_Conv("conv2", 128, 64, offset="(1,0,0)", to="(pool1-east)", height=32, depth=32, width=2 ),
    to_connection( "pool1", "conv2"),
    to_Pool("pool2", offset="(0,0,0)", to="(conv2-east)", height=28, depth=28, width=1),
    to_SoftMax("soft1", 10 ,"(3,0,0)", "(pool1-east)", caption="SOFT"  ),
    to_connection("pool2", "soft1"),
    to_end()
    ]

def main():
    to_generate(arch, str(PROJECT_DIR / f"{Path(__file__).stem}.tex"))

if __name__ == '__main__':
    main()
```

# 标准流程

```
- [ ] 1. 理解用户架构（层类型、连接、skip、尺寸标注）。用户可能提供文字描述，公式描述等。如果某些地方用户描述不完全清楚，使用对深度学习和神经网络的基本理解来补全。
- [ ] 2. 确定 <project_name>，创建 PROJECT_DIR
- [ ] 3. 写入 <project_name>.py
- [ ] 4. 确定产物的输出路径OUTPUT_DIR。如果用户制定了输出位置，则按照用户要求，否则选为用户工作区中最合适的位置。
- [ ] 5. 编译。使用上一步确定的OUTPUT_DIR
- [ ] 6. 列出创建/更新的文件路径
```

**Step 5 — 编译**

按系统选择脚本（参数相同：`<python_script_path>` `<output_dir>`）：

| 系统 | 命令 |
|------|------|
| Windows（PowerShell） | `powershell -ExecutionPolicy Bypass -File "<SKILL_ROOT>/scripts/tikzmake.ps1" "<PROJECT_DIR>/<project_name>.py" "<OUTPUT_DIR>"` |
| Linux / macOS / Git Bash | `bash "<SKILL_ROOT>/scripts/tikzmake.sh" "<PROJECT_DIR>/<project_name>.py" "<OUTPUT_DIR>"` |

脚本在 `.py` 所在目录运行 `python` 与 `pdflatex`，删除中间产物，将 `.tex` 与 `.pdf` 复制到 `<OUTPUT_DIR>`。

编译日志不会打印到终端。假设.tex文件已经正常生成，那么编译的成功会由scripts/脚本的正确性保证。

**Step 6 — 收尾**

向用户报告：

- `<PROJECT_DIR>/<project_name>.py`
- `<OUTPUT_DIR>` 存放了.tex和.pdf
