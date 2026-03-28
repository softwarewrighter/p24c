#include "lexer.c"
#include "parser.h"

/* Forward declarations for recursive descent */
int parse_expression(void);
void parse_stmt(void);
void parse_proc_call(char *name);

/* --- String helpers --- */

void str_copy(char *dst, char *src) {
    int i;
    i = 0;
    while (src[i] != 0) {
        dst[i] = src[i];
        i = i + 1;
    }
    dst[i] = 0;
}

/* --- Error handling --- */

void error(char *msg) {
    printf("error line %d: %s (got %s)\n", tok_line, msg, token_name(tok_type));
    parse_error = 1;
}

void expect(int tok) {
    if (tok_type != tok) {
        printf("error line %d: expected %s, got %s\n",
               tok_line, token_name(tok), token_name(tok_type));
        parse_error = 1;
        return;
    }
    next_token();
}

int accept(int tok) {
    if (tok_type == tok) {
        next_token();
        return 1;
    }
    return 0;
}

/* --- .spc emission --- */

int new_label(void) {
    int l;
    l = label_count;
    label_count = label_count + 1;
    return l;
}

/* --- Symbol table --- */

char *sym_name_at(int i) {
    int off;
    off = i * MAX_NAME;
    return &sym_name[off];
}

char *str_data_at(int i) {
    int off;
    off = i * MAX_STRING_BYTES;
    return &str_data[off];
}

/* --- Procedure table --- */

char *proc_pascal_at(int i) {
    int off;
    off = i * MAX_NAME;
    return &proc_pascal[off];
}

char *proc_extern_at(int i) {
    int off;
    off = i * MAX_NAME;
    return &proc_extern[off];
}

int proc_lookup(char *name) {
    int i;
    i = 0;
    while (i < proc_count) {
        if (strcmp(proc_pascal_at(i), name) == 0) return i;
        i = i + 1;
    }
    return -1;
}

int proc_add(char *pascal_name, char *extern_name, int argc, int has_ret, int ret_type) {
    int idx;
    if (proc_count >= MAX_PROCS) {
        error("too many procedures");
        return -1;
    }
    idx = proc_count;
    str_copy(proc_pascal_at(idx), pascal_name);
    str_copy(proc_extern_at(idx), extern_name);
    proc_argc[idx] = argc;
    proc_has_ret[idx] = has_ret;
    proc_ret_type[idx] = ret_type;
    proc_count = proc_count + 1;
    return idx;
}

void register_system_unit(void) {
    /* Standard functions (return values, used in expressions) */
    /* NOTE: names are lowercase because lexer lowercases identifiers */
    proc_add("abs", "_p24p_abs", 1, 1, TYPE_INTEGER);
    proc_add("odd", "_p24p_odd", 1, 1, TYPE_BOOLEAN);
    proc_add("ord", "_p24p_ord", 1, 1, TYPE_INTEGER);
    proc_add("chr", "_p24p_chr", 1, 1, TYPE_INTEGER);
    proc_add("succ", "_p24p_succ", 1, 1, TYPE_INTEGER);
    proc_add("pred", "_p24p_pred", 1, 1, TYPE_INTEGER);
    proc_add("sqr", "_p24p_sqr", 1, 1, TYPE_INTEGER);
    proc_add("eof", "_p24p_eof", 0, 1, TYPE_BOOLEAN);
    proc_add("eoln", "_p24p_eoln", 0, 1, TYPE_BOOLEAN);
    /* Standard procedures (no return, used as statements) */
    proc_add("readln", "_p24p_read_ln", 0, 0, 0);
    proc_add("writechar", "_p24p_write_char", 1, 0, 0);
}

void register_hardware_unit(void) {
    proc_add("setled", "_p24p_set_led", 1, 0, 0);
    proc_add("readswitch", "_p24p_read_switch", 0, 1, TYPE_INTEGER);
}

/* --- Symbol table --- */

int sym_lookup(char *name) {
    int i;
    i = 0;
    while (i < sym_count) {
        if (strcmp(sym_name_at(i), name) == 0) return i;
        i = i + 1;
    }
    return -1;
}

