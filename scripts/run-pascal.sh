#!/bin/bash
# run-pascal.sh — Compile and run a Pascal program through the full p24p toolchain
# Usage: ./scripts/run-pascal.sh <file.pas> [max_instructions]
#
# Pipeline: .pas → p24p → .spc → pl24r → pa24r → .p24 → pvm.s
set -euo pipefail

PAS="${1:?Usage: $0 <file.pas> [max_instructions]}"
MAX_INSTRS="${2:-50000000}"

# Tool paths
P24P_DIR="$(cd "$(dirname "$0")/.." && pwd)"
P24P_S="$P24P_DIR/p24p.s"
PL24R="$HOME/github/softwarewrighter/pl24r/target/release/pl24r"
PA24R="$HOME/github/softwarewrighter/pa24r/target/release/pa24r"
RUNTIME="$HOME/github/softwarewrighter/pr24p/src/runtime.spc"
PVM="$HOME/github/sw-vibe-coding/pv24a/pvm.s"

NAME=$(basename "$PAS" .pas)
TMP="/tmp/p24p_$$"
mkdir -p "$TMP"
trap "rm -rf $TMP" EXIT

# Step 1: Compile Pascal to .spc
SPC_OUTPUT=$(printf '%s\x04' "$(cat "$PAS")" | \
  cor24-run --run "$P24P_S" --terminal --speed 0 -n 5000000 2>&1)

if ! echo "$SPC_OUTPUT" | grep -q "; OK"; then
  echo "Compilation failed:" >&2
  echo "$SPC_OUTPUT" | grep "error" >&2
  exit 1
fi

echo "$SPC_OUTPUT" | sed -n '/^\.module/,/^\.endmodule/p' > "$TMP/$NAME.spc"

# Step 2: Link with runtime
"$PL24R" "$RUNTIME" "$TMP/$NAME.spc" -o "$TMP/${NAME}_linked.spc" 2>/dev/null

# Step 3: Assemble to .p24
"$PA24R" "$TMP/${NAME}_linked.spc" -o "$TMP/$NAME.p24" 2>/dev/null

# Step 4: Relocate for load address 0x010000
python3 /tmp/relocate_p24.py "$TMP/$NAME.p24" 0x010000 >/dev/null

# Step 5: Create code_ptr patch (0x010000 LE)
printf '\x00\x00\x01' > "$TMP/code_ptr.bin"

# Step 6: Run on PVM
cor24-run --run "$PVM" \
  --load-binary "$TMP/$NAME.bin@0x010000" \
  --load-binary "$TMP/code_ptr.bin@0x0A0F" \
  --terminal --speed 0 -n "$MAX_INSTRS" 2>&1 | \
  grep -v '^\[' | grep -v '^Assembled' | grep -v '^Running' | \
  grep -v '^Executed' | grep -v '^Loaded' | grep -v '^PVM OK' | \
  grep -v '^$' | grep -v '^HALT$'
