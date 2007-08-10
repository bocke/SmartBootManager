@ECHO OFF
cls

copy includes\* .
cls

ECHO ---------- The ToasterOS make file 1.00 Kernel module Version ----------
ECHO  Compile Smart Boot Manager:
ECHO ------------------------------------------------------------------------

nasm "edd30.asm" -o "edd30.bin" -f bin -l "binaries\edd30.lst" -O99
@ECHO ON
@ECHO OFF

ECHO ------------------------------------------------------------------------

nasm "sbm.asm" -o "binaries\sbm.sys" -f bin -l "binaries\sbm.lst" -O99
@ECHO ON
@ECHO OFF

ECHO ------------------------------------------------------------------------

del *.h

cmd