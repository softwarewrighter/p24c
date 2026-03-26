/* p24p Phase 1 lexer test — exercises all new tokens */

#include <stdio.h>
#include <string.h>
#include "lexer.c"

int errors;

void expect(int expected, char *name) {
    int t;
    t = next_token();
    if (t != expected) {
        printf("FAIL: expected %s got %s\n", name, token_name(t));
        errors = errors + 1;
    }
}

int main() {
    char *src;
    int len;

    errors = 0;

    printf("=== Phase 1 lexer test ===\n");

    /* Test 1: all new keywords */
    src = "procedure function forward type array of record char for to downto repeat until case write read readln";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_PROCEDURE, "PROCEDURE");
    expect(TOK_FUNCTION, "FUNCTION");
    expect(TOK_FORWARD, "FORWARD");
    expect(TOK_TYPE, "TYPE");
    expect(TOK_ARRAY, "ARRAY");
    expect(TOK_OF, "OF");
    expect(TOK_RECORD, "RECORD");
    expect(TOK_CHAR_KW, "CHAR");
    expect(TOK_FOR, "FOR");
    expect(TOK_TO, "TO");
    expect(TOK_DOWNTO, "DOWNTO");
    expect(TOK_REPEAT, "REPEAT");
    expect(TOK_UNTIL, "UNTIL");
    expect(TOK_CASE, "CASE");
    expect(TOK_WRITE, "WRITE");
    expect(TOK_READ, "READ");
    expect(TOK_READLN, "READLN");
    expect(TOK_EOF, "EOF");
    printf("  keywords: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 2: new symbols [ ] .. */
    src = "a[1..10]";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_IDENT, "IDENT");
    expect(TOK_LBRACKET, "LBRACKET");
    expect(TOK_INT_LIT, "INT");
    expect(TOK_DOTDOT, "DOTDOT");
    expect(TOK_INT_LIT, "INT");
    expect(TOK_RBRACKET, "RBRACKET");
    expect(TOK_EOF, "EOF");
    printf("  symbols: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 3: char literal */
    src = "'x'";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_CHAR_LIT, "CHAR_LIT");
    if (tok_int_val != 120) {
        printf("FAIL: char literal value expected 120 got %d\n", tok_int_val);
        errors = errors + 1;
    }
    printf("  char_lit: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 4: string literal */
    src = "'Hello, World!'";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_STR_LIT, "STR_LIT");
    if (tok_str_len != 13) {
        printf("FAIL: string length expected 13 got %d\n", tok_str_len);
        errors = errors + 1;
    }
    if (strcmp(tok_str_val, "Hello, World!") != 0) {
        printf("FAIL: string value expected 'Hello, World!' got '%s'\n", tok_str_val);
        errors = errors + 1;
    }
    printf("  str_lit: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 5: dot vs dotdot disambiguation */
    src = "end.";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_END, "END");
    expect(TOK_DOT, "DOT");
    expect(TOK_EOF, "EOF");
    printf("  dot_vs_dotdot: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 6: case-insensitive keywords */
    src = "Procedure FUNCTION Forward";
    len = strlen(src);
    lexer_init(src, len);

    expect(TOK_PROCEDURE, "PROCEDURE");
    expect(TOK_FUNCTION, "FUNCTION");
    expect(TOK_FORWARD, "FORWARD");
    expect(TOK_EOF, "EOF");
    printf("  case_insensitive: %s\n", errors == 0 ? "PASS" : "FAIL");

    /* Test 7: full Phase 1 program fragment */
    src = "program Test;\ntype\n  IntArray = array[1..10] of integer;\nvar\n  a: IntArray;\nprocedure Swap(var x, y: integer);\nforward;\nbegin\n  for i := 1 to 10 do\n    write(a[i]);\n  repeat\n    readln(a[1])\n  until a[1] = 0;\n  case a[1] of\n    1: writeln('one');\n    2: writeln('AB')\n  end\nend.\n";
    len = strlen(src);
    lexer_init(src, len);

    /* Just tokenize the whole thing and count */
    {
        int count;
        int t;
        count = 0;
        t = next_token();
        while (t != TOK_EOF && t != TOK_ERROR) {
            count = count + 1;
            t = next_token();
        }
        if (t == TOK_ERROR) {
            printf("FAIL: unexpected error token at line %d lexeme='%s'\n", tok_line, tok_lexeme);
            errors = errors + 1;
        }
        printf("  full_program: %d tokens, %s\n", count, errors == 0 ? "PASS" : "FAIL");
    }

    printf("=== %s (%d errors) ===\n", errors == 0 ? "ALL PASS" : "FAILURES", errors);
    return errors != 0;
}
