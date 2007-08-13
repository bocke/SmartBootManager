; sbm.h
;
; header file for main.asm and loader.asm
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%define MAX_SBM_SIZE    30000              ; the max size of Smart Boot Manager

%define MAX_RECORD_NUM      32
%define MAX_FLOPPY_NUM      2
%define MAX_PASSWORD_LENGTH 16

%define PART_OFF        0x0600             ; partition table offset
                                           ; Smart Boot Manager kernel startup
%define SBM_SAVE_NBLKS  5

%ifndef STRUC_SBMK_HEADER
%define STRUC_SBMK_HEADER


struc struc_block_map
      .n_sects         resb 1
      .lba_addr        resd 1
      .end_of_struc
endstruc

%define SIZE_OF_STRUC_BLOCK_MAP struc_block_map.end_of_struc


%endif

