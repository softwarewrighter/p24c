tc24r_include := "~/github/sw-vibe-coding/tc24r/include"

# Compile and run lexer test
test-lexer:
    tc24r tests/test_lexer.c -o tests/test_lexer.s -I {{tc24r_include}} -I src
    cor24-run --run tests/test_lexer.s --speed 0 --time 30

# Compile a test file (no run)
build-lexer:
    tc24r tests/test_lexer.c -o tests/test_lexer.s -I {{tc24r_include}} -I src

# Run all tests
test: test-lexer
