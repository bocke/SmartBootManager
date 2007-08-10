; asmsyntax=nasm
; loader.asm
;
; Loader for Smart Boot Manager
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

%include "hd_io.h"
%include "knl.h"
%include "sbm.h"
%define RETRY_TIMES     3

        bits 16
        
        section .text
        
        org 0

start:
        cli
        jmp short main_start

;=================== For floppy FAT12 filesystem ======================
bsOEM       db "SBM3.7.1"               ; OEM String
bsSectSize  dw 512                      ; Bytes per sector
bsClustSize db 1                        ; Sectors per cluster
bsRessect   dw 1                        ; # of reserved sectors
bsFatCnt    db 2                        ; # of fat copies
bsRootSize  dw 224                      ; size of root directory
bsTotalSect dw 2880                     ; total # of sectors if < 32 meg
bsMedia     db 0xF0                     ; Media Descriptor
bsFatSize   dw 9                        ; Size of each FAT
bsTrackSect dw 18                       ; Sectors per track
bsHeadCnt   dw 2                        ; number of read-write heads
bsHidenSect dd 0                        ; number of hidden sectors
bsHugeSect  dd 0                        ; if bsTotalSect is 0 this value is
                                        ; the number of sectors
bsBootDrv   db 0                        ; holds drive that the bs came from
bsReserv    db 0                        ; not used for anything
bsBootSign  db 29h                      ; boot signature 29h
bsVolID     dd 0                        ; Disk volume ID also used for temp
                                        ; sector # / # sectors to load
bsVoLabel   db "SMART BTMGR"            ; Volume Label
bsFSType    db "FAT12   "               ; File System type

		jmp short main_start
;====================================================================

sbml_magic      dd  SBML_MAGIC     ; magic number = 'SBML', 4 bytes.
                                   ; it's abbr. of 'Smart Boot Manager Loader'
sbml_version    dw  SBML_VERSION   ; version, high byte is major version,
                                   ; low byte is minor version.
kernel_block_map times SIZE_OF_STRUC_BLOCK_MAP * 5 db 0

;
; dl = current driver id
;

main_start:
        xor ax, ax
        mov ss, ax
        mov sp, BOOT_OFF
        mov si, sp
        push ax
        pop es
        push ax
        pop ds
        sti
        cld
        mov di,PART_OFF
        mov cx,100h
        rep movsw
        jmp (PART_OFF/16):continue

continue:
        push cs
        pop ds

        push word KERNEL_SEG
        pop es


        lea si, [kernel_block_map]
	mov cx, SBM_SAVE_NBLKS              ; Only five knl blocks
	xor di, di

.read_knl_blk:
        push cx

        lodsb                               ; get sectors of this block
	mov cl, al
        lodsd                               ; get LBA addr of this block
        mov ebx, eax                        ;

        mov ax, ( INT13H_READ << 8 ) | 1 

	or cx, cx
	jz .read_end

.loop_read:
        call disk_access
        jc .read_failed

        add di, SECTOR_SIZE

	inc ebx
        loop .loop_read

	pop cx
	loop .read_knl_blk
	jmp short .check_knl

.read_end:
	pop cx

.check_knl:
; validate the kernel
        xor di, di
        cmp dword [es:di + struc_sbmk_header.magic], SBMK_MAGIC
        jne .bad_sbmk                      ; magic not match.
        cmp word [es:di + struc_sbmk_header.version], SBMK_VERSION
        jne .bad_sbmk                      ; version not match.
        
        mov cx, [es:di + struc_sbmk_header.total_size]
        xor bl, bl

.calc_checksum:                             ; calcuate the kernel's
        mov al, [es:di]                     ;
        add bl, al                          ; checksum value.
        inc di                              ;
        loop .calc_checksum                 ; it must be zero.
        
        or bl, bl
        jnz .bad_sbmk

        jmp KERNEL_SEG:0

.read_failed:
        pop cx

.bad_sbmk:
        lea si, [sbmk_bad]

