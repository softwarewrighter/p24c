# Phase 1 Pascal Subset: Block Structure

Phase 1 extends Phase 0 with procedures, functions, nested scopes, structured types, and additional control flow. The compiler remains single-pass where possible but uses forward declaration to handle mutual recursion.

## 1. BNF Grammar

New/changed productions marked with `(+)`. Phase 0 productions unchanged unless noted.

```bnf
program         = "program" IDENT ";" block "." .

block           = [ const-section ] [ type-section(+) ] [ var-section ]
                  { proc-or-func-decl(+) }
                  compound-stmt .

const-section   = "const" const-def { const-def } .
const-def       = IDENT "=" const-expr ";" .
const-expr      = [ "+" | "-" ] ( INTEGER | IDENT ) .

type-section(+) = "type" type-def { type-def } .
type-def(+)     = IDENT "=" type-denoter ";" .

type-denoter(+) = simple-type | array-type | record-type .
simple-type     = "integer" | "boolean" | "char"(+) | IDENT(+) .
array-type(+)   = "array" "[" const-expr ".." const-expr "]" "of" type-denoter .
record-type(+)  = "record" field-list "end" .
field-list(+)   = field-decl { ";" field-decl } .
field-decl(+)   = ident-list ":" type-denoter .

var-section     = "var" var-decl { var-decl } .
var-decl        = ident-list ":" type-denoter ";" .
ident-list      = IDENT { "," IDENT } .

proc-or-func-decl(+) = proc-decl | func-decl .

proc-decl(+)    = "procedure" IDENT [ formal-params ] ";" ( block ";" | "forward" ";" ) .
func-decl(+)    = "function" IDENT [ formal-params ] ":" simple-type ";" ( block ";" | "forward" ";" ) .

formal-params(+) = "(" param-group { ";" param-group } ")" .
param-group(+)   = [ "var" ] ident-list ":" simple-type .

compound-stmt   = "begin" stmt { ";" stmt } "end" .

stmt            = [ assignment
                  | proc-call(+)
                  | if-stmt
                  | while-stmt
                  | for-stmt(+)
                  | repeat-stmt(+)
                  | case-stmt(+)
                  | write-stmt(+)
                  | read-stmt(+)
                  | compound-stmt ] .

assignment      = designator(+) ":=" expression .
proc-call(+)    = IDENT [ "(" expr-list ")" ] .

if-stmt         = "if" expression "then" stmt [ "else" stmt ] .
while-stmt      = "while" expression "do" stmt .

for-stmt(+)     = "for" IDENT ":=" expression ( "to" | "downto" ) expression "do" stmt .
repeat-stmt(+)  = "repeat" stmt { ";" stmt } "until" expression .
case-stmt(+)    = "case" expression "of" case-branch { ";" case-branch } [ ";" ] "end" .
case-branch(+)  = const-expr { "," const-expr } ":" stmt .

write-stmt(+)   = ( "write" | "writeln" ) [ "(" write-arg { "," write-arg } ")" ] .
write-arg(+)    = expression [ ":" expression [ ":" expression ] ] .

read-stmt(+)    = ( "read" | "readln" ) [ "(" designator { "," designator } ")" ] .

designator(+)   = IDENT { "[" expression "]" | "." IDENT } .

expression      = simple-expr [ rel-op simple-expr ] .
rel-op          = "=" | "<>" | "<" | "<=" | ">" | ">=" .

simple-expr     = [ "+" | "-" ] term { add-op term } .
add-op          = "+" | "-" | "or" .

term            = factor { mul-op factor } .
mul-op          = "*" | "div" | "mod" | "and" .

factor          = INTEGER | STRING-LIT(+) | CHAR-LIT(+)
               | "true" | "false"
               | "not" factor
               | "(" expression ")"
               | designator(+) [ "(" expr-list ")" ](+)  .

expr-list       = expression { "," expression } .
```

### New Tokens

