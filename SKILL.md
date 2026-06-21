---
name: plot-neural-net
description: Trigger when the user asks to draw a neural network architecture diagram.
---

Use the bundled library in `scripts/` to write Python code that generates neural network architecture diagrams (PDF).

# Core Rules and Constraints

- **Read-only library**: `scripts/` is the bundled PlotNeuralNet library (`pycore/`, `layers/`, `examples/`). Do not write to or modify it.
- **Artifacts**: Write all user `.py`, `.tex`, and `.pdf` files under `<skill-root>/projects/<project_name>/`. Use a slug for `<project_name>` (lowercase, hyphenated), e.g. `resnet-18`. If `projects/<project_name>/` already exists, append a date suffix, e.g. `resnet-18-20250621`. Derive paths in Python scripts from `__file__`; do not hard-code absolute paths.
- **API usage**: When calling `scripts/` APIs, do not invent parameters. If unsure how to write the code, read [llm.txt](llm.txt).

# Directory Layout

```
<skill-root>/                 # SKILL_ROOT, directory containing this file
├── SKILL.md
├── llm.txt                   # Python API reference
├── scripts/                  # SCRIPTS_DIR, read-only
│   ├── pycore/
│   ├── layers/
│   ├── examples/
│   ├── tikzmake.sh           # Linux / macOS / Git Bash
│   └── tikzmake.ps1          # Windows PowerShell
└── projects/                 # user artifacts; safe to delete entirely for cleanup
    └── <project_name>/
        ├── <project_name>.py
        ├── <project_name>.tex # copied to <output-dir>
        └── <project_name>.pdf # copied to <output-dir>

<output-dir>/
├── <project_name>.tex
└── <project_name>.pdf
```

| Variable | Path |
|----------|------|
| `SKILL_ROOT` | Directory containing `SKILL.md` |
| `SCRIPTS_DIR` | `SKILL_ROOT / "scripts"` |
| `PROJECT_DIR` | `SKILL_ROOT / "projects" / <project_name>` |
| `PROJECT_PATH` | `os.path.relpath(SCRIPTS_DIR, PROJECT_DIR)`, usually `../../scripts` |

# Knowledge Base

When unsure about an API, read [llm.txt](llm.txt) before building `arch`. It covers:

- `tikzeng` layer functions, connection functions, and `to_generate`
- `blocks` composite blocks (`block_2ConvPool`, `block_Unconv`, `block_Res`)
- Layout conventions (positioning, sizing, anchors)

Pure `.tex` examples are in `scripts/examples/`.

# Example Code

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

# Standard Workflow

```
- [ ] 1. Understand the user's architecture (layer types, connections, skip links, size labels). The user may provide text, formulas, etc. Fill in gaps using basic deep learning / neural network knowledge where the description is incomplete.
- [ ] 2. Choose <project_name> and create PROJECT_DIR
- [ ] 3. Write <project_name>.py
- [ ] 4. Choose OUTPUT_DIR for artifacts. Use the user's path if specified; otherwise pick the most suitable location in the workspace.
- [ ] 5. Compile using OUTPUT_DIR from step 4
- [ ] 6. List created/updated file paths
```

**Step 5 — Compile**

Pick the script for your OS (same arguments: `<python_script_path>` `<output_dir>`):

| OS | Command |
|----|---------|
| Windows (PowerShell) | `powershell -ExecutionPolicy Bypass -File "<SKILL_ROOT>/scripts/tikzmake.ps1" "<PROJECT_DIR>/<project_name>.py" "<OUTPUT_DIR>"` |
| Linux / macOS / Git Bash | `bash "<SKILL_ROOT>/scripts/tikzmake.sh" "<PROJECT_DIR>/<project_name>.py" "<OUTPUT_DIR>"` |

The script runs `python` and `pdflatex` in the `.py` directory, removes intermediate files, and copies `.tex` and `.pdf` to `<OUTPUT_DIR>`.

Compilation logs are not printed to the terminal. If the `.tex` file was generated correctly, successful compilation is guaranteed by the correctness of the `scripts/` tooling.

**Step 6 — Wrap up**

Report to the user:

- `<PROJECT_DIR>/<project_name>.py`
- `<OUTPUT_DIR>` contains the `.tex` and `.pdf`
