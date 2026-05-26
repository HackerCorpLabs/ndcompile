# Building a PLANC Hello World on ND-100 (SINTRAN III)

## Source Code

File: `HELLO:PLNC` (must have CRLF line endings and even parity)

```planc
MODULE hello
    INTEGER ARRAY : stack(0:100)
    BYTES : msg := 'HELLO FROM PLANC!'

    PROGRAM : main
        INISTACK stack
        OUTPUT (1,'AL17',msg)
        OUTPUT (1,'AL1','$')
    ENDROUTINE
ENDMODULE
```

## Interactive Build

From the SINTRAN prompt:

```
@PLANC
PROG-FILE "HELLO"
COMPILE HELLO:PLNC,"HELLO:LIST","HELLO"
EXIT
@HELLO
```

## Automated Build (MODE file)

File: `DO-BUILD:MODE`

```
@DELETE-FILE HELLO:PROG
@DELETE-FILE HELLO:LIST
@DELETE-FILE HELLO:BRF
@PLANC
PROG-FILE "HELLO"
COMPILE HELLO:PLNC,"HELLO:LIST","HELLO"
EXIT
@HELLO
```

Run with: `@MODE DO-BUILD:MODE,,`

## Step by step

1. **Delete old build artifacts** -- `@DELETE-FILE` removes any previous `:PROG`, `:LIST`, and `:BRF` files.

2. **Start the PLANC compiler** -- `@PLANC` launches the ND-100 PLANC compiler (Version E, 1984).

3. **Set output program file** -- `PROG-FILE "HELLO"` tells the compiler to create `HELLO:PROG` directly. This is critical -- without it, the compiler only creates a `:BRF` (Binary Relocatable File) and you would need NRL (the linker) as a separate step.

4. **Compile** -- `COMPILE HELLO:PLNC,"HELLO:LIST","HELLO"` compiles the source. The three parameters are:
   - `HELLO:PLNC` -- source file
   - `"HELLO:LIST"` -- listing output file (quoted)
   - `"HELLO"` -- object file name (quoted, no type = creates `:BRF`)

5. **Exit compiler** -- `EXIT` leaves the PLANC compiler. It reports line count, diagnostics, and memory usage.

6. **Run the program** -- `@HELLO` executes the compiled `HELLO:PROG`.

## Build output

The compiler produces three files:
- `HELLO:PROG` -- executable program (run with `@HELLO`)
- `HELLO:BRF` -- binary relocatable file
- `HELLO:LIST` -- compiler listing with line numbers

## Expected output

```
HELLO FROM PLANC!
```

## PLANC syntax notes

- PLANC uses `MODULE`/`ENDMODULE` structure -- not Pascal's `PROGRAM`/`BEGIN`/`END`
- Entry point is declared with `PROGRAM : name` inside the module
- `INISTACK` must be called first to initialize the runtime stack
- `OUTPUT (device, format, variable)` writes to terminal (device 1)
- `'AL17'` is a format descriptor: Alphanumeric, Left-justified, 17 characters
- `'$'` outputs a CR+LF (newline)
- `BYTES : name := 'string'` declares a byte array with implicit length from the initializer
- All SINTRAN text files (`:MODE`, `:PLNC`, `:LIST`) require CRLF line endings and even parity (bit 7)

## AI Skill Reference

A comprehensive PLANC programming skill has been created for AI-assisted development:

- **Main skill**: `/home/ronny/.claude/skills/planc-programming/SKILL.md`
- **Operators reference**: `/home/ronny/.claude/skills/planc-programming/references/operators.md`
- **Monitor calls reference**: `/home/ronny/.claude/skills/planc-programming/references/moncalls.md`
- **XMSG reference**: `/home/ronny/.claude/skills/planc-programming/references/xmsg.md`

Coverage: 14 sections covering lexical structure, types, declarations, all operators with priorities, every statement form, routines with all modifiers, modules with EXPORT/IMPORT, I/O with all format descriptors, monitor calls with worked examples, XMSG with complete client/server examples, inline assembly, dynamic memory, and known restrictions. Every claim cites manual section/page.

Related documentation in NDInsight (`/mnt/e/Dev/Ronny/NDInsight/`):
- `Developer/QUICK-START-EXAMPLES.md` -- verified PLANC build examples
- `Developer/Languages/Application/PLANC-DEVELOPER-GUIDE.md` -- full developer guide (v2.0)
- `Developer/Workflow/BUILD-PLANC.MODE` -- build MODE file template
- `Developer/Workflow/BUILD-PLANC-2BANK.MODE` -- 2-bank build MODE file template