int sym_add(char *name, int kind, int type, int value) {
    int idx;
    if (sym_lookup(name) >= 0) {
        printf("error line %d: duplicate symbol '%s'\n", tok_line, name);
        parse_error = 1;
        return -1;
    }
    if (sym_count >= MAX_SYMBOLS) {
        error("too many symbols");
        return -1;
    }
    idx = sym_count;
    str_copy(sym_name_at(idx), name);
    sym_kind[idx] = kind;
    sym_type_id[idx] = type;
    sym_value[idx] = value;
    sym_count = sym_count + 1;
    return idx;
}

/* --- Expression parsing (returns type) --- */

int parse_factor(void) {
    int idx;
    int type;
    char name[MAX_NAME];
    char *s;

    if (tok_type == TOK_INT_LIT) {
        printf("    push %d\n", tok_int_val);
        next_token();
        return TYPE_INTEGER;
    }

    if (tok_type == TOK_CHAR_LIT) {
        /* Treat char literal as a 1-char string for write/writeln */
        idx = str_count;
        if (idx >= MAX_STRINGS) {
            error("too many string literals");
            return TYPE_STRING;
        }
        s = str_data_at(idx);
        s[0] = tok_int_val;
        s[1] = 0;
        str_len[idx] = 1;
        str_count = str_count + 1;
        printf("    push S%d\n", idx);
        next_token();
        return TYPE_STRING;
    }

    if (tok_type == TOK_TRUE) {
        printf("    push 1\n");
        next_token();
        return TYPE_BOOLEAN;
    }

    if (tok_type == TOK_FALSE) {
        printf("    push 0\n");
        next_token();
        return TYPE_BOOLEAN;
    }

    if (tok_type == TOK_NOT) {
        next_token();
        type = parse_factor();
        if (type != TYPE_BOOLEAN) error("not requires boolean");
        printf("    push 0\n");
        printf("    eq\n");
        return TYPE_BOOLEAN;
    }

    if (tok_type == TOK_LPAREN) {
        next_token();
        type = parse_expression();
        expect(TOK_RPAREN);
        return type;
    }

    if (tok_type == TOK_STR_LIT) {
        idx = str_count;
        if (idx >= MAX_STRINGS) {
            error("too many string literals");
            return TYPE_STRING;
        }
        str_copy(str_data_at(idx), tok_str_val);
        str_len[idx] = tok_str_len;
        str_count = str_count + 1;
        printf("    push S%d\n", idx);
        next_token();
        return TYPE_STRING;
    }

    if (tok_type == TOK_IDENT) {
        str_copy(name, tok_lexeme);
        next_token();

        /* Check if it's a function call */
        idx = proc_lookup(name);
        if (idx >= 0 && proc_has_ret[idx]) {
            parse_proc_call(name);
            return proc_ret_type[idx];
        }

        /* Variable or constant */
        idx = sym_lookup(name);
        if (idx < 0) {
            printf("error line %d: undeclared '%s'\n", tok_line, name);
            parse_error = 1;
            return TYPE_INTEGER;
        }
        if (sym_kind[idx] == SYM_CONST) {
            printf("    push %d\n", sym_value[idx]);
        } else {
            printf("    loadg %s\n", sym_name_at(idx));
        }
        return sym_type_id[idx];
    }

    error("expected expression");
    return TYPE_INTEGER;
}

int parse_term(void) {
    int type;
    int op;
    int rtype;

    type = parse_factor();

    while (tok_type == TOK_STAR || tok_type == TOK_DIV ||
           tok_type == TOK_MOD || tok_type == TOK_AND) {
        op = tok_type;
        next_token();
        rtype = parse_factor();

        if (op == TOK_STAR) {
            if (type != TYPE_INTEGER || rtype != TYPE_INTEGER)
                error("* requires integers");
            printf("    mul\n");
        } else if (op == TOK_DIV) {
            if (type != TYPE_INTEGER || rtype != TYPE_INTEGER)
                error("div requires integers");
            printf("    div\n");
        } else if (op == TOK_MOD) {
            if (type != TYPE_INTEGER || rtype != TYPE_INTEGER)
                error("mod requires integers");
            printf("    mod\n");
        } else {
            if (type != TYPE_BOOLEAN || rtype != TYPE_BOOLEAN)
                error("and requires booleans");
            printf("    and\n");
            type = TYPE_BOOLEAN;
        }
    }

    return type;
}

