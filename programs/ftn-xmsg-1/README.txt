Fant litt XMSG. Det er 2 biblioteker og 2 programmer. Det ene er kodet i NPL og gjør MON 200, det andre er et overbygg
Som gjør det litt enklere og åpne porter, connecte, sende og motta.
Det ene programmet åpner en port og venter på at en client kobler seg til den.
Client kobler seg til og sender to meldinger. MAGNO er tall jeg generer selv og er kanskje veldig forskjellig fra det XMSG gir
i SINTRAN. Det er vel forskjellige versjoner av XMSG, jeg vet ikke hvor godt de spiller sammen.

<>server

 ./(XMSG)/SERVER.PROG
A server port named ServerX should now be open
Port no.                1, MAGNO is          4292717
1ype 1 to continue

** Read incoming messages
--- Somebody asked for my magic number
--- give him my MAGNO =          4292717
--- His MAGNO         =          8503405
** A client connected to my server port
Client magic number is          8503405
Received     2 bytes
Send port               1, client magno         8503405
Received     4 bytes
Send port               1, client magno         8503405

<>client

 ./(XMSG)/CLIENT.PROG
The server MAGNO is          4292717
My port no. is                2
Sent    2 bytes
Sent    4 bytes
PAUSE 10

Programmet terminer når du gir en CR og kan startes igjen, server venter på ny oppkobling.

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
