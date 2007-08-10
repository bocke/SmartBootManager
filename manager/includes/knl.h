; knl.h
;
; header file for knl.asm
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%define MAX_NAME_LENGTH   15
%define MAX_KEYSTROKES    13

%define FAT16_DRVID_OFF   0x24               ; drive id offset in fat16
%define FAT16_HIDSEC_OFF  0x1C               ; hidden sector offset in fat16
%define FAT16_EXTBRID_OFF 0x26               ; EXBRID offset in fat16

%define FAT32_DRVID_OFF   0x40
%define FAT32_HIDSEC_OFF  0x1C
%define FAT32_EXTBRID_OFF 0x42

%define EXTBRID           0x29               ; ext boot record id for fat

%define INFOFLAG_SCHEDULED  0x8000       ; 1000,0000,0000,0000B
%define INFOFLAG_HAVEKEYS   0x4000       ; 0100,0000,0000,0000B
%define INFOFLAG_SWAPDRVID  0x2000       ; 0010,0000,0000,0000B
%define INFOFLAG_AUTOACTIVE 0x1000       ; 0001,0000,0000,0000B
%define INFOFLAG_ACTIVE     0x0800       ; 0000,1000,0000,0000B
%define INFOFLAG_AUTOHIDE   0x0400       ; 0000,0100,0000,0000B
%define INFOFLAG_HIDDEN     0x0200       ; 0000,0010,0000,0000B
%define INFOFLAG_LOGICAL    0x0100       ; 0000,0001,0000,0000B

%define INFOFLAG_ISDRIVER   0x0080       ; 0000,0000,1000,0000B
%define INFOFLAG_ISSPECIAL  0X0008       ; 0000,0000,0000,1000B

%define SPREC_BOOTPREV      0
%define SPREC_QUIT          1
%define SPREC_POWEROFF      2
%define SPREC_RESTART       3

%define NUM_OF_SPREC        4

%define NUM_OF_INFOFLAGS    9

; structure for boot record, including removable drives and partitions
struc struc_bootrecord
      .flags           : resw 1  ; type flags of this record, see INFOFLAG_x
      .drive_id        : resb 1  ; drive id = 0 to 255
                                 ; partition id used in linux,
      .part_id         : resb 1  ; 1-4 for primary partitions,
                                 ; > 5 for logical partitions,
                                 ; 0 for driver or special bootrecord.
      .type            : resb 1  ; partition type, = 0 : not a partition
      .reserved        : resb 1  ;
      .father_abs_addr : resd 1  ; father's LBA address
      .abs_addr        : resd 1  ; partition's abs LBA address
      .password        : resd 1  ; password of this record
      .schedule_time   : resd 1  ; schedule time
      .name            : resb 16 ; name of this record, zero ending.
      .keystrokes      : resw 13 ; keystrokes to be preloaded.
      .end_of_struc
endstruc

; structure for partition record
struc struc_partition
      .state           : resb 1  ; = 0 : inactive; = drive id : active
      .start_head      : resb 1  ; start chs address of the partition
      .start_cs        : resw 1  ;
      .type            : resb 1  ; equal to the same item in struc_bootrecord
      .end_head        : resb 1  ; end chs address of the partition
      .end_cs          : resw 1  ;
      .relative_addr   : resd 1  ; the relative address of this partition
      .sectors         : resd 1  ; the number of sectors of the partition
      .end_of_struc
endstruc

%define SIZE_OF_BOOTRECORD (struc_bootrecord.end_of_struc)
%define SIZE_OF_PARTITION  (struc_partition.end_of_struc)

