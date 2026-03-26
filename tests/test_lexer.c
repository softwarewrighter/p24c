/* p24p lexer test — tokenizes a small Pascal program and prints each token */

#include <stdio.h>
#include <string.h>
#include "lexer.c"

int main() {
    char *src = "program Countdown;\nconst\n  start = 10;\nvar\n  n: integer;\n  done: boolean;\nbegin\n  n := start;\n  done := false;\n  { this is a comment }\n  while not done do\n  begin\n    writeln(n);\n    n := n - 1;\n    if n = 0 then\n      done := true\n  end;\n  (* another comment style *)\n  if n <> 5 then\n    writeln(n)\nend.\n";

    int len = strlen(src);
    int t;

    printf("=== p24p lexer test ===\n");
    lexer_init(src, len);

    t = next_token();
    while (t != TOK_EOF) {
        printf("%d %s %s\n", tok_line, token_name(t), tok_lexeme);
        t = next_token();
    }
    printf("%d %s\n", tok_line, token_name(t));
    printf("=== done ===\n");

    return 0;
}
