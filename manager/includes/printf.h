%ifndef _PRINTF_H
%define _PRINTF_H
%include "helptool.h"

%assign PRINT_EOL 1

%macro push_string 1+
	section .data
%%str	db	%1,0
	section .text
	push word %%str
%endmacro

%macro printf 1-*

	pusha
	%assign rargc 0
	%if %0 >1
	%rotate -2
	%assign argc %0-1
	%rep argc
		%ifidn %1,byte
	     		push byte %2
			%rotate -1
			%assign argc argc-1
			%assign rargc rargc+1
	    	%elifidn %1,word
	    		push word %2
			%rotate -1
			%assign argc argc-1
			%assign rargc rargc+1
	    	%elifidn %1,dword
	        	push dword %2
			%rotate -1
			%assign argc argc-1
			%assign rargc rargc+2
		%elifstr %2
			push_string %2
			%assign rargc rargc+1
	    	%else
	        	push word %2
			%assign rargc rargc+1
    	    	%endif
		%rotate -1
		%assign argc argc-1
		%if argc <=0
			%exitrep
		%endif
	%endrep
	%rotate 1
	%endif
	%ifstr %1
		push_string %1
	%else
		push word %1
	%endif
	%assign rargc rargc+1
	call __printf
	add sp, (rargc) *2
	popa
%endmacro

	section .text
	
%define n           bp+6
%define strp        bp+4

;Proc        itoa
itoa:

            push bp                 ;Set up stack frame
            mov bp,sp
            pusha                   ;Save all registers

            mov ax,[n]              ;AX = n
            mov di,[strp]           ;DI = string pointer

            test ax,ax              ;Negative?
            jge .p1_noneg
            mov byte[ di],'-'       ;Store minus sign
            inc di
            neg ax                  ;Make it positive

.p1_noneg:   xor cx,cx               ;Zero CX
            test ax,ax              ;Check for zero
            jnz p1_nozero

            push byte '0'                ;Push a zero
            inc cx                  ;One digit
            jmp p1_ploop

p1_nozero:  mov si,10               ;SI = 10

.p1_dloop:   xor dx,dx               ;Divide by 10
            div si
            mov bl,dl               ;Remainder in BL
            add bl,30h              ;Convert to digit
            push bx                 ;Push digit
            inc cx
            test ax,ax              ;Loop back
            jnz .p1_dloop

p1_ploop:   pop ax                  ;Pop digit
            mov [di],al             ;Store digit
            inc di
            loop p1_ploop           ;Loop back

            mov byte[ di],0         ;Add the null byte

            popa                    ;Restore registers
            pop bp                  ;Delete stack frame
            ret 4                   ;Return

;EndP        itoa

;****************** ltoa() -- Convert long to string
;void ltoa(long n, char *strp);

;Proc        ltoa
ltoa:

            push bp                 ;Set up stack frame
            mov bp,sp
            pusha                   ;Save all registers

            mov di,[strp]           ;DI = string pointer
            mov dx,[n+2]            ;DX:AX = n
            mov ax,[n]
            test dx,dx              ;DX = 0, use itoa
            jnz p1_chkn
            cmp ax,8000h
            jnb p1_chkn

p1_itoa:    push ax
	    push di              ;Convert with itoa
            call itoa
            jmp p1_done_l             ;Return

p1_chkn:    cmp dx,-1               ;DX = -1 and AX <> 0, use itoa
            jne p1_strp
            cmp ax,8000h
            jae p1_itoa

p1_strp:    test dx,dx              ;Negative?
            jge .p1_noneg
            mov byte[ di],'-'       ;Store minus sign
            inc di
            neg dx                  ;Make it positive
            neg ax
            sbb dx,0

.p1_noneg:   mov bx,50000            ;Divide by 100000
            div bx
            xor bx,bx               ;Zero BX
            shr ax,1
            adc bx,0                ;BX = rem flag
            push bx
	    push dx              ;Save BX, DX

            test ax,ax              ;Check for zero
            jz p1_cont

            xor cx,cx               ;Zero CX
            mov si,10               ;SI = 10

.p1_dloop:   xor dx,dx               ;Divide by 10
            div si
            mov bl,dl               ;Remainder in BL
            add bl,30h              ;Convert to digit
            push bx                 ;Push digit
            inc cx
            test ax,ax              ;Loop back
            jnz .p1_dloop

.p1_ploop:   pop ax                  ;Pop digit
            mov [di],al             ;Store digit
            inc di
            loop .p1_ploop           ;Loop back

p1_cont:    pop ax
	    pop bx               ;Restore low data
            xor dx,dx               ;Zero DX
            test bx,bx              ;Check for high part
            jz p1_nohigh

            add ax,50000            ;Add in 50000
            adc dx,0

p1_nohigh:  mov si,10               ;SI = 10
            mov cx,5                ;5 digits
            jmp .p1_skip1

.p1_dloopb:  xor dx,dx               ;Zero DX
.p1_skip1:   div si                  ;Divide by 10
            mov bl,dl               ;Remainder in BL
            add bl,30h              ;Convert to digit
            push bx                 ;Push digit
            loop .p1_dloopb          ;Loop back

            mov cx,5                ;5 digits

p1_ploopb:  pop ax                  ;Pop digit
            mov [di],al             ;Store digit
            inc di
            loop p1_ploopb          ;Loop back

            mov byte[ di],0         ;Add the null byte

p1_done_l:    popa                    ;Restore registers
            pop bp                  ;Delete stack frame
            ret 6                   ;Return

;EndP        ltoa

;Proc        PUT_CHAR
PUT_CHAR:

            pusha                   ;Save registers
%ifdef use_dos
	    xchg dx,ax              ;STDOUT output, DL = char
            mov ah,2
            int 21h                 ;DOS call
