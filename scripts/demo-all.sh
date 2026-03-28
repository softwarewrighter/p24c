#!/bin/bash
# demo-all.sh — Run all demos with verbose pipeline output
#
# Usage: ./scripts/demo-all.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
P24P_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

for f in "$P24P_DIR"/tests/t*.pas "$P24P_DIR"/tests/hello_str.pas; do
  [ -f "$f" ] || continue
  NAME=$(basename "$f" .pas)
  EXPECT="$P24P_DIR/tests/expected/${NAME}.txt"

  # Skip if no expected output (can't run end-to-end)
  [ -f "$EXPECT" ] || continue

  "$SCRIPT_DIR/demo.sh" "$f"
  echo ""
  echo ""
done