| Token       | Pattern                  | Notes                        |
|-------------|--------------------------|------------------------------|
| CHAR-LIT    | `'x'` (single char)     | Ordinal value 0-255          |
| STRING-LIT  | `'abc'` (len >= 2)      | Sequence of bytes            |
| `procedure` | keyword                  |                              |
| `function`  | keyword                  |                              |
| `forward`   | keyword                  |                              |
| `type`      | keyword                  |                              |
| `array`     | keyword                  |                              |
| `of`        | keyword                  |                              |
| `record`    | keyword                  |                              |
| `char`      | keyword (type)           |                              |
| `for`       | keyword                  |                              |
| `to`        | keyword                  |                              |
| `downto`    | keyword                  |                              |
| `repeat`    | keyword                  |                              |
| `until`     | keyword                  |                              |
| `case`      | keyword                  |                              |
| `write`     | keyword                  |                              |
| `read`      | keyword                  |                              |
| `readln`    | keyword                  |                              |
| `[` `]`     | symbols                  | Array indexing               |
| `..`        | symbol                   | Range in array bounds        |

## 2. .spc Code Generation

### 2.1 Procedure and Function Declarations

Each procedure/function becomes a `.proc` / `.end` block. Local variables use `loadl`/`storel`. Parameters use `loada`/`storea`.

```pascal
procedure PrintSum(a, b: integer);
var sum: integer;
begin
  sum := a + b;
  writeln(sum)
end;
```

Emits:

```
.proc PrintSum 1          ; 1 local variable (sum)
    enter 1
    loada 0               ; a
    loada 1               ; b
    add
    storel 0              ; sum := a + b
    loadl 0               ; sum
    call _p24p_write_int
    call _p24p_write_ln
    ret 2                 ; clean 2 arguments
.end
```

### 2.2 Procedure Calls

Caller pushes arguments left-to-right, then `call`.

```pascal
PrintSum(10, 20);
```

Emits:

```
    push 10               ; arg 0
    push 20               ; arg 1
    call PrintSum
```

### 2.3 Function Calls and Return Values

Functions leave their return value on the eval stack. The function body assigns to the function name, which maps to a hidden local.

```pascal
function Max(a, b: integer): integer;
begin
  if a > b then Max := a
  else Max := b
end;
```

Emits:

```
.proc Max 1               ; 1 local = return value slot
    enter 1
    loada 0               ; a
    loada 1               ; b
    gt
    jz L0
    loada 0
    storel 0              ; return value := a
    jmp L1
L0:
    loada 1
    storel 0              ; return value := b
L1:
    loadl 0               ; push return value
    ret 2                 ; clean 2 args, return value on stack
.end
```

Caller:

```
    push 5
    push 3
    call Max              ; leaves result on eval stack
    storel 0              ; store result
```

### 2.4 Var Parameters (Pass by Reference)

`var` parameters pass the address of the variable. The callee uses `load`/`store` (indirect) to access the value through the address.

```pascal
procedure Swap(var x, y: integer);
var tmp: integer;
begin
  tmp := x;   { x is a pointer — indirect load }
  x := y;
  y := tmp
end;
```

Caller:

```
    addrl 0               ; push address of local variable x
    addrl 1               ; push address of local variable y
    call Swap
```

Callee:

```
.proc Swap 1              ; 1 local (tmp)
    enter 1
    loada 0               ; address of x
    load                  ; indirect: get value of x
    storel 0              ; tmp := x
    loada 1               ; address of y
    load                  ; get value of y
    loada 0               ; address of x
    store                 ; x := y (indirect store)
    loadl 0               ; tmp
    loada 1               ; address of y
    store                 ; y := tmp
    ret 2
.end
```

### 2.5 Nested Procedures and Static Links

When a nested procedure accesses a variable from an enclosing scope, the compiler uses `loadn`/`storen` with a depth (number of static link hops) and an offset (local slot in that frame).

```pascal
program Nesting;
var g: integer;

  procedure Outer;
  var x: integer;

    procedure Inner;
    begin
      x := x + 1;         { x is in Outer's frame, depth=1 }
      writeln(x)
    end;

  begin
    x := 10;
    Inner
  end;

begin
  Outer
end.
```

Inner's code for `x := x + 1`:

```
    loadn 1 0             ; depth=1 (one level up), offset=0 (first local in Outer)
    push 1
    add
    storen 1 0            ; store back
```

Calling a nested procedure uses `calln depth addr`:

```
    calln 0 Inner         ; depth=0: Inner is directly nested in current scope
```

### 2.6 Arrays

Arrays are stored as contiguous words. The compiler tracks low bound and element size for index calculation.

```pascal
var a: array[1..10] of integer;
```

Emits `.global a 10` (10 words).

Access `a[i]`:

```
    addrg a               ; base address
    loadg i               ; index value
    push 1                ; subtract low bound
    sub
    push 3                ; multiply by element size (3 bytes per word)
    mul
    add                   ; base + (i - lo) * elemsize
    load                  ; indirect load
```