int parse_simple_expr(void) {
    int negate;
    int type;
    int op;
    int rtype;

    negate = 0;
    if (tok_type == TOK_PLUS) {
        next_token();
    } else if (tok_type == TOK_MINUS) {
        next_token();
        negate = 1;
    }

    type = parse_term();

    if (negate) {
        if (type != TYPE_INTEGER) error("unary minus requires integer");
        printf("    neg\n");
    }

    while (tok_type == TOK_PLUS || tok_type == TOK_MINUS || tok_type == TOK_OR) {
        op = tok_type;
        next_token();
        rtype = parse_term();

        if (op == TOK_PLUS) {
            if (type != TYPE_INTEGER || rtype != TYPE_INTEGER)
                error("+ requires integers");
            printf("    add\n");
        } else if (op == TOK_MINUS) {
            if (type != TYPE_INTEGER || rtype != TYPE_INTEGER)
                error("- requires integers");
            printf("    sub\n");
        } else {
            if (type != TYPE_BOOLEAN || rtype != TYPE_BOOLEAN)
                error("or requires booleans");
            printf("    or\n");
            type = TYPE_BOOLEAN;
        }
    }

    return type;
}

int parse_expression(void) {
    int type;
    int op;
    int rtype;

    type = parse_simple_expr();

    if (tok_type == TOK_EQ || tok_type == TOK_NEQ ||
        tok_type == TOK_LT || tok_type == TOK_LE ||
        tok_type == TOK_GT || tok_type == TOK_GE) {
        op = tok_type;
        next_token();
        rtype = parse_simple_expr();

        if (type != rtype) error("type mismatch in comparison");

        if (op == TOK_EQ) printf("    eq\n");
        else if (op == TOK_NEQ) printf("    ne\n");
        else if (op == TOK_LT) printf("    lt\n");
        else if (op == TOK_LE) printf("    le\n");
        else if (op == TOK_GT) printf("    gt\n");
        else if (op == TOK_GE) printf("    ge\n");

        return TYPE_BOOLEAN;
    }

    return type;
}

/* --- Statement parsing --- */

void parse_compound_stmt(void) {
    expect(TOK_BEGIN);
    parse_stmt();
    while (tok_type == TOK_SEMI) {
        next_token();
        parse_stmt();
    }
    expect(TOK_END);
}

void parse_if_stmt(void) {
    int type;
    int l_else;
    int l_end;

    next_token(); /* consume IF */
    type = parse_expression();
    if (type != TYPE_BOOLEAN) error("if condition must be boolean");

    l_else = new_label();
    l_end = new_label();

    printf("    jz L%d\n", l_else);

    expect(TOK_THEN);
    parse_stmt();

    if (tok_type == TOK_ELSE) {
        printf("    jmp L%d\n", l_end);
        printf("L%d:\n", l_else);
        next_token();
        parse_stmt();
        printf("L%d:\n", l_end);
    } else {
        printf("L%d:\n", l_else);
    }
}

void parse_while_stmt(void) {
    int type;
    int l_start;
    int l_end;

    next_token(); /* consume WHILE */
    l_start = new_label();
    l_end = new_label();

    printf("L%d:\n", l_start);

    type = parse_expression();
    if (type != TYPE_BOOLEAN) error("while condition must be boolean");

    printf("    jz L%d\n", l_end);

    expect(TOK_DO);
    parse_stmt();

    printf("    jmp L%d\n", l_start);
    printf("L%d:\n", l_end);
}

