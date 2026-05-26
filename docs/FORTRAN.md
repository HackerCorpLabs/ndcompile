# Building FORTRAN Programs on ND-100 (SINTRAN III)

## Source Code

FORTRAN source files use the `:SYMB` extension on NDFS. Files must have CRLF line endings and even parity (bit 7).

### Example: XMSG Client

File: `CLIENT:SYMB`

```fortran
C ---------------------------------------------------------------------------
C XMSG Client - connects to a named server port and sends messages
C ---------------------------------------------------------------------------

      PROGRAM CLIENT

      INTEGER*4 SRV_MAGNO, CLI_MAGNO
      INTEGER*2 MYPORT, ISTAT, MESAD, NBYTES
      INTEGER*2 MESS(1024)
      INTEGER*2 OPEN_CLIENT, SEND_MESS, RECV_MESS

      ISTAT = OPEN_CLIENT('ServerX', MYPORT, SRV_MAGNO, 1)
      IF (ISTAT .NE. 0) THEN
        CALL  WSTAT('* Open client failed', ISTAT)
        STOP 999
      ENDIF

      OUTPUT(1)'The server MAGNO is ', SRV_MAGNO
      OUTPUT(1)'My port no. is ', MYPORT
      DO 10 I=1,2
       NBYTES = I*2
       ISTAT = SEND_MESS(MYPORT, SRV_MAGNO, MESS, NBYTES)
       IF (ISTAT .NE. 0) THEN
         CALL  WSTAT('* Send message failed', ISTAT)
         STOP 999
       ENDIF
       WRITE(1,20)NBYTES
20     FORMAT(1H ,'Sent', I5 , ' bytes')

C Read an answer from the server
       ISTAT = RECV_MESS(MYPORT, MESAD, MESS, NBYTES,0,
     c  SRV_MAGNO, CLI_MAGNO)
10    CONTINUE
      PAUSE 10
      END
```

## Interactive Build

From the SINTRAN prompt:

```
@FORT
SEP OFF
COMP CLIENT,,"CLIENT"
EXIT
@BRF-LINKER
PROG-FILE "CLIENT"
LOAD CLIENT
LOAD FORTRAN-XLIB
LOAD XMSG-LIBRARY
LOAD FORT-1B
LI-E-UNDEF
EXIT
@CLIENT
```

## Automated Build (MODE file)

File: `CLIENT:MODE`

```
@DELETE-FILE CLIENT:PROG
@DELETE-FILE CLIENT:BRF
@FORT
SEP OFF
COMP CLIENT,,"CLIENT"
EXIT
@BRF-LINKER
PROG-FILE "CLIENT"
LOAD CLIENT
LOAD FORTRAN-XLIB
LOAD XMSG-LIBRARY
LOAD FORT-1B
LI-E-UNDEF
EXIT
```

Run with: `@MODE CLIENT:MODE,,`

## Build Process Step by Step

### 1. Compile with FORTRAN

```
@FORT
SEP OFF
COMP sourcename,,"objectname"
EXIT
```

- `@FORT` -- launches the ANSI 77 FORTRAN compiler (203053F02)
- `SEP OFF` -- disables separate data space (single address space, 1-bank mode)
- `COMP source,,"object"` -- compiles source. Three parameters:
  - `source` -- source file name (looks for `:SYMB` extension)
  - listing -- omitted (empty between commas)
  - `"object"` -- object file name (quoted because it's created, produces `:BRF`)
- Multiple COMP commands can be issued in one session to compile several files
- `EXIT` -- leaves the compiler

### 2. Link with BRF-LINKER

```
@BRF-LINKER
PROG-FILE "progname"
LOAD module1
LOAD module2
LOAD library
LOAD FORT-1B
LI-E-UNDEF
EXIT
```

- `@BRF-LINKER` -- launches the BRF linker (210721C01)
- `PROG-FILE "name"` -- sets output program file name (quoted, creates `:PROG`)
- `LOAD name` -- loads a `:BRF` module into the program
- `LOAD FORT-1B` -- loads the FORTRAN 1-bank runtime (includes FORTRAN-1BANK-F02 and PLANC-1BANK-G00)
- `LI-E-UNDEF` -- lists any undefined symbols (useful for debugging missing dependencies)
- `EXIT` -- writes the PROG file and exits
- Load order matters: application modules first, then libraries, then runtime last

### 3. Run

```
@progname
```

Runs the compiled `:PROG` file.

## Build Output

The compiler and linker produce:
- `name:BRF` -- binary relocatable file (from FORT compiler)
- `name:PROG` -- executable program (from BRF-LINKER)

## NPL/MAC Library Build

Some libraries (like XMSG-LIBRARY) are written in NPL and need a separate build step before the FORTRAN link:

```
@NPL
@DEV XMSG-LIBRARY,,100
@MAC
)9ASSM 100,,"XMSG-LIBRARY"
)9TSS
```

- `@NPL` / `@DEV` -- compiles NPL source to MAC assembly (output to logical file 100)
- `@MAC` / `)9ASSM` -- assembles MAC output into `:BRF` (quoted output name for creation)
- `)9TSS` -- exits MAC assembler

## Quoting Rules

- Files being **created** (output) must be quoted: `"FILENAME"`
- Files being **read** (input/source) are unquoted: `FILENAME`
- This applies to COMP object parameter, PROG-FILE, and )9ASSM output

## Prerequisites

Install FORTRAN compiler from floppy 210191F02-XX-01D (use 48 bit lib):

```
@COPY-FILE "FORTRAN-100-F02:PROG" (210191F02-XX-01D:FLOPPY-USER)FORTRAN-100-F02:PROG
@COPY-FILE "FORT-1BANK-F02:BRF" (210191F02-XX-01D:FLOPPY-USER)FORT48-1BANK-F02:BRF
@COPY-FILE "FORT-2BANK-F02:BRF" (210191F02-XX-01D:FLOPPY-USER)FORT48-2BANK-F02:BRF
```

Install BRF-LINKER from floppy 210721C01-XX-01D:

```
@COPY-FILE "BRF-LINKER:PROG" (210721C01-XX-01D:FLOPPY-USER)BRF-LINKER-C01:PROG
```

## FORTRAN Syntax Notes

- Fixed-format source: columns 1-6 for labels/continuation, 7-72 for code
- Column 1: `C` for comment lines
- Column 6: any character for continuation line
- `INTEGER*2` -- 16-bit integer (1 word)
- `INTEGER*4` -- 32-bit integer (2 words)
- `OUTPUT(unit)` -- ND-100 FORTRAN extension for simple terminal output
- `INPUT(unit)` -- ND-100 FORTRAN extension for simple terminal input
- All SINTRAN text files (`:SYMB`, `:MODE`) require CRLF line endings and even parity (bit 7)
