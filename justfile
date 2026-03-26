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

# Run all tests
test: test-lexer test-parser test-codegen test-lexer-phase1
