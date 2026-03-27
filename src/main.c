/* p24p — Pascal compiler for COR24 P-Code VM
   UART-input mode: reads Pascal source from stdin until EOT (0x04),
   then compiles and emits .spc to stdout. */

#include <stdio.h>
#include <string.h>
#include "parser.c"

#define INPUT_BUF_SIZE 8192

char input_buf[INPUT_BUF_SIZE];

int main() {
    int ch;
    int len;

    len = 0;
    while (len < INPUT_BUF_SIZE - 1) {
        ch = getchar();
        if (ch == 4 || ch == -1) {
            break;
        }
        input_buf[len] = ch;
        len = len + 1;
    }
    input_buf[len] = 0;

    if (len == 0) {
        printf("; ERROR: no input\n");
        return 1;
    }

    parser_init(input_buf, len);
    parse_program();

    if (parse_error) {
        printf("; COMPILE ERROR\n");
        return 1;
    }

    printf("; OK\n");
    return 0;
}
