; macros.h
;
; some nasm macros that simplify the coding.
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%ifndef DEFINE_MACROS
%define DEFINE_MACROS

%macro retz 0
       jnz %%skip
       ret
%%skip:
%endmacro

%define jmpz  jz near
%define jmpnz jnz near
%define jmpe  je near
%define jmpne jne near
%define jmpc  jc near
%define jmpnc jnc near
%define jmpa  ja near
%define jmpna jna near
%define jmpb  jb near
%define jmpnb jnb near


%if 0
%macro jmpz 1
       jnz %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpnz 1
       jz %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpe 1
       jne %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpne 1
       je %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpc 1
       jnc %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpnc 1
       jc %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpb 1
       jnb %%skip
       jmp %1
%%skip:
%endmacro

%macro jmpnb 1
       jb %%skip
       jmp %1
%%skip:
%endmacro

%endif

%endif
