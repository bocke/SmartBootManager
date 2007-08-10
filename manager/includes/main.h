; main.h
;
; header file for main.asm main-cmds.asm main-utils.asm
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%define KNLFLAG_FIRSTSCAN   0x01
%define KNLFLAG_SECURITY    0x02
%define KNLFLAG_NOINT13EXT  0x04
%define KNLFLAG_NOCDROM     0x08

%define KNLFLAG_REMLAST     0x10
%define KNLFLAG_ONLYPARTS   0X20
%define KNLFLAG_COMPRESSED  0x80

%define BMSTYLE_FULL        0
%define BMSTYLE_NOFLAGS     1
%define BMSTYLE_NONUMBER    2
%define BMSTYLE_NOTYPE      3

