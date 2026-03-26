# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: AgentRail Session Protocol (MUST follow exactly)

This project uses AgentRail. Every session follows this exact sequence:

### 1. START (do this FIRST, before anything else)
```bash
agentrail next
```
Read the output carefully. It tells you your current step, prompt, skill docs, and past trajectories.

### 2. BEGIN (immediately after reading the next output)
```bash
agentrail begin
```

### 3. WORK (do what the step prompt says)
Do NOT ask the user "want me to proceed?" or "shall I start?". The step prompt IS your instruction. Execute it.

### 4. COMMIT (after the work is done)
Commit your code changes with git.

### 5. COMPLETE (LAST thing, after committing)
```bash
agentrail complete --summary "what you accomplished" \
  --reward 1 \
  --actions "tools and approach used"
```
If the step failed: `--reward -1 --failure-mode "what went wrong"`
If the saga is finished: add `--done`

### 6. STOP (after complete, DO NOT continue working)
Do NOT make any further code changes after running agentrail complete.
Any changes after complete are untracked and invisible to the next session.
If you see more work to do, it belongs in the NEXT step, not this session.

Do NOT skip any of these steps. The next session depends on your trajectory recording.

## Project: p24p — Pascal Compiler for COR24 P-Code VM

Pascal compiler written in C (via tc24r) that emits .spc p-code assembler output for the pv24a VM. The runtime library is written in Pascal itself (dogfooded). Pipeline: `.pas → p24p (C) → .spc → pasm → .p24 → pv24a VM`.

## Related Projects

- `~/github/sw-vibe-coding/pv24a` — P-code VM and p-code assembler (COR24 assembly, `pvm.s`, `pasm.s`)
- `~/github/sw-vibe-coding/tc24r` — COR24 C compiler (Rust), compiles p24p's C source
- `~/github/sw-embed/cor24-rs` — COR24 assembler and emulator (Rust, provides `cor24-run`)
- `~/github/softwarewrighter/web-dv24r` — Browser-based p-code VM debugger (Yew/WASM)
- `~/github/sw-vibe-coding/agentrail-domain-coding` — Coding skills domain

## Available Task Types

`cor24-c`, `pre-commit`

## Key Documentation (READ BEFORE WORKING)

- `docs/research.txt` — Deep research on p-code VM design, Pascal compiler architecture, bootstrapping strategy
- `docs/c-and-pascal-implementation.md` — Implementation strategy: what's in C vs Pascal, phase breakdown, runtime dogfooding plan
- `docs/tc24r-bug-report-feature-request.md` — Known tc24r issues and workarounds

## Build & Test

```bash
# Compile a C source file to COR24 assembly
tc24r <file.c> -o <file.s> -I ~/github/sw-vibe-coding/tc24r/include

# Assemble and run on emulator
cor24-run --run <file.s> --dump --speed 0 --time 30

# With UART input
cor24-run --run <file.s> -u 'input\n' --speed 0 -n 5000000
```

## COR24 C Constraints (tc24r)

- Single translation unit (no linker)
- No function pointers (use switch/case for dispatch)
- No floating point (COR24 has no FPU)
- malloc is a bump allocator (free is a no-op)
- All integers are 24-bit (3 bytes)
- Use `#include <stdio.h>` and `#include <stdlib.h>` from tc24r/include/

## P-Code Target

The compiler emits `.spc` files — p-code assembler source for pasm. See pv24a `docs/design.md` for the p-code instruction set (opcodes, encoding, stack effects).

## Cross-Agent Wiki

This project coordinates with other COR24 toolchain agents via a shared wiki. See `docs/agent-cas-wiki.md` for the API reference and CAS protocol. Key pages: [[P24P]], [[P24Toolchain]], [[AgentToAgentRequests]], [[AgentStatus]].

```bash
# Quick wiki access
curl -s http://localhost:7402/api/pages          # list pages
curl -s http://localhost:7402/api/pages/P24P      # read a page
```