; Draw string
.loop_disp:
        lodsb
        or al, al
        jz .end
        mov bx,7
        mov ah,0x0e
        int 0x10
        jmp short .loop_disp

.end:

        xor ah, ah
        int 0x16

        int 0x18                            ; boot next device.

halt:   jmp short halt

;==============================================================================
;disk_access ---- read / write sectors on disk
;input:
;      ah = function id, ( 02 = read, 03 = write )
;      al = number of sectors to be accessed
;      ebx = lba address
;      dl = drive id
;      es : di -> buffer
;output:
;      cf = 0 success
;      cf = 1 error
;==============================================================================
disk_access:
        pusha
        
        push ax
        push bx

        mov bx, 0x55aa
        mov ah, INT13H_EXT_INSTCHECK
        int 0x13                        ; Check if int13h extension is presents
        
        jc .no_ext
        cmp bx, 0xaa55
        jne .no_ext
        test cl, EXT_SUBSET_FIXED       ; Check if this drive supports extended
        jz .no_ext                      ; read/write

        pop bx
        pop ax
        
        add ah, 0x40                         ; ext read func id = 0x42
        lea si, [tmp_int13ext]
        xor ecx, ecx
        mov byte [si + struc_int13ext.pack_size], 0x10 ;
        mov [si + struc_int13ext.blk_num_high1], ecx ; clear and set
        mov [si + struc_int13ext.reserved], cl       ; some stuff.
        mov [si + struc_int13ext.reserved1], cl      ;

.retry_ext_read:
        mov [si + struc_int13ext.blk_count], al
        mov [si + struc_int13ext.buf_addr_off], di
        mov [si + struc_int13ext.buf_addr_seg], es
        mov [si + struc_int13ext.blk_num_low1], ebx
        
        push ax
        push dx
        int 0x13
        pop dx
        pop ax
        jnc .access_ok
        call reset_drive
        inc dh
        cmp dh, RETRY_TIMES                 ; retry 3 times
        jb .retry_ext_read
        jmp short .access_error

        
.no_ext:
        push dx
        push es
        push di
        mov ah, INT13H_GETINFO
        int 0x13
        mov [tmp_sectors], cl
        mov [tmp_heads], dh
        pop di
        pop es
        pop dx
        pop bx
        pop ax
        jc .access_error

        push ax
        push dx

;convert lba to chs.
	mov eax, ebx

        movzx ecx, word [tmp_sectors]          ; calculate sector:
        and cx, 0x3F
        
        xor edx, edx
        div ecx                                ; sector =  lba % sects_per_track + 1
        inc dx                                 ; lba1 = lba1 / sects_per_track
        mov cx, dx                             ;

        xor ebx, ebx                           ; calculate head and cylinder:
        mov bl, [tmp_heads]                    ; head = lba1 % num_of_heads
        inc bl                                 ; cylinder = lba1 / num_of_heads
        xor edx, edx
        div ebx                                ;
        
        mov bl, dl

        xchg al, ah                            ;
        shl al, 6                              ; fill cylinder and sector into
        or cx, ax                              ; cx
        
        pop dx
        pop ax

        mov dh, bl                             ; head number
        mov bx, di                             ; es : bx -> buffer
        xor di, di
        
.retry_read:
        push ax
        int 0x13
        pop ax
        jnc .access_ok
        call reset_drive
        inc di
        cmp di, RETRY_TIMES                 ; retry 3 times
        jb .retry_read

.access_error:
        stc
.access_ok:
        popa
        ret

;==============================================================================
;reset_drive ---- reset the drive
;input:
;      dl = drive id
;output:
;      cf = 0 success
;      cf = 1 error
;==============================================================================
reset_drive:
        pusha
        xor ax, ax
        int 0x13
        popa
        ret

sbmk_bad    db      0x07,"SBMK Bad!",0x0d,0x0a,0

        times 510-($-$$) db 0
                dw 0aa55h

	section .bss
tmp_sectors  resb 1
tmp_heads    resb 1
tmp_int13ext resb SIZE_OF_INT13EXT
