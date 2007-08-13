; ******************************************************

;	Name: Bootloader
;	Autor: Peter Kleissner
;	Version: 1.02
;	Date: Wednesday, 12th April 2006
;	last Update: Monday, 17th April 2006

;	For: ToasterOS BMS
;	         |
;                l--› MBR Version
;                l-----› Standalone
;	            |         |
;                   |         l---› FAT16
;                   |         l---› FAT32
;                   l
;                   l--› ISO Version

; ******************************************************

[bits 16]					; create a 16 Bit Code
CPU 386						; Assemble instructions up to the 386 instruction set



; disable Interrupts & clear the direction flag
cli
cld


; set the Stack to 0000h:Stack_Pointer
xor ebx,ebx
mov ss,bx
mov sp,7C00h

; set the Data Segments to 0000h (0000h:7C000h operating address)
xor ax,ax
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax



;(Table 00653)
;Values Bootstrap loader is called with (IBM BIOS):
;	CS:IP = 0000h:7C00h
;	DH = access
;	    bits 7-6,4-0: don't care
;	    bit 5: =0 device supported by INT 13
;	DL = boot drive
;	    00h first floppy
;	    80h first hard disk


; check if the drive is a floppy (since ToasterOS Server Business Edition pre deactivated)
test dl,80h
jz Drive_Error

; check if the drive is not supported by Interrupt 13h
;test dh,00100000b
;jnz Drive_Error

; store the boot drive
mov [Boot_Drive],edx




; load the default for the disk address packet
mov [dap_Size],byte 10h
mov [dap_Reserved],bl

; [ds:si] = disk address packet
mov si,disk_address_packet



; load the whole Master Boot Record into memory
mov [dap_Count],word 63
mov [Boot_Drive_Sector],ebx
mov [dap_LBA_low],ebx
mov [dap_LBA_high],ebx
mov [dap_Buffer],dword 00008000h

; interrupt 13h, function 42h: Extended Read
mov ah,42h
int 13h

jc Read_Error



; set the Data Segments to 8000h (0800h:0000h operating address)
mov ax,0800h
mov ds,ax
mov es,ax



; jump to the Smart Boot Manager Kernel
jmp 0800h:Smart_Boot_Manager_Kernel






Boot_Error:

; if boot partition isn't found

mov si,MSG_Boot_Error
jmp Public_Error



Drive_Error:

; if boot drive is a floppy

mov si,MSG_Drive_Error
jmp Public_Error



Read_Error:

; if there was an read error

mov si,MSG_Read_Error
;jmp Public_Error




; the public error handler (esi = specific text)
Public_Error:
call Print_Text

mov si,MSG_Reboot
call Print_Text

; reboot after a key press
xor ah,ah					; Function 00h: Get Keystroke
int 16h

; this code jumps to the BIOS reboot
db 0EAh
dw 0000h
dw 0FFFFh




; a function to write a text onto the screen (si = text)
Print_Text:

;mov ax,cs
;mov ds,ax					; ds = cs

mov bx,0007h					; Page Number = 0, Attribute = 07h
mov ah,0Eh					; function 0Eh: Teletype Output

cs lodsb					; load the first character

Next_Char:
int 10h
cs lodsb					; al = next character
or al,al					; last letter?
jnz Next_Char					; if not print next letter

ret




; Error Messages
MSG_Drive_Error		db	10, 13, "Invalid Boot-Drive", 0
MSG_Boot_Error		db	10, 13, "Boot Error", 0
MSG_Read_Error		db	10, 13, "Read Error", 0
MSG_Reboot		db	10, 13, "Press a key to restart", 0

Boot_Checksum	dd	"QDOS"





; Error routines entry points

times 1AFh-($-$$) db 0

jmp Boot_Error
jmp Read_Error



; language descriptions [unused]

times 1B5h-($-$$) db 0

Error_Message_1_length	db	0
Error_Message_2_length	db	0
Error_Message_3_length	db	0



; Disk Signature

times 440-($-$$) db 0

disk_signature		dd	0
			dw	0



; Partition Table

times 1BEh-($-$$) db 0


Partition_1
    Partition_1_bootable	db	80h
    Partition_1_Start_CHS	db	00h, 01h, 01h
    Partition_1_Type		db	04h
    Partition_1_End_CHS		db	0FFh, 0FEh, 0FFh
    Partition_1_Start_LBA	dd	63
    Partition_1_Sectors		dd	20160-63
Partition_2
    Partition_2_bootable	db	0
    Partition_2_Start_CHS	db	0, 0, 0
    Partition_2_Type		db	7h
    Partition_2_End_CHS		db	0, 0, 0
    Partition_2_Start_LBA	dd	20160
    Partition_2_Sectors		dd	40960
Partition_3
    Partition_3_bootable	db	0
    Partition_3_Start_CHS	db	0, 0, 0
    Partition_3_Type		db	0
    Partition_3_End_CHS		db	0, 0, 0
    Partition_3_Start_LBA	dd	0
    Partition_3_Sectors		dd	0
Partition_4
    Partition_4_bootable	db	0
    Partition_4_Start_CHS	db	0, 0, 0
    Partition_4_Type		db	0
    Partition_4_End_CHS		db	0, 0, 0
    Partition_4_Start_LBA	dd	0
    Partition_4_Sectors		dd	0
    

times 510-($-$$) db 0

Boot_Signature	dw	0AA55h
