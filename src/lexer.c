#include "lexer.h"

/* Character classification helpers */

int lex_is_alpha(int c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

int lex_is_digit(int c) {
    return c >= '0' && c <= '9';
}

int lex_to_lower(int c) {
    if (c >= 'A' && c <= 'Z') return c + 32;
    return c;
}

/* Source navigation */

int lex_peek(void) {
    if (lex_pos >= lex_len) return 0;
    return lex_src[lex_pos];
}

int lex_advance(void) {
    if (lex_pos >= lex_len) return 0;
    int c = lex_src[lex_pos];
    lex_pos = lex_pos + 1;
    if (c == 10) lex_line = lex_line + 1;
    return c;
}

/* Skip whitespace and comments */

void lex_skip_ws(void) {
    while (lex_pos < lex_len) {
        int c = lex_src[lex_pos];

        if (c == ' ' || c == 9 || c == 13 || c == 10) {
            lex_advance();
        } else if (c == '{') {
            /* { } comment */
            lex_advance();
            while (lex_pos < lex_len && lex_src[lex_pos] != '}') {
                lex_advance();
            }
            if (lex_pos < lex_len) lex_advance();
        } else if (c == '(' && lex_pos + 1 < lex_len && lex_src[lex_pos + 1] == '*') {
            /* (* *) comment */
            lex_advance();
            lex_advance();
            while (lex_pos + 1 < lex_len) {
                if (lex_src[lex_pos] == '*' && lex_src[lex_pos + 1] == ')') {
                    lex_advance();
                    lex_advance();
                    break;
                }
                lex_advance();
            }
        } else {
            break;
        }
    }
}

/* Keyword lookup — returns keyword token or TOK_IDENT */

int lex_keyword(char *id) {
    if (strcmp(id, "program") == 0) return TOK_PROGRAM;
    if (strcmp(id, "const") == 0) return TOK_CONST;
    if (strcmp(id, "var") == 0) return TOK_VAR;
    if (strcmp(id, "begin") == 0) return TOK_BEGIN;
    if (strcmp(id, "end") == 0) return TOK_END;
    if (strcmp(id, "if") == 0) return TOK_IF;
    if (strcmp(id, "then") == 0) return TOK_THEN;
    if (strcmp(id, "else") == 0) return TOK_ELSE;
    if (strcmp(id, "while") == 0) return TOK_WHILE;
    if (strcmp(id, "do") == 0) return TOK_DO;
    if (strcmp(id, "writeln") == 0) return TOK_WRITELN;
    if (strcmp(id, "integer") == 0) return TOK_INTEGER_KW;
    if (strcmp(id, "boolean") == 0) return TOK_BOOLEAN_KW;
    if (strcmp(id, "true") == 0) return TOK_TRUE;
    if (strcmp(id, "false") == 0) return TOK_FALSE;
    if (strcmp(id, "div") == 0) return TOK_DIV;
    if (strcmp(id, "mod") == 0) return TOK_MOD;
    if (strcmp(id, "and") == 0) return TOK_AND;
    if (strcmp(id, "or") == 0) return TOK_OR;
    if (strcmp(id, "not") == 0) return TOK_NOT;
    return TOK_IDENT;
}

/* Public API */

void lexer_init(char *src, int len) {
    lex_src = src;
    lex_pos = 0;
    lex_len = len;
    lex_line = 1;
    tok_type = TOK_EOF;
    tok_line = 1;
    tok_int_val = 0;
    tok_lexeme[0] = 0;
}

int next_token(void) {
    int c;
    int i;

    lex_skip_ws();

    tok_line = lex_line;
    tok_lexeme[0] = 0;

    if (lex_pos >= lex_len) {
        tok_type = TOK_EOF;
        return TOK_EOF;
    }

    c = lex_src[lex_pos];

    /* Identifiers and keywords */
    if (lex_is_alpha(c)) {
        i = 0;
        while (lex_pos < lex_len && (lex_is_alpha(lex_src[lex_pos]) || lex_is_digit(lex_src[lex_pos]))) {
            if (i < MAX_LEXEME - 1) {
                tok_lexeme[i] = lex_to_lower(lex_src[lex_pos]);
                i = i + 1;
            }
            lex_pos = lex_pos + 1;
        }
        tok_lexeme[i] = 0;
        tok_type = lex_keyword(tok_lexeme);
        return tok_type;
    }

    /* Integer literals */
    if (lex_is_digit(c)) {
        i = 0;
        tok_int_val = 0;
        while (lex_pos < lex_len && lex_is_digit(lex_src[lex_pos])) {
            if (i < MAX_LEXEME - 1) {
                tok_lexeme[i] = lex_src[lex_pos];
                i = i + 1;
            }
            tok_int_val = tok_int_val * 10 + (lex_src[lex_pos] - '0');
            lex_pos = lex_pos + 1;
        }
        tok_lexeme[i] = 0;
        tok_type = TOK_INT_LIT;
        return TOK_INT_LIT;
    }

    /* Symbols — consume first char */
    lex_advance();

    if (c == ':') {
        if (lex_pos < lex_len && lex_src[lex_pos] == '=') {
            lex_advance();
            tok_lexeme[0] = ':';
            tok_lexeme[1] = '=';
            tok_lexeme[2] = 0;
            tok_type = TOK_ASSIGN;
            return TOK_ASSIGN;
        }
        tok_lexeme[0] = ':';
        tok_lexeme[1] = 0;
        tok_type = TOK_COLON;
        return TOK_COLON;
    }
    if (c == '<') {
        if (lex_pos < lex_len && lex_src[lex_pos] == '>') {
            lex_advance();
            tok_lexeme[0] = '<';
            tok_lexeme[1] = '>';
            tok_lexeme[2] = 0;
            tok_type = TOK_NEQ;
            return TOK_NEQ;
        }
        if (lex_pos < lex_len && lex_src[lex_pos] == '=') {
            lex_advance();
            tok_lexeme[0] = '<';
            tok_lexeme[1] = '=';
            tok_lexeme[2] = 0;
            tok_type = TOK_LE;
            return TOK_LE;
        }
        tok_lexeme[0] = '<';
        tok_lexeme[1] = 0;
        tok_type = TOK_LT;
        return TOK_LT;
    }
    if (c == '>') {
        if (lex_pos < lex_len && lex_src[lex_pos] == '=') {
            lex_advance();
            tok_lexeme[0] = '>';
            tok_lexeme[1] = '=';
            tok_lexeme[2] = 0;
            tok_type = TOK_GE;
            return TOK_GE;
        }
        tok_lexeme[0] = '>';
        tok_lexeme[1] = 0;
        tok_type = TOK_GT;
        return TOK_GT;
    }
    if (c == ';') { tok_lexeme[0] = ';'; tok_lexeme[1] = 0; tok_type = TOK_SEMI; return TOK_SEMI; }
    if (c == '.') { tok_lexeme[0] = '.'; tok_lexeme[1] = 0; tok_type = TOK_DOT; return TOK_DOT; }
    if (c == ',') { tok_lexeme[0] = ','; tok_lexeme[1] = 0; tok_type = TOK_COMMA; return TOK_COMMA; }
    if (c == '(') { tok_lexeme[0] = '('; tok_lexeme[1] = 0; tok_type = TOK_LPAREN; return TOK_LPAREN; }
    if (c == ')') { tok_lexeme[0] = ')'; tok_lexeme[1] = 0; tok_type = TOK_RPAREN; return TOK_RPAREN; }
    if (c == '+') { tok_lexeme[0] = '+'; tok_lexeme[1] = 0; tok_type = TOK_PLUS; return TOK_PLUS; }
    if (c == '-') { tok_lexeme[0] = '-'; tok_lexeme[1] = 0; tok_type = TOK_MINUS; return TOK_MINUS; }
    if (c == '*') { tok_lexeme[0] = '*'; tok_lexeme[1] = 0; tok_type = TOK_STAR; return TOK_STAR; }
    if (c == '=') { tok_lexeme[0] = '='; tok_lexeme[1] = 0; tok_type = TOK_EQ; return TOK_EQ; }

    /* Unknown character */
    tok_lexeme[0] = c;
    tok_lexeme[1] = 0;
    tok_type = TOK_ERROR;
    return TOK_ERROR;
}

char *token_name(int type) {
    if (type == TOK_PROGRAM) return "PROGRAM";
    if (type == TOK_CONST) return "CONST";
    if (type == TOK_VAR) return "VAR";
    if (type == TOK_BEGIN) return "BEGIN";
    if (type == TOK_END) return "END";
    if (type == TOK_IF) return "IF";
    if (type == TOK_THEN) return "THEN";
    if (type == TOK_ELSE) return "ELSE";
    if (type == TOK_WHILE) return "WHILE";
    if (type == TOK_DO) return "DO";
    if (type == TOK_WRITELN) return "WRITELN";
    if (type == TOK_INTEGER_KW) return "INTEGER";
    if (type == TOK_BOOLEAN_KW) return "BOOLEAN";
    if (type == TOK_TRUE) return "TRUE";
    if (type == TOK_FALSE) return "FALSE";
    if (type == TOK_DIV) return "DIV";
    if (type == TOK_MOD) return "MOD";
    if (type == TOK_AND) return "AND";
    if (type == TOK_OR) return "OR";
    if (type == TOK_NOT) return "NOT";
    if (type == TOK_ASSIGN) return "ASSIGN";
    if (type == TOK_SEMI) return "SEMI";
    if (type == TOK_DOT) return "DOT";
    if (type == TOK_COMMA) return "COMMA";
    if (type == TOK_LPAREN) return "LPAREN";
    if (type == TOK_RPAREN) return "RPAREN";
    if (type == TOK_PLUS) return "PLUS";
    if (type == TOK_MINUS) return "MINUS";
    if (type == TOK_STAR) return "STAR";
    if (type == TOK_EQ) return "EQ";
    if (type == TOK_NEQ) return "NEQ";
    if (type == TOK_LT) return "LT";
    if (type == TOK_LE) return "LE";
    if (type == TOK_GT) return "GT";
    if (type == TOK_GE) return "GE";
    if (type == TOK_COLON) return "COLON";
    if (type == TOK_IDENT) return "IDENT";
    if (type == TOK_INT_LIT) return "INT";
    if (type == TOK_EOF) return "EOF";
    return "ERROR";
}