%else
	    mov ah, 0eh
	    sub bx,bx
	    int 10h
%endif
            popa                    ;Restore registers
            ret                     ;Return

;EndP        PUT_CHAR




;****************** printf() -- Print formatted string
;void printf(char *fmt, void *args);

%define fmt         bp+4
%define args        bp+6

	section .bss
PRT_BUF	resb	20
STAT_BUF resb	40
	section .text
__printf:

            push bp                 ;Set up stack frame
            mov bp,sp
            pusha                   ;Save all registers

            mov si,[fmt]            ;SI = string pointer
            lea bx,[args]           ;BX = arg pointer

p1_loop:    lodsb                   ;Get char
            test al,al              ;Check for null
            jz p1_done
            cmp al,'%'              ;Check for '%'
            je p1_proc
	    cmp al,'\'
	    je p1_esc
p1_putc:    call PUT_CHAR           ;Output char
            jmp p1_loop             ;Loop back

p1_esc:	    lodsb
	    test al,al
	    jz p1_done
	    cmp al,"\"
	    je p1_putc
	    cmp al,"n"
	    je p1_eol
	    jmp p1_loop
p1_eol:
	    mov al,13
	    call PUT_CHAR
	    mov al,10
	    call PUT_CHAR
	    jmp p1_loop
	    
p1_proc:    lodsb                   ;Get char
            test al,al              ;Check for null
            jz p1_done
            cmp al,'%'              ; %% = percent
            je p1_putc
            cmp al,'d'              ; %d = integer
            je p1_int
            cmp al,'l'              ; %l = long int
            je p1_long
            cmp al,'x'              ; %x = hex
            je p1_hex
	    cmp al,'h'		    ; %h = byte hex
	    je p1_bhex
            cmp al,'c'              ; %c = char
            je NEAR p1_char
            cmp al,'s'              ; %s = string
            je NEAR p1_str
	    cmp al,'b'		    ; %b = binary bits 8bit
	    je NEAR p1_bin8
	    cmp al,'B'		    ; %B = binary bits 16bit
	    je NEAR p1_bin16
            jmp p1_loop             ;Invalid, ignore

p1_done:    popa                    ;Restore registers
            pop bp                  ;Delete stack frame
            ret                    ;Return

p1_long:    lodsb                   ;Get char
            test al,al              ;Check for null
            jz p1_done
            cmp al,'d'              ; %ld = long integer
            je p1_lint
            cmp al,'x'              ; %lx = long hex
            je p1_lhex
            jmp p1_loop             ;Invalid, ignore

p1_int:     push word[ss:bx]          ;itoa(*bx, PRT_BUF);
            push word PRT_BUF
            call itoa
            inc bx                  ;Advance pointer
            inc bx
            mov di,PRT_BUF   ;Print alpha string
            jmp p1_alpha

p1_lint:    push word[ss:bx+2]
            push word[ss:bx]          ;ltoa(*bx, PRT_BUF);
            push word PRT_BUF
            call ltoa
            add bx,4                ;Advance pointer
            mov di,PRT_BUF   ;Print alpha string
            jmp p1_alpha

p1_hex:     mov ax,[ss:bx]             ;AX = arg
            call p1_chex            ;Convert to hex
            inc bx                  ;Advance pointer
            inc bx
            jmp p1_loop             ;Loop back
p1_bhex:
	    mov ax,[ss:bx]
	    mov cx,2
	    ror al,byte 4
	    call p1_hloop
	    inc bx
	    inc bx
	    jmp p1_loop

p1_lhex:    mov ax,[ss:bx+2]           ;AX = high word
            call p1_chex            ;Convert to hex
            mov ax,[ss:bx]             ;AX = low word
            call p1_chex            ;Convert to hex
            add bx,4                ;Advance pointer
            jmp p1_loop             ;Loop back
p1_char:    mov al,[ss:bx]             ;Output char
            call PUT_CHAR
            inc bx                  ;Advance pointer
            jmp p1_loop             ;Loop back

p1_str:
	    mov cx,[ss:bx]
	    add bx,2
.again:
	    xchg bx,cx
	    mov al,[ss:bx]             ;Get char
            inc bx                  ;Advance pointer
	    xchg bx,cx
            test al,al              ;Check for null
            jz p1_sdone
            call PUT_CHAR           ;Output char
            jmp .again              ;Loop back

p1_sdone:   jmp p1_loop             ;Return to main loop

p1_bin8:
	    mov cx,8
	    mov dh,[ss:bx]
	    jmp p1_bin
p1_bin16:	    
	    mov cx,16
	    mov dx,[ss:bx]           ;AX = high word
p1_bin:	    
p1_bin_loop:
	    shl dx,1
	    setc al
	    add al,'0'
	    call PUT_CHAR
	    loop p1_bin_loop
            add bx,2                ;Advance pointer
            jmp p1_loop             ;Loop back


p1_alpha:   mov al,[di]             ;Get char
            test al,al              ;Check for null
            jz p1_sdone
            call PUT_CHAR           ;Output char
            inc di                  ;Advance pointer
            jmp p1_alpha            ;Loop back


p1_chex:    mov cx,4                ;4 hex digits
            xchg al,ah              ;Reverse the order
            ror ah,cl               ;of the hex digits
            ror al,cl               ;in AX

p1_hloop:   push ax                 ;Save AX
            and al,0Fh              ;Keep 4 bits
            cmp al,0Ah              ;Compute the hex digit,
            sbb al,69h              ;using Improved Allison's Algorithm
            das
            call PUT_CHAR           ;Output char
            pop ax                  ;Restore AX
            shr ax,4                ;Shift it over
            loop p1_hloop           ;Loop back
            ret                     ;Return

%endif