void parse_for_stmt(void) {
    char name[MAX_NAME];
    int idx;
    int l_start;
    int l_end;
    int downto;

    next_token(); /* consume FOR */

    if (tok_type != TOK_IDENT) {
        error("expected variable after for");
        return;
    }
    str_copy(name, tok_lexeme);
    next_token();

    idx = sym_lookup(name);
    if (idx < 0) {
        printf("error line %d: undeclared '%s'\n", tok_line, name);
        parse_error = 1;
        return;
    }
    if (sym_kind[idx] != SYM_VAR) {
        error("for variable must be a var");
        return;
    }

    expect(TOK_ASSIGN);
    if (parse_error) return;

    parse_expression();
    printf("    storeg %s\n", sym_name_at(idx));

    downto = 0;
    if (tok_type == TOK_DOWNTO) {
        downto = 1;
        next_token();
    } else {
        expect(TOK_TO);
        if (parse_error) return;
    }

    /* limit expression — evaluated each iteration */
    l_start = new_label();
    l_end = new_label();

    printf("L%d:\n", l_start);
    printf("    loadg %s\n", sym_name_at(idx));
    parse_expression();
    if (downto) {
        printf("    ge\n");
    } else {
        printf("    le\n");
    }
    printf("    jz L%d\n", l_end);

    expect(TOK_DO);
    if (parse_error) return;
    parse_stmt();

    /* increment/decrement */
    printf("    loadg %s\n", sym_name_at(idx));
    if (downto) {
        printf("    push 1\n");
        printf("    sub\n");
    } else {
        printf("    push 1\n");
        printf("    add\n");
    }
    printf("    storeg %s\n", sym_name_at(idx));
    printf("    jmp L%d\n", l_start);
    printf("L%d:\n", l_end);
}

void parse_write_stmt(void) {
    int type;

    next_token(); /* consume WRITE */

    if (tok_type == TOK_LPAREN) {
        next_token();

        type = parse_expression();
        if (type == TYPE_STRING) {
            printf("    call _p24p_write_str\n");
        } else if (type == TYPE_BOOLEAN) {
            printf("    call _p24p_write_bool\n");
        } else {
            printf("    call _p24p_write_int\n");
        }

        while (tok_type == TOK_COMMA) {
            next_token();
            type = parse_expression();
            if (type == TYPE_STRING) {
                printf("    call _p24p_write_str\n");
            } else if (type == TYPE_BOOLEAN) {
                printf("    call _p24p_write_bool\n");
            } else {
                printf("    call _p24p_write_int\n");
            }
        }

        expect(TOK_RPAREN);
    }
    /* no call to _p24p_write_ln */
}

void parse_writeln_stmt(void) {
    int type;

    next_token(); /* consume WRITELN */

    if (tok_type == TOK_LPAREN) {
        next_token();

        type = parse_expression();
        if (type == TYPE_STRING) {
            printf("    call _p24p_write_str\n");
        } else if (type == TYPE_BOOLEAN) {
            printf("    call _p24p_write_bool\n");
        } else {
            printf("    call _p24p_write_int\n");
        }

        while (tok_type == TOK_COMMA) {
            next_token();
            type = parse_expression();
            if (type == TYPE_STRING) {
                printf("    call _p24p_write_str\n");
            } else if (type == TYPE_BOOLEAN) {
                printf("    call _p24p_write_bool\n");
            } else {
                printf("    call _p24p_write_int\n");
            }
        }

        expect(TOK_RPAREN);
    }

    printf("    call _p24p_write_ln\n");
}

void parse_proc_call(char *name) {
    int pidx;
    int argc;

    pidx = proc_lookup(name);
    if (pidx < 0) {
        printf("error line %d: unknown procedure '%s'\n", tok_line, name);
        parse_error = 1;
        return;
    }

    argc = 0;
    if (tok_type == TOK_LPAREN) {
        next_token();
        if (tok_type != TOK_RPAREN) {
            parse_expression();
            argc = argc + 1;
            while (tok_type == TOK_COMMA) {
                next_token();
                parse_expression();
                argc = argc + 1;
            }
        }
        expect(TOK_RPAREN);
        if (parse_error) return;
    }

    if (argc != proc_argc[pidx]) {
        printf("error line %d: wrong arg count for %s\n", tok_line, name);
        parse_error = 1;
        return;
    }

    printf("    call %s\n", proc_extern_at(pidx));
}

