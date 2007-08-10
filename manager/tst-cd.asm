%define MAIN

%include "hd_io.h"
%include "macros.h"

	bits 16

	org 0x100

	section .text

start:

	lea si, [extparam_buf]
	mov dx, 0x9F

	mov ah, INT13H_EXT_GETINFO
	mov word [si + struc_extparam.pack_size], SIZE_OF_EXTPARAM
	push dx
	int 0x13
	pop dx

	mov si, int13ext
	mov [si + struc_int13ext.buf_addr_seg], ds

	mov ah, INT13H_EXT_READ
	int 0x13

	mov ax, 0x4c00
	int 0x21

int13ext	istruc struc_int13ext
	at struc_int13ext.pack_size,	db  SIZE_OF_INT13EXT
	at struc_int13ext.blk_count,	db  1
	at struc_int13ext.buf_addr_off, dw  disk_buf
	at struc_int13ext.buf_addr_seg, dw  0
	at struc_int13ext.blk_num_low1, dw  16
	at struc_int13ext.blk_num_low2, dw  0,0,0
		iend

	section .bss

extparam_buf	resb SIZE_OF_EXTPARAM
disk_buf	resb 2048
