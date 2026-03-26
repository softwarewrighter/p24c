#pragma once

/* p24p Phase 0 Lexer — tokenizes Pascal source from a char buffer */

#define MAX_LEXEME 64

/* Token types */
#define TOK_PROGRAM    0
#define TOK_CONST      1
#define TOK_VAR        2
#define TOK_BEGIN      3
#define TOK_END        4
#define TOK_IF         5
#define TOK_THEN       6
#define TOK_ELSE       7
#define TOK_WHILE      8
#define TOK_DO         9
#define TOK_WRITELN    10
#define TOK_INTEGER_KW 11
#define TOK_BOOLEAN_KW 12
#define TOK_TRUE       13
#define TOK_FALSE      14
#define TOK_DIV        15
#define TOK_MOD        16
#define TOK_AND        17
#define TOK_OR         18
#define TOK_NOT        19
/* Symbols */
#define TOK_ASSIGN     20
#define TOK_SEMI       21
#define TOK_DOT        22
#define TOK_COMMA      23
#define TOK_LPAREN     24
#define TOK_RPAREN     25
#define TOK_PLUS       26
#define TOK_MINUS      27
#define TOK_STAR       28
#define TOK_EQ         29
#define TOK_NEQ        30
#define TOK_LT         31
#define TOK_LE         32
#define TOK_GT         33
#define TOK_GE         34
#define TOK_COLON      35
/* Literals */
#define TOK_IDENT      36
#define TOK_INT_LIT    37
/* Special */
#define TOK_EOF        38
#define TOK_ERROR      39

/* Current token state — set by next_token() */
int tok_type;
int tok_line;
int tok_int_val;
char tok_lexeme[MAX_LEXEME];

/* Lexer source state */
char *lex_src;
int lex_pos;
int lex_len;
int lex_line;

/* Initialize lexer with source buffer and its length */
void lexer_init(char *src, int len);

/* Advance to next token. Returns token type. */
int next_token(void);

/* Return printable name for a token type */
char *token_name(int type);
