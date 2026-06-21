# plot-neural-net

A [Cursor Agent Skill](SKILL.md) that generates neural-network architecture diagrams (PDF) via Python.

scripts/ contains upstream code comes from **[PlotNeuralNet](https://github.com/HarisIqbal88/PlotNeuralNet)** (MIT). 

## What this skill add / changes

| Piece | Role |
|-------|------|
| `SKILL.md` | Agent workflow and constraints |
| `llm.txt` | Python API reference for agents |
| `projects/` | artifacts path |
| `scripts/tikzmake.sh` | Run Python + `pdflatex`, copy outputs to a chosen directory |
| `scripts/tikzmake.ps1` | Same on Windows PowerShell |


## Prerequisites

- Python 3
- A LaTeX install with `pdflatex`

## License

PlotNeuralNet core is MIT — see `scripts/LICENSE`. Skill metadata and docs in this repo root are separate from upstream.
