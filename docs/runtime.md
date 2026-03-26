# p24p Runtime Library

The runtime library provides execution-time services for Pascal programs compiled by p24p. It is written in Pascal, compiled by p24p itself into .spc, assembled by pasm into .p24 bytecode, and loaded alongside user programs on the pv24a VM.

## Architecture

```
runtime.pas ──→ p24p (C compiler) ──→ runtime.spc
                                          │
user.pas ───→ p24p (C compiler) ───→ user.spc
                                          │
                              ┌───────────┘
                              ▼
                     pasm (assembler)
                              │
                              ▼
                     combined .p24 bytecode
                              │
                              ▼
                     pv24a VM (execution)
                              │
                              ▼
                     web-dv24r (Rust/Yew debugger)
```

The compiler emits `call` instructions to runtime routines. pasm resolves these references when assembling the combined .spc output (runtime + user program) into a single .p24 file.

## Linking Model

Phase 0 uses a simple concatenation model: the compiler's .spc output is appended after the runtime .spc stubs. pasm sees all procedures in one assembly unit and resolves all `call` targets by name.

```
; runtime.spc (always included)
.proc _p24p_write_int 0
    ...
.end

.proc _p24p_write_bool 0
    ...
.end

.proc _p24p_write_ln 0
    ...
.end

; user program .spc (compiler output)
.proc main 0
    enter 0
    push 42
    call _p24p_write_int
    call _p24p_write_ln
    halt
.end
```

## Runtime Components by Phase

### Phase 0 — Hand-Written .spc (Permanent)

These routines wrap `sys` instructions directly and stay as hand-written .spc forever. There is no benefit to rewriting them in Pascal since they are thin wrappers around VM syscalls.

| Routine | Stack Effect | Description |
|---------|-------------|-------------|
| `_p24p_write_int` | ( n -- ) | Print signed integer to UART as decimal |
| `_p24p_write_bool` | ( b -- ) | Print `TRUE` or `FALSE` to UART |
| `_p24p_write_ln` | ( -- ) | Print newline (LF) to UART |

**Implementation notes:**
- `_p24p_write_int` handles sign, converts to decimal digits via repeated div/mod, outputs via `sys 1` (PUTC)
- `_p24p_write_bool` compares to 0, branches to print "TRUE" or "FALSE" character by character
- `_p24p_write_ln` pushes 10 (LF) and calls `sys 1`

### Phase 1 — Pascal Runtime (Dogfooding Begins)

Once the compiler supports procedures, functions, arrays, records, and characters, these routines can be written in Pascal and compiled by p24p itself.

| Routine | Description | Compiler Features Exercised |
|---------|-------------|---------------------------|
| `abs(x)` | Absolute value | functions, if/then/else |
| `odd(x)` | Test if odd | functions, mod |
| `ord(c)` | Character to integer | functions, char type |
| `chr(n)` | Integer to character | functions, char type |
| `succ(x)` | Next ordinal value | functions, arithmetic |
| `pred(x)` | Previous ordinal value | functions, arithmetic |
| `sqr(x)` | Square of integer | functions, multiplication |
| `_p24p_bounds_check` | Array bounds violation handler | procedures, writeln, arrays |
| `_p24p_nil_check` | Nil pointer dereference handler | procedures, pointers |

Each routine tests the compiler feature that enables it — this is the dogfooding feedback loop.

### Phase 1 — Read/Readln Support

| Routine | Stack Effect | Description |
|---------|-------------|-------------|
| `_p24p_read_int` | ( -- n ) | Read integer from UART (sign + digits) |
| `_p24p_read_char` | ( -- c ) | Read single character from UART |
| `_p24p_read_ln` | ( -- ) | Skip to next line (consume through LF) |

These use `sys 2` (GETC) internally. The integer reader handles optional sign and digit accumulation. Written in Pascal once char type and loops are available.

### Phase 2 — Heap and Dynamic Features (Pascal)

| Routine | Description | Compiler Features Exercised |
|---------|-------------|---------------------------|
| `_p24p_heap_init` | Initialize free list | pointers, records, globals |
| `_p24p_new(size)` | Allocate heap block | pointers, records, sys ALLOC |
| `_p24p_dispose(ptr)` | Free heap block | pointers, records, sys FREE |
| `_p24p_leak_report` | Report unfreed allocations at exit | arrays, records, writeln |
| `_p24p_set_union` | Set union (bit-vector OR) | arrays, bitwise ops |
| `_p24p_set_intersect` | Set intersection (bit-vector AND) | arrays, bitwise ops |
| `_p24p_set_diff` | Set difference | arrays, bitwise ops |
| `_p24p_set_member` | Set membership test | arrays, bitwise ops |
| `_p24p_str_compare` | String comparison | arrays, char type, loops |
| `_p24p_str_copy` | String copy | arrays, char type |
| `_p24p_str_concat` | String concatenation | arrays, char type, new |
| `_p24p_subrange_check` | Subrange violation handler | procedures, writeln |

The heap allocator is the flagship dogfooding target — it exercises pointers, records, arrays, and the VM's memory model simultaneously.

## VM Syscall Interface

The runtime communicates with the VM through `sys` instructions:

| ID | Name | Stack Effect | Description |
|----|------|-------------|-------------|
| 0 | HALT | ( -- ) | Stop execution |
| 1 | PUTC | ( c -- ) | Write byte to UART |
| 2 | GETC | ( -- c ) | Read byte from UART (blocking) |
| 3 | LED | ( n -- ) | Write LED state |
| 4 | ALLOC | ( size -- addr ) | Heap allocate |
| 5 | FREE | ( addr -- ) | Heap free |

Phase 0 runtime uses only PUTC. Phase 1 adds GETC. Phase 2 adds ALLOC/FREE.

## Debugging with web-dv24r

The web-dv24r browser debugger (Rust/Yew/WASM) provides p-code-level visibility into runtime execution:

- **Step through runtime code** at the p-code instruction level — see each `push`, `div`, `mod`, `sys 1` as `_p24p_write_int` converts a number to decimal digits
- **Eval stack inspection** — watch values flow through runtime routines
- **Call frame panel** — see the call chain from user code into runtime procedures
- **Memory map** — inspect globals, heap state, and VM regions
- **Delta highlighting** — see what changed after each instruction

This makes the runtime fully transparent during development. When a runtime routine misbehaves, the debugger shows exactly which p-code instruction produced the wrong result — no printf debugging needed.

## Naming Convention

All runtime routines use the `_p24p_` prefix to avoid collisions with user-defined Pascal identifiers. Standard functions (`abs`, `odd`, etc.) are exposed under their Pascal names but implemented as calls to prefixed internal routines where needed.
