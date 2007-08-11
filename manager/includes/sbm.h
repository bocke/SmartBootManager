; sbm.h
;
; header file for main.asm and loader.asm
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%define BR_GOOD_FLAG    0XAA55
%define BR_FLAG_OFF     0x01FE
%define PART_TBL_OFF    0x01BE

%define SECTOR_SIZE     0x200              ; size of a sector
%define CDSECTOR_SIZE   0x800              ; size of a CD-ROM sector

%define MAX_SBM_SIZE    30000              ; the max size of Smart Boot Manager

%define SIZE_OF_MBR     446                ; the size of master boot record

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

struc struc_sbml_header
      .jmp_cmd     resb 3               ; cli and jmp command.

;=================== For floppy FAT12 filesystem ======================
      .bsOEM       resb 8               ; OEM String
      .bsSectSize  resw 1               ; Bytes per sector
      .bsClustSize resb 1               ; Sectors per cluster
      .bsRessect   resw 1               ; # of reserved sectors
      .bsFatCnt    resb 1               ; # of fat copies
      .bsRootSize  resw 1               ; size of root directory
      .bsTotalSect resw 1               ; total # of sectors if < 32 meg
      .bsMedia     resb 1               ; Media Descriptor
      .bsFatSize   resw 1               ; Size of each FAT
      .bsTrackSect resw 1               ; Sectors per track
      .bsHeadCnt   resw 1               ; number of read-write heads
      .bsHidenSect resd 1               ; number of hidden sectors
      .bsHugeSect  resd 1               ; if bsTotalSect is 0 this value is
                                        ; the number of sectors
      .bsBootDrv   resb 1               ; holds drive that the bs came from
      .bsReserv    resb 1               ; not used for anything
      .bsBootSign  resb 1               ; boot signature 29h
      .bsVolID     resd 1               ; Disk volume ID also used for temp
                                        ; sector # / # sectors to load
      .bsVoLabel   resb 11              ; Volume Label
      .bsFSType    resb 8               ; File System type

      .reserved    resb 2
;====================================================================

      .magic           resd 1           ; magic number.
      .version         resw 1           ; version.

      .block_map       resb SIZE_OF_STRUC_BLOCK_MAP * 5
                                        ; block map for SBMK, 5 blocks allowed
endstruc

struc struc_sbmk_header
      .jmp_cmd         resd 1           ; jmp and nop command.
      .magic           resd 1           ; magic number.
      .version         resw 1           ; version.
      .total_size      resw 1           ; the size of kernel code.
      .compressed_addr resw 1           ; the address of compressed part
      .checksum        resb 1           ; checksum value.
      .sectors         resb 1           ;
      .drvid           resb 1           ;
      .block_map       resb SIZE_OF_STRUC_BLOCK_MAP * 5
                                        ; block map for SBMK, 5 blocks allowed
      .reserved1       resw 1           ;

      .flags           resb 1           ; kernel flags. 
      .delay_time      resb 1           ; delay time ( seconds )
      .direct_boot     resb 1           ; >= MAX_RECORD_NUM means no
                                        ; direct boot.
      .default_boot    resb 1           ; the record number will
                                        ; be booted after the
                                        ; delay time is up or ESC
                                        ; key is pressed.
      .root_password   resd 1           ; root password.

      .bootmenu_style  resb 2
      .cdrom_ioports   resw 2
      .y2k_last_year   resw 1
      .y2k_last_month  resb 1
      .reserved2       resb 3
endstruc

struc struc_sbmk_data
      .boot_records    resb MAX_RECORD_NUM * SIZE_OF_BOOTRECORD
      .sbml_codes      resb SIZE_OF_MBR
      .previous_mbr    resb SECTOR_SIZE

      .boot_menu_pos   resw 1
      .main_menu_pos   resw 1
      .record_menu_pos resw 1
      .sys_menu_pos    resw 1
endstruc

struc struc_sbmt_header
      .magic           resd 1           ; magic number.
      .reserved        resw 1           ;
      .lang            resb 6           ; language info.
      .version         resw 1           ; theme version.
      .size            resw 1           ; theme size.
endstruc


%endif

