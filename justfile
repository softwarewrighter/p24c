tc24r_include := "~/github/sw-vibe-coding/tc24r/include"

# Compile and run lexer test
test-lexer:
    tc24r tests/test_lexer.c -o tests/test_lexer.s -I {{tc24r_include}} -I src
    cor24-run --run tests/test_lexer.s --speed 0 --time 30

# Compile a test file (no run)
build-lexer:
    tc24r tests/test_lexer.c -o tests/test_lexer.s -I {{tc24r_include}} -I src

# Compile and run parser test
test-parser:
    tc24r tests/test_parser.c -o tests/test_parser.s -I {{tc24r_include}} -I src
    cor24-run --run tests/test_parser.s --speed 0 --time 30

# Compile parser test (no run)
build-parser:
    tc24r tests/test_parser.c -o tests/test_parser.s -I {{tc24r_include}} -I src

# Compile and run codegen test (validates .spc output)
test-codegen:
    tc24r tests/test_codegen.c -o tests/test_codegen.s -I {{tc24r_include}} -I src
    cor24-run --run tests/test_codegen.s --speed 0 --time 30

# Compile codegen test (no run)
build-codegen:
    tc24r tests/test_codegen.c -o tests/test_codegen.s -I {{tc24r_include}} -I src

# Run end-to-end pipeline test (codegen + pasm + pvm)
test-pipeline:
    bash tests/run_pipeline.sh

# Compile and run Phase 1 lexer test
test-lexer-phase1:
    tc24r tests/test_lexer_phase1.c -o tests/test_lexer_phase1.s -I {{tc24r_include}} -I src
    cor24-run --run tests/test_lexer_phase1.s --speed 0 --time 30

# Build p24p compiler (UART-input mode)
build:
    tc24r src/main.c -o p24p.s -I {{tc24r_include}} -I src

# Run p24p compiler with a Pascal file via UART
run file:
    printf '%s\x04' "$(cat {{file}})" | cor24-run --run p24p.s --terminal --speed 0 --time 30

# Run all unit tests (lexer, parser, codegen)
test: test-lexer test-parser test-codegen test-lexer-phase1

# Run end-to-end regression tests (compile + link + assemble + run, check expected output)
test-e2e:
    bash scripts/test-all.sh

# Demo one Pascal program with full pipeline visibility
demo file:
    bash scripts/demo.sh {{file}}

# Demo all Pascal programs
demo-all:
    bash scripts/demo-all.sh

# Demo LED on/off programs (checks I/O dump)
demo-led:
    bash scripts/demo-led.sh
