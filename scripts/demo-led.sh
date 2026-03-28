#!/bin/bash
# demo-led.sh — Demonstrate LED control from Pascal
# Shows: source → compile → link → assemble → run → LED state in dump
#
# Usage: ./scripts/demo-led.sh
set -euo pipefail

P24P_DIR="$(cd "$(dirname "$0")/.." && pwd)"
P24P_S="$P24P_DIR/p24p.s"
PL24R="$HOME/github/softwarewrighter/pl24r/target/release/pl24r"
PA24R="$HOME/github/softwarewrighter/pa24r/target/release/pa24r"
RUNTIME="$HOME/github/softwarewrighter/pr24p/src/runtime.spc"
PVM="$HOME/github/sw-vibe-coding/pv24a/pvm.s"

TMP="/tmp/p24p_led_$$"
mkdir -p "$TMP"
trap "rm -rf $TMP" EXIT

printf '\x00\x00\x01' > "$TMP/code_ptr.bin"

for f in "$P24P_DIR"/tests/led_on.pas "$P24P_DIR"/tests/led_off.pas; do
  [ -f "$f" ] || continue
  NAME=$(basename "$f" .pas)

  echo "════════════════════════════════════════════════════════"
  echo "  LED Demo: $NAME"
  echo "════════════════════════════════════════════════════════"
  echo ""

  echo "--- Source ---"
  cat "$f"
  echo ""

  # Compile
  SPC_OUTPUT=$(printf '%s\x04' "$(cat "$f")" | \
    cor24-run --run "$P24P_S" --terminal --speed 0 -n 5000000 2>&1)

  if ! echo "$SPC_OUTPUT" | grep -q "; OK"; then
    echo "  COMPILE FAILED"
    echo "$SPC_OUTPUT" | grep "error" | sed 's/^/  /'
    continue
  fi

  SPC=$(echo "$SPC_OUTPUT" | sed -n '/^\.module/,/^\.endmodule/p')
  echo "$SPC" > "$TMP/$NAME.spc"
  echo "--- Generated .spc ---"
  echo "$SPC" | sed -n '/^\.proc/,/^\.end/p'
  echo ""

  # Link + assemble + relocate
  "$PL24R" "$RUNTIME" "$TMP/$NAME.spc" -o "$TMP/${NAME}_linked.spc" 2>/dev/null
  "$PA24R" "$TMP/${NAME}_linked.spc" -o "$TMP/$NAME.p24" 2>/dev/null
  python3 /tmp/relocate_p24.py "$TMP/$NAME.p24" 0x010000 >/dev/null 2>&1

  # Run with dump
  EXEC_OUTPUT=$(cor24-run --run "$PVM" \
    --load-binary "$TMP/$NAME.bin@0x010000" \
    --load-binary "$TMP/code_ptr.bin@0x09DC" \
    --dump --speed 0 -n 50000000 2>&1)

  INSTRS=$(echo "$EXEC_OUTPUT" | grep -oE 'Executed [0-9]+' | grep -oE '[0-9]+')
  HALTED=$(echo "$EXEC_OUTPUT" | grep -c 'CPU halted' || true)

  echo "--- Hardware State ---"
  echo "$EXEC_OUTPUT" | grep -E '^\s*(LED D2|BTN S2):' | sed 's/^/  /'
  echo ""
  echo "--- Stats ---"
  echo "  VM instructions: $INSTRS"
  if [ "$HALTED" -eq 1 ]; then
    echo "  Status: HALT (clean exit)"
  else
    echo "  Status: DID NOT HALT"
  fi
  echo ""
done

echo "NOTE: LED D2 is active-low. SetLED(0) = LED on, SetLED(1) = LED off."
echo "NOTE: If both show same state, pvm.s sys 3 may write to wrong I/O address (REQ-026)."
