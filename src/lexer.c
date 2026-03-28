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
    /* Phase 1 keywords */
    if (strcmp(id, "procedure") == 0) return TOK_PROCEDURE;
    if (strcmp(id, "function") == 0) return TOK_FUNCTION;
    if (strcmp(id, "forward") == 0) return TOK_FORWARD;
    if (strcmp(id, "type") == 0) return TOK_TYPE;
    if (strcmp(id, "array") == 0) return TOK_ARRAY;
    if (strcmp(id, "of") == 0) return TOK_OF;
    if (strcmp(id, "record") == 0) return TOK_RECORD;
    if (strcmp(id, "char") == 0) return TOK_CHAR_KW;
    if (strcmp(id, "for") == 0) return TOK_FOR;
    if (strcmp(id, "to") == 0) return TOK_TO;
    if (strcmp(id, "downto") == 0) return TOK_DOWNTO;
    if (strcmp(id, "repeat") == 0) return TOK_REPEAT;
    if (strcmp(id, "until") == 0) return TOK_UNTIL;
    if (strcmp(id, "case") == 0) return TOK_CASE;
    if (strcmp(id, "write") == 0) return TOK_WRITE;
    if (strcmp(id, "read") == 0) return TOK_READ;
    if (strcmp(id, "readln") == 0) return TOK_READLN;
    if (strcmp(id, "uses") == 0) return TOK_USES;
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
    tok_str_val[0] = 0;
    tok_str_len = 0;
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

    /* String and char literals: 'x' is char, 'abc' is string */
    if (c == 39) {
        int si;
        lex_advance(); /* skip opening quote */
        si = 0;
        while (lex_pos < lex_len && lex_src[lex_pos] != 39) {
            if (si < MAX_STRING - 1) {
                tok_str_val[si] = lex_src[lex_pos];
                si = si + 1;
            }
            lex_pos = lex_pos + 1;
        }
        tok_str_val[si] = 0;
        tok_str_len = si;
        if (lex_pos < lex_len) lex_advance(); /* skip closing quote */
        if (si == 1) {
            /* char literal */
            tok_int_val = tok_str_val[0];
            tok_lexeme[0] = tok_str_val[0];
            tok_lexeme[1] = 0;
            tok_type = TOK_CHAR_LIT;
            return TOK_CHAR_LIT;
        }
        /* string literal */
        i = 0;
        while (i < si && i < MAX_LEXEME - 1) {
            tok_lexeme[i] = tok_str_val[i];
            i = i + 1;
        }
        tok_lexeme[i] = 0;
        tok_type = TOK_STR_LIT;
        return TOK_STR_LIT;
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
    if (c == '.') {
        if (lex_pos < lex_len && lex_src[lex_pos] == '.') {
            lex_advance();
            tok_lexeme[0] = '.';
            tok_lexeme[1] = '.';
            tok_lexeme[2] = 0;
            tok_type = TOK_DOTDOT;
            return TOK_DOTDOT;
        }
        tok_lexeme[0] = '.';
        tok_lexeme[1] = 0;
        tok_type = TOK_DOT;
        return TOK_DOT;
    }
    if (c == ',') { tok_lexeme[0] = ','; tok_lexeme[1] = 0; tok_type = TOK_COMMA; return TOK_COMMA; }
    if (c == '(') { tok_lexeme[0] = '('; tok_lexeme[1] = 0; tok_type = TOK_LPAREN; return TOK_LPAREN; }
    if (c == ')') { tok_lexeme[0] = ')'; tok_lexeme[1] = 0; tok_type = TOK_RPAREN; return TOK_RPAREN; }
    if (c == '+') { tok_lexeme[0] = '+'; tok_lexeme[1] = 0; tok_type = TOK_PLUS; return TOK_PLUS; }
    if (c == '-') { tok_lexeme[0] = '-'; tok_lexeme[1] = 0; tok_type = TOK_MINUS; return TOK_MINUS; }
    if (c == '*') { tok_lexeme[0] = '*'; tok_lexeme[1] = 0; tok_type = TOK_STAR; return TOK_STAR; }
    if (c == '=') { tok_lexeme[0] = '='; tok_lexeme[1] = 0; tok_type = TOK_EQ; return TOK_EQ; }
    if (c == '[') { tok_lexeme[0] = '['; tok_lexeme[1] = 0; tok_type = TOK_LBRACKET; return TOK_LBRACKET; }
    if (c == ']') { tok_lexeme[0] = ']'; tok_lexeme[1] = 0; tok_type = TOK_RBRACKET; return TOK_RBRACKET; }

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
    if (type == TOK_PROCEDURE) return "PROCEDURE";
    if (type == TOK_FUNCTION) return "FUNCTION";
    if (type == TOK_FORWARD) return "FORWARD";
    if (type == TOK_TYPE) return "TYPE";
    if (type == TOK_ARRAY) return "ARRAY";
    if (type == TOK_OF) return "OF";
    if (type == TOK_RECORD) return "RECORD";
    if (type == TOK_CHAR_KW) return "CHAR";
    if (type == TOK_FOR) return "FOR";
    if (type == TOK_TO) return "TO";
    if (type == TOK_DOWNTO) return "DOWNTO";
    if (type == TOK_REPEAT) return "REPEAT";
    if (type == TOK_UNTIL) return "UNTIL";
    if (type == TOK_CASE) return "CASE";
    if (type == TOK_WRITE) return "WRITE";
    if (type == TOK_READ) return "READ";
    if (type == TOK_READLN) return "READLN";
    if (type == TOK_LBRACKET) return "LBRACKET";
    if (type == TOK_RBRACKET) return "RBRACKET";
    if (type == TOK_DOTDOT) return "DOTDOT";
    if (type == TOK_CHAR_LIT) return "CHAR_LIT";
    if (type == TOK_STR_LIT) return "STR_LIT";
    if (type == TOK_USES) return "USES";
    if (type == TOK_EOF) return "EOF";
    return "ERROR";
}
