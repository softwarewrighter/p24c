#pragma once

/* p24p Phase 0 Parser — recursive descent, emits .spc directly */

/* Type kinds */
#define TYPE_INTEGER 0
#define TYPE_BOOLEAN 1
#define TYPE_STRING  2

/* Symbol kinds */
#define SYM_CONST 0
#define SYM_VAR   1

/* Symbol table limits */
#define MAX_SYMBOLS 64
#define MAX_NAME 32
#define SYM_NAME_SIZE 2048

/* Symbol table — parallel arrays (avoids tc24r struct array bugs) */
char sym_name[SYM_NAME_SIZE];
int sym_kind[MAX_SYMBOLS];
int sym_type_id[MAX_SYMBOLS];
int sym_value[MAX_SYMBOLS];
int sym_count;

/* Label counter */
int label_count;

/* String literal table */
#define MAX_STRINGS 16
#define MAX_STRING_BYTES 256
#define STR_DATA_SIZE 4096
char str_data[STR_DATA_SIZE];
int str_len[MAX_STRINGS];
int str_count;

/* External procedure table */
#define MAX_PROCS 32
#define PROC_NAME_SIZE 1024
char proc_pascal[PROC_NAME_SIZE];
char proc_extern[PROC_NAME_SIZE];
int proc_argc[MAX_PROCS];
int proc_has_ret[MAX_PROCS];
int proc_ret_type[MAX_PROCS];
int proc_count;

/* Unit flags */
int unit_hardware;

/* Error flag */
int parse_error;

/* Initialize parser with source buffer */
void parser_init(char *src, int len);

/* Parse a complete Pascal program, emitting .spc to stdout */
void parse_program(void);