Store `a[i] := expr`:

```
    ; <compile expr — leaves value on stack>
    addrg a               ; base address
    loadg i
    push 1
    sub
    push 3
    mul
    add                   ; address of a[i]
    store                 ; indirect store: ( val addr -- )
```

### 2.7 Records

Records are contiguous words with named field offsets.

```pascal
type Point = record
  x, y: integer
end;
var p: Point;
```

Emits `.global p 2` (2 words: x at offset 0, y at offset 3).

Access `p.x`:

```
    addrg p               ; base address
    push 0                ; field offset for x (0 bytes)
    add
    load
```

Access `p.y`:

```
    addrg p
    push 3                ; field offset for y (3 bytes)
    add
    load
```

### 2.8 For Statement

```pascal
for i := 1 to 10 do
  writeln(i);
```

Emits:

```
    push 1
    storel 0              ; i := 1
    push 10
    storel 1              ; limit in hidden local
L0:
    loadl 0               ; i
    loadl 1               ; limit
    gt                    ; i > limit?
    jnz L1                ; exit if past limit
    ; <body>
    loadl 0
    call _p24p_write_int
    call _p24p_write_ln
    ; increment
    loadl 0
    push 1
    add
    storel 0              ; i := i + 1
    jmp L0
L1:
```

`downto` uses `lt` instead of `gt` and `sub` instead of `add`.

### 2.9 Repeat/Until

```pascal
repeat
  readln(n);
until n = 0;
```

Emits:

```
L0:
    ; <body>
    addrl 0               ; address of n for readln
    call _p24p_read_int
    ; <condition>
    loadl 0
    push 0
    eq
    jz L0                 ; loop while condition is false
```

### 2.10 Case Statement

Implemented as a chain of comparisons (not a jump table — simpler for Phase 1).

```pascal
case x of
  1: writeln(10);
  2, 3: writeln(20);
end;
```

Emits:

```
    loadl 0               ; x
    dup
    push 1
    eq
    jz L0
    drop                  ; discard selector
    push 10
    call _p24p_write_int
    call _p24p_write_ln
    jmp L2                ; exit case
L0:
    dup
    push 2
    eq
    jnz L1_hit
    dup
    push 3
    eq
    jz L1
L1_hit:
    drop
    push 20
    call _p24p_write_int
    call _p24p_write_ln
    jmp L2
L1:
    drop                  ; no match — drop selector
L2:
```

### 2.11 Char Type and String Literals

`char` is a single byte (ordinal 0-255). Stored as a word but only the low byte is significant.

String literals go into the `.data` segment:

```pascal
writeln('Hello');
```

Emits:

```
.data S0 72, 101, 108, 108, 111, 0   ; "Hello\0"

    push S0                ; address of string data
    call _p24p_write_str   ; runtime: print null-terminated string
    call _p24p_write_ln
```

Char literals:

```pascal
var ch: char;
ch := 'A';
```

Emits:

```
    push 65               ; ord('A')
    storel 0
```

### 2.12 Read/Readln

`read` reads values into variables. `readln` reads then skips to next line.

```pascal
read(n);
readln(ch);
```

Emits:

```
    addrl 0               ; address of n
    call _p24p_read_int   ; runtime: read integer, store via address
    addrl 1               ; address of ch
    call _p24p_read_char  ; runtime: read char
    call _p24p_read_ln    ; skip to next line
```

### 2.13 Write with Field Widths

```pascal
write(n:5);           { right-justify in 5 columns }
write(x:10:2);        { not applicable — no reals }
```

Emits:

```
    loadl 0               ; n
    push 5                ; width
    call _p24p_write_int_w  ; runtime: write with width
```

### 2.14 Module Metadata

Same as Phase 0. All procedures and the main block are exported/externed as needed:

```
.module <program_name>
.extern _p24p_write_int
.extern _p24p_write_ln
.extern _p24p_write_str
.extern _p24p_read_int
.extern _p24p_read_ln
.export main
.endmodule
```

## 3. Symbol Table Design

### 3.1 Scope Stack

Phase 1 requires nested scopes. The symbol table uses a scope stack.

```
scope_level:  current nesting depth (0 = program level)
scope_start[]: index into symbol array where each scope begins
```

When entering a new scope (procedure/function body), push `sym_count` onto `scope_start`. When leaving, pop and restore `sym_count` — all symbols added in that scope are discarded.

