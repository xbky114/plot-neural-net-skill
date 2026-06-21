#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <python_script_path> <output_dir>" >&2
    exit 1
fi

PYTHON_SCRIPT="$1"
OUTPUT_DIR="$2"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Python script not found: $PYTHON_SCRIPT" >&2
    exit 1
fi

WORKDIR="$(cd "$(dirname "$PYTHON_SCRIPT")" && pwd)"
BASENAME="$(basename "$PYTHON_SCRIPT" .py)"
SCRIPT_NAME="$(basename "$PYTHON_SCRIPT")"

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

cd "$WORKDIR"

python "$SCRIPT_NAME"
pdflatex -interaction=nonstopmode "${BASENAME}.tex" > /dev/null

rm -f ./*.aux ./*.log ./*.vscodeLog

cp -f "${BASENAME}.tex" "${BASENAME}.pdf" "$OUTPUT_DIR/"

echo "Success! Output saved to ${OUTPUT_DIR}/${BASENAME}.pdf"
