%include "helptool.h"

%macro debug_iprint 1+
%ifdef DEBUG
	push ds

	push cs
	pop ds
	printf %1
	pop ds
%endif
%endmacro

%macro debug_print 1+
%ifdef DEBUG
	push ds
	push cs
	pop ds
	printf %1
	pop ds
%endif
%endmacro


%macro print_stat 2+ 
%ifdef DEBUG
	pusha
	mov al,%1
	call set_stat_buff
	%if %0 > 1
		debug_print %2
	%endif
	popa
%endif
%endmacro


%ifdef DEBUG
%include "printf.h"

	section .text
proc set_stat_buff
	mov di, STAT_BUF
	if {test al, 0x80},nz
		mov si,__BSY   ; busy
		mov cx,4
		rep movsb
	endif
	if {test al, 0x40},nz
		mov si,__RDY   ; ready
		mov cx,4
		rep movsb
	endif
	if {test al, 0x20},nz
		mov si,__DF   ; write fault (old name)
		mov cx,7
		rep movsb
	endif
	if {test al, 0x10},nz
		mov si,__SKC  ; service
		mov cx,8
		rep movsb
	endif
	if {test al, 0x08},nz
		mov si,__DRQ   ; data request
		mov cx,4
		rep movsb
	endif
	if {test al, 0x04},nz
		mov si,__CRR  ; corrected
		mov cx,4
		rep movsb
	endif
	if {test al, 0x02},nz
		mov si,__IDX   ; index
		mov cx,4
		rep movsb
	endif
	if {test al, 0x01},nz
		mov si,__ERR   ; error
		mov cx,4
		rep movsb
	endif
	mov byte [di],0
endp
	section .data
__BSY   db "BSY "
__RDY   db "RDY "
__DF   db "DF/WFT "
__SKC   db "SKC/SRV "
__DRQ   db "DRQ "
__CRR  db "CRR "
__IDX   db "IDX "
__ERR   db "ERR "
	section .text
%endif