### 3.2 Symbol Kinds

```
SYM_CONST    = 0   compile-time constant
SYM_VAR      = 1   variable (global or local)
SYM_PROC     = 2   procedure
SYM_FUNC     = 3   function
SYM_TYPE     = 4   type name
SYM_FIELD    = 5   record field
SYM_PARAM    = 6   value parameter
SYM_VARPARAM = 7   var parameter (by reference)
```

### 3.3 Symbol Fields

Each symbol stores:

| Field | Description |
|-------|-------------|
| name | Identifier (lowercased) |
| kind | SYM_CONST, SYM_VAR, SYM_PROC, etc. |
| type_id | Type index (integer, boolean, char, array, record, etc.) |
| level | Scope nesting depth where declared |
| value | For SYM_CONST: constant value. For SYM_VAR/PARAM: slot offset. For SYM_PROC/FUNC: label name or index. |
| param_count | For SYM_PROC/FUNC: number of parameters |

### 3.4 Type Table

Types are stored in a separate table indexed by type_id:

| Field | Description |
|-------|-------------|
| kind | TYPE_INTEGER, TYPE_BOOLEAN, TYPE_CHAR, TYPE_ARRAY, TYPE_RECORD |
| size | Size in words (for allocation) |
| elem_type | For arrays: element type_id |
| lo, hi | For arrays: index bounds |
| fields | For records: index into field list |

### 3.5 Variable Addressing

| Variable Kind | Scope | Load | Store | Address-of |
|---------------|-------|------|-------|------------|
| Global var | level 0 | `loadg name` | `storeg name` | `addrg name` |
| Local var | same level | `loadl off` | `storel off` | `addrl off` |
| Nonlocal var | outer level | `loadn depth off` | `storen depth off` | follow chain + `addrl` |
| Value param | same level | `loada idx` | `storea idx` | — |
| Var param | same level | `loada idx` then `load` | `loada idx` then `store` | `loada idx` (already an address) |

Depth for nonlocal access = `current_level - declared_level`.

## 4. Type Checking

Phase 1 type rules (extends Phase 0):

| Context | Rule |
|---------|------|
| Assignment `x := e` | Type of `e` must match type of `x` |
| Procedure call `P(args)` | Number and types of args must match formal params |
| Function call `F(args)` | Same as procedure, plus return type used in expression |
| Var param actual | Must be a variable (designator), type must match exactly |
| Array index `a[e]` | `e` must be integer, result type is element type |
| Record field `r.f` | `f` must be a field of `r`'s record type |
| For loop variable | Must be integer or char (ordinal type), same scope |
| Case selector | Must be integer or char |
| Case labels | Must be constants matching selector type |
| Char operations | `ord(ch)` → integer, `chr(n)` → char |

## 5. Runtime Library Extensions

Phase 1 adds these runtime routines (in addition to Phase 0):

| Routine | Stack | Description |
|---------|-------|-------------|
| `_p24p_write_str` | ( addr -- ) | Print null-terminated string |
| `_p24p_write_char` | ( ch -- ) | Print single character |
| `_p24p_write_int_w` | ( n width -- ) | Print integer right-justified in width columns |
| `_p24p_read_int` | ( addr -- ) | Read decimal integer from UART, store at addr |
| `_p24p_read_char` | ( addr -- ) | Read one character from UART, store at addr |
| `_p24p_read_ln` | ( -- ) | Skip remaining input until newline |

Standard functions (compiled inline, not runtime calls):

| Function | Emitted Code |
|----------|-------------|
| `abs(n)` | `dup; push 0; lt; jz L; neg; L:` |
| `odd(n)` | `push 1; and` |
| `ord(ch)` | no-op (char is already an integer) |
| `chr(n)` | no-op (integer is stored as word) |
| `succ(n)` | `push 1; add` |
| `pred(n)` | `push 1; sub` |

## 6. Compiler Architecture (Phase 1)

Phase 1 remains single-pass for the common case but adds:

1. **Forward declarations**: `procedure Foo; forward;` adds the symbol with its signature. The body is compiled later when the full declaration appears.
2. **Scope stack**: Enter scope on procedure/function body, exit on `.end`.
3. **Local frame layout**: Count locals during var section, emit `enter N` with the correct count.
4. **Type table**: Separate from symbol table, stores array/record type info.