void parse_stmt(void) {
    char name[MAX_NAME];
    int idx;
    int etype;
    int pidx;

    if (tok_type == TOK_IDENT) {
        str_copy(name, tok_lexeme);
        next_token();

        if (tok_type == TOK_ASSIGN) {
            /* Assignment */
            next_token();

            idx = sym_lookup(name);
            if (idx < 0) {
                printf("error line %d: undeclared '%s'\n", tok_line, name);
                parse_error = 1;
                return;
            }
            if (sym_kind[idx] != SYM_VAR) {
                error("cannot assign to constant");
                return;
            }

            etype = parse_expression();

            if (sym_type_id[idx] != etype) {
                error("type mismatch in assignment");
            }
            printf("    storeg %s\n", sym_name_at(idx));

        } else {
            /* Procedure call */
            parse_proc_call(name);
        }

    } else if (tok_type == TOK_IF) {
        parse_if_stmt();
    } else if (tok_type == TOK_WHILE) {
        parse_while_stmt();
    } else if (tok_type == TOK_FOR) {
        parse_for_stmt();
    } else if (tok_type == TOK_WRITE) {
        parse_write_stmt();
    } else if (tok_type == TOK_WRITELN) {
        parse_writeln_stmt();
    } else if (tok_type == TOK_BEGIN) {
        parse_compound_stmt();
    }
    /* else: empty statement — valid per grammar */
}

/* --- Declaration parsing --- */

void parse_const_def(void) {
    char name[MAX_NAME];
    int value;
    int type;
    int negate;
    int idx;

    if (tok_type != TOK_IDENT) {
        error("expected identifier in const");
        return;
    }
    str_copy(name, tok_lexeme);
    next_token();

    expect(TOK_EQ);
    if (parse_error) return;

    negate = 0;
    if (tok_type == TOK_MINUS) {
        negate = 1;
        next_token();
    } else if (tok_type == TOK_PLUS) {
        next_token();
    }

    if (tok_type == TOK_INT_LIT) {
        value = tok_int_val;
        if (negate) value = 0 - value;
        type = TYPE_INTEGER;
        next_token();
    } else if (tok_type == TOK_TRUE) {
        value = 1;
        type = TYPE_BOOLEAN;
        next_token();
    } else if (tok_type == TOK_FALSE) {
        value = 0;
        type = TYPE_BOOLEAN;
        next_token();
    } else if (tok_type == TOK_IDENT) {
        idx = sym_lookup(tok_lexeme);
        if (idx < 0 || sym_kind[idx] != SYM_CONST) {
            error("expected constant value");
            next_token();
            expect(TOK_SEMI);
            return;
        }
        value = sym_value[idx];
        if (negate) value = 0 - value;
        type = sym_type_id[idx];
        next_token();
    } else {
        error("expected constant value");
        return;
    }

    sym_add(name, SYM_CONST, type, value);
    expect(TOK_SEMI);
}

void parse_const_section(void) {
    next_token(); /* consume CONST */
    parse_const_def();
    while (tok_type == TOK_IDENT && !parse_error) {
        parse_const_def();
    }
}

