#!/bin/bash
# End-to-end pipeline test for p24p codegen
# Tests: (1) .spc generation, (2) pasm assembly of a small program, (3) pvm execution

set -euo pipefail

PASM=~/github/sw-vibe-coding/pv24a/pasm.s
PVM=~/github/sw-vibe-coding/pv24a/pvm.s
TC24R_INCLUDE=~/github/sw-vibe-coding/tc24r/include
WORKDIR=$(mktemp -d)

trap "rm -rf $WORKDIR" EXIT

echo "=== Test 1: Compile Countdown to .spc ==="
tc24r tests/test_codegen.c -o "$WORKDIR/test_codegen.s" -I "$TC24R_INCLUDE" -I src
SPC_RAW=$(cor24-run --run "$WORKDIR/test_codegen.s" --speed 0 --time 30 2>&1)
SPC=$(echo "$SPC_RAW" | sed -n '/^UART output: /,$ { s/^UART output: //; /^Executed/d; /^CPU/d; /^$/d; p; }')

if echo "$SPC" | grep -q "; COMPILE ERROR"; then
    echo "FAIL: Compiler reported error"
    echo "$SPC"
    exit 1
fi

# Validate key .spc constructs
PASS=1
check() {
    if ! echo "$SPC" | grep -q "$1"; then
        echo "FAIL: expected '$1' in .spc output"
        PASS=0
    fi
}

check ".module countdown"
check ".extern _p24p_write_int"
check ".extern _p24p_write_ln"
check ".export main"
check ".endmodule"
check ".global n 1"
check ".global done 1"
check ".proc main 0"
check "enter 0"
check "push 10"
check "storeg n"
check "storeg done"
check "loadg done"
check "jz L1"
check "call _p24p_write_int"
check "call _p24p_write_ln"
check "jmp L0"
check "halt"
check ".end"
check "; OK"

if [ $PASS -eq 1 ]; then
    echo "PASSED: .spc output contains all expected constructs"
else
    echo "Generated .spc:"
    echo "$SPC"
    exit 1
fi

echo ""
echo "=== Test 2: Assemble minimal .spc with pasm ==="
# Tiny program that fits in pasm's 160-byte input buffer.
# Prints "A\n" (65 = 'A', 10 = '\n')
printf '.proc main 0\nenter 0\npush 65\nsys 1\npush 10\nsys 1\nhalt\n.end\n\x04' | \
    cor24-run --run "$PASM" --terminal --speed 0 --time 30 -n 50000000 2>&1 > "$WORKDIR/pasm_out.txt"

if grep -q "DONE" "$WORKDIR/pasm_out.txt"; then
    BYTECODE=$(grep "CODE " "$WORKDIR/pasm_out.txt" | sed 's/^CODE //')
    echo "PASSED: pasm assembled $(echo $BYTECODE | wc -w) bytes"
else
    echo "FAIL: pasm did not complete"
    cat "$WORKDIR/pasm_out.txt"
    exit 1
fi

echo ""
echo "=== Test 3: Execute bytecode on pvm ==="
echo "$BYTECODE" > "$WORKDIR/bytecode.txt"
python3 tests/patch_pvm.py "$WORKDIR" "$PVM"

PVM_OUT=$(cor24-run --run "$WORKDIR/pvm_test.s" --speed 0 --time 10 -n 5000000 --dump 2>&1)

if echo "$PVM_OUT" | grep -q "Assembly errors"; then
    echo "FAIL: VM assembly errors"
    echo "$PVM_OUT" | head -5
    exit 1
fi

# Extract full UART TX log from --dump output
TX_LOG=$(echo "$PVM_OUT" | grep "UART TX log:" | sed 's/.*UART TX log: *"//' | sed 's/"$//')

if echo "$TX_LOG" | grep -q 'A'; then
    echo "PASSED: pvm executed and printed 'A' (TX log: $TX_LOG)"
else
    echo "FAIL: expected 'A' in TX log, got: [$TX_LOG]"
    exit 1
fi

echo ""
echo "=== All pipeline tests PASSED ==="
echo "Note: Full end-to-end (compiler .spc -> pasm -> pvm) requires"
echo "pasm input buffer >160 bytes. Filed as known issue."