```
Pascal source (.pas)
       |
  [Lexer] ─── token stream
       |
  [Parser] ─── recursive descent, emits .spc directly
       |         forward decls allow single-pass
       |
  [Symbol Table] ─── scope stack, types, procedure signatures
       |
  [Type Table] ─── array bounds, record field layouts
       |
  .spc output
```

The compiler is still single-pass: each procedure body is compiled as it's encountered, emitting `.proc`/`.end` blocks. Forward declarations provide the signature before the body.

## 7. Complete Example

### Pascal Source

```pascal
program Demo;
type
  Pair = record
    x, y: integer
  end;

var
  arr: array[1..5] of integer;
  i: integer;

  procedure Fill(n: integer);
  var j: integer;
  begin
    for j := 1 to n do
      arr[j] := j * j
  end;

  function Sum(n: integer): integer;
  var j, total: integer;
  begin
    total := 0;
    for j := 1 to n do
      total := total + arr[j];
    Sum := total
  end;

begin
  Fill(5);
  for i := 1 to 5 do
    write(arr[i]:4);
  writeln;
  writeln(Sum(5))
end.
```

### Expected .spc Output

```
.module demo
.extern _p24p_write_int
.extern _p24p_write_int_w
.extern _p24p_write_ln
.export main

.global arr 5
.global i 1

.proc Fill 2              ; locals: j, for-limit
    enter 2
    push 1
    storel 0              ; j := 1
    loada 0               ; n
    storel 1              ; limit := n
L0:
    loadl 0
    loadl 1
    gt
    jnz L1
    ; arr[j] := j * j
    loadl 0
    loadl 0
    mul                   ; j * j
    addrg arr
    loadl 0
    push 1
    sub
    push 3
    mul
    add                   ; &arr[j]
    store
    ; j := j + 1
    loadl 0
    push 1
    add
    storel 0
    jmp L0
L1:
    ret 1
.end

.proc Sum 3               ; locals: j, total, for-limit (+ return value slot)
    enter 3
    push 0
    storel 1              ; total := 0
    push 1
    storel 0              ; j := 1
    loada 0
    storel 2              ; limit := n
L2:
    loadl 0
    loadl 2
    gt
    jnz L3
    ; total := total + arr[j]
    loadl 1
    addrg arr
    loadl 0
    push 1
    sub
    push 3
    mul
    add
    load                  ; arr[j]
    add
    storel 1              ; total := total + arr[j]
    ; j := j + 1
    loadl 0
    push 1
    add
    storel 0
    jmp L2
L3:
    loadl 1               ; push return value (total)
    ret 1
.end

.proc main 1              ; 1 local: for-limit
    enter 1
    ; Fill(5)
    push 5
    call Fill
    ; for i := 1 to 5 do write(arr[i]:4)
    push 1
    storeg i
    push 5
    storel 0              ; limit
L4:
    loadg i
    loadl 0
    gt
    jnz L5
    ; write(arr[i]:4)
    addrg arr
    loadg i
    push 1
    sub
    push 3
    mul
    add
    load                  ; arr[i]
    push 4                ; width
    call _p24p_write_int_w
    ; i := i + 1
    loadg i
    push 1
    add
    storeg i
    jmp L4
L5:
    ; writeln
    call _p24p_write_ln
    ; writeln(Sum(5))
    push 5
    call Sum              ; return value on stack
    call _p24p_write_int
    call _p24p_write_ln
    halt
.end
.endmodule
```

### Expected Output

```
   1   4   9  16  25
55
```

## 8. Implementation Order

Recommended order for incremental development:

1. **Procedures (no params)** — `.proc`/`.end`, `call`/`ret`, scope stack
2. **Value parameters** — `loada`/`storea`, argument pushing
3. **Local variables** — `loadl`/`storel`, `enter N` with correct count
4. **Functions** — return value slot, function call in expressions
5. **For/repeat statements** — new control flow
6. **Var parameters** — `addrl`/`addrg`, indirect `load`/`store`
7. **Nested procedures** — `calln`, `loadn`/`storen`, static links
8. **Char type and string literals** — `.data` segment, `_p24p_write_str`
9. **Arrays** — index calculation, bounds info in type table
10. **Records** — field offset calculation
11. **Case statement** — comparison chain
12. **Read/readln** — runtime routines, address passing
13. **Forward declarations** — two-phase symbol resolution
14. **Write with field widths** — `_p24p_write_int_w`