void parse_var_decl(void) {
    int first;
    int type;
    int i;

    first = sym_count;

    /* First identifier */
    if (tok_type != TOK_IDENT) {
        error("expected identifier in var");
        return;
    }
    sym_add(tok_lexeme, SYM_VAR, TYPE_INTEGER, 0);
    next_token();

    /* More identifiers separated by commas */
    while (tok_type == TOK_COMMA) {
        next_token();
        if (tok_type != TOK_IDENT) {
            error("expected identifier after comma");
            return;
        }
        sym_add(tok_lexeme, SYM_VAR, TYPE_INTEGER, 0);
        next_token();
    }

    expect(TOK_COLON);
    if (parse_error) return;

    /* Type name */
    if (tok_type == TOK_INTEGER_KW) {
        type = TYPE_INTEGER;
        next_token();
    } else if (tok_type == TOK_BOOLEAN_KW) {
        type = TYPE_BOOLEAN;
        next_token();
    } else {
        error("expected type name");
        return;
    }

    expect(TOK_SEMI);

    /* Fix up types and emit .global directives */
    i = first;
    while (i < sym_count) {
        sym_type_id[i] = type;
        printf(".global %s 1\n", sym_name_at(i));
        i = i + 1;
    }
}

void parse_var_section(void) {
    next_token(); /* consume VAR */
    parse_var_decl();
    while (tok_type == TOK_IDENT && !parse_error) {
        parse_var_decl();
    }
}

/* --- Block and program --- */

void parse_block(void) {
    if (tok_type == TOK_CONST) parse_const_section();
    if (tok_type == TOK_VAR) parse_var_section();

    printf("\n.proc main 0\n");
    printf("    enter 0\n");

    parse_compound_stmt();

    printf("    halt\n");
    printf(".end\n");
}

/* --- Public API --- */

void emit_string_data(void) {
    int i;
    int j;
    char *s;

    i = 0;
    while (i < str_count) {
        s = str_data_at(i);
        printf(".data S%d ", i);
        j = 0;
        while (j < str_len[i]) {
            if (j > 0) printf(",");
            printf("%d", s[j]);
            j = j + 1;
        }
        printf(",0\n");
        i = i + 1;
    }
}

void parser_init(char *src, int len) {
    sym_count = 0;
    label_count = 0;
    parse_error = 0;
    str_count = 0;
    proc_count = 0;
    unit_hardware = 0;
    register_system_unit();
    lexer_init(src, len);
    next_token(); /* prime the first token */
}

void parse_uses_clause(void) {
    char unit_name[MAX_NAME];

    next_token(); /* consume USES */

    if (tok_type != TOK_IDENT) {
        error("expected unit name after uses");
        return;
    }

    while (1) {
        str_copy(unit_name, tok_lexeme);
        next_token();

        /* Lexer lowercases identifiers */
        if (strcmp(unit_name, "hardware") == 0) {
            unit_hardware = 1;
            register_hardware_unit();
        } else {
            printf("error line %d: unknown unit '%s'\n", tok_line, unit_name);
            parse_error = 1;
            return;
        }

        if (tok_type != TOK_COMMA) break;
        next_token();
        if (tok_type != TOK_IDENT) {
            error("expected unit name after comma");
            return;
        }
    }

    expect(TOK_SEMI);
}

void emit_externs(void) {
    int i;
    /* Always emit the write/writeln externs (System builtins handled as keywords) */
    printf(".extern _p24p_write_int\n");
    printf(".extern _p24p_write_bool\n");
    printf(".extern _p24p_write_str\n");
    printf(".extern _p24p_write_ln\n");
    /* Emit externs for all registered procedures */
    i = 0;
    while (i < proc_count) {
        printf(".extern %s\n", proc_extern_at(i));
        i = i + 1;
    }
}

void parse_program(void) {
    char prog_name[MAX_NAME];

    expect(TOK_PROGRAM);
    if (parse_error) return;

    str_copy(prog_name, tok_lexeme);
    expect(TOK_IDENT);
    if (parse_error) return;

    expect(TOK_SEMI);
    if (parse_error) return;

    /* Parse optional uses clause */
    if (tok_type == TOK_USES) {
        parse_uses_clause();
        if (parse_error) return;
    }

    printf(".module %s\n", prog_name);
    emit_externs();
    printf(".export main\n");
    printf("; p24p output: %s\n", prog_name);

    parse_block();

    if (str_count > 0) {
        emit_string_data();
    }

    expect(TOK_DOT);

    printf(".endmodule\n");

    if (parse_error) {
        printf("; compilation failed\n");
    }
}
