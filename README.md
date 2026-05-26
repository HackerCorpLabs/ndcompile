# ndcompile

Build and test tool for ND-100 programs using the nd100x emulator and ndtool for disk image management.

## Supported Languages

- [PLANC](docs/PLANC.md)
- [FORTRAN](docs/FORTRAN.md)

## Usage

```bash
# Build and run a program
make hello

# Build any program by name
make build PROG=HELLO

# Boot SINTRAN without build scripts
make run

# Restore disk from backup and create BUILD user
make clean
```

## Project Structure

```
programs/           Program source directories
  HELLO/
    HELLO.PLNC      PLANC source code
scripts/
  LOAD-MODE.MODE    Boot script (copies to SYSTEM on disk)
docs/               Language-specific build documentation
Makefile            Build system
```

## Requirements

- [nd100x](https://github.com/HackerCorpLabs/nd100x) -- ND-100 emulator
- [ndtool](https://github.com/HackerCorpLabs/norskdata-ndfs) -- NDFS disk image tool
- SMD0.IMG.bak -- clean SINTRAN III disk image (not included)
