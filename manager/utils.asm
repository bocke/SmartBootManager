; asmsyntax=nasm
;
; utils.asm
;
; Some utility functions
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

;=============================================================================
;itoa ---- convert integer to ascii string (the string is zero ending)
;input:
;      ax = the integer to be converted
;      cl = max length of the integer
;      es:di -> buffer
;output:
;      none
;=============================================================================
itoa:
        pusha
        xor ch, ch
        add di, cx
        mov byte [di], 0
        mov bx, 10
.loop_itoa:
        xor dx, dx
        dec di
        div bx
        add dl, '0'
        mov [di], dl
        dec cx
        or ax, ax
        jz .end_itoa
        or cx, cx
        jnz .loop_itoa
.end_itoa:
        or cx, cx
        jz .end
.loop_fillspace:
        dec di
        mov byte [di], ' '
        loop .loop_fillspace
.end:
        popa
        ret

;=============================================================================
;atoi ---- convert ascii string to integer (the string is zero ending)
;input:
;      ds:si -> buffer
;output:
;      ax = convert result ( <= 65535 )
;=============================================================================
atoi:
	push bx
	push cx

	xor bx, bx
	xor ax, ax

.loop_conv:
	lodsb
	or al, al
	jz .end
	sub al, '0'
	cmp al, 10
	jae .end

	mov cx, bx
        shl bx, 3                   ; bx = bx * 10
        shl cx, 1                   ;
        add bx, cx                  ;
	add bx, ax
	jmp short .loop_conv

.end:
	mov ax, bx
	dec si
	pop cx
	pop bx
	ret

;=============================================================================
;strlen ---- Count Length of a zero ending string
;input:
;      ds:si -> string
;output:
;      cx = length (not include the ending zero)
;=============================================================================
strlen:
        push ax
        xor cx,cx

        or si,si
        jz .end

        push si
        cld
.loop_count:
        inc cx
        lodsb
        or al, al
        jnz .loop_count

        dec cx
        pop si

.end:
        pop ax
        ret

;=============================================================================
;strlen_hl ---- Count Length of a zero ending string (ignore ~ chars)
;input:
;      ds:si -> string
;output:
;      cx = length (not include the ending zero)
;=============================================================================
strlen_hl:
        push ax
        xor cx,cx

        or si,si
        jz .end

        push si
        cld
.loop_count:
        inc cx

.loop_nocount:
        lodsb
        cmp al, '~'
        je .loop_nocount
        or al, al
        jnz .loop_count

        dec cx
        pop si

.end:
        pop ax
        ret

;=============================================================================
;strchr ---- search a char in a string
;input:
;      al = the char to be searched
;      cx = length of the string
;      es:di -> string
;output:
;      cf = 0 the char was found
;            cx = offset of the char
;      cf = 1 the char was not found
;            cx = length of the string
;=============================================================================
strchr:
        push bx
        push di
        mov bx,cx
        cld
        repnz scasb
        pop di
        xchg bx, cx
        jnz .not_found
        sub cx, bx
        dec cx
        pop bx
        clc
        ret
.not_found:
        pop bx
        stc
        ret

;=============================================================================
;strncpy ---- copy strings
;input:
;      cx = max number of chars to be copied
;      ds:si -> source string
;      es:di -> dest string
;output:
;      cx = number of chars actually copied (not include the ending zero char)
;      es:di -> point to next char of the end of dest string and set it to
;               zero
;=============================================================================
strncpy:
        push si
        push ax
        push bx
        mov bx, cx
        cld
.loop_copy:
        lodsb
        stosb
        or al, al
        jz .end
        loop .loop_copy
        xor al, al
        stosb
.end:
        dec di
        xchg bx, cx
        sub cx, bx
        pop bx
        pop ax
        pop si
        ret

;=============================================================================
;strcpy ---- copy strings
;input:
;      ds:si -> source string
;      es:di -> dest string
;output:
;      es:di -> point to next char of the end of dest string and set it to
;               zero
;=============================================================================
strcpy:
        push si
        push ax

        cld
.loop_copy:
        lodsb
        stosb
        or al, al
	jnz .loop_copy

        dec di
        pop ax
        pop si
        ret


;=============================================================================
;calc_password ---- calculate the password
;input:
;      ds:si -> the pasword string (zero ending)
;      cx = max length of the password
;output:
;      dx:ax = the encrypted password (32 bits)
;=============================================================================
calc_password:
        push si
        xor edx, edx
        xor eax, eax
        cld
.loop_calc:
        lodsb
        or al, al
        jz .end
        not al
        rol al, 4
        add edx, eax
        rol edx, 2
        loop .loop_calc
.end:
        mov ax, dx
        ror edx, 16
        pop si
        ret

;=============================================================================
;htoa ---- hex to ascii
;input:
;     ax = hex number
;     cl = length of hex number (1 to 4)
;     es:di -> buffer to store ascii string
;output:
;     es:di -> ascii string
;=============================================================================
htoa:
        pusha
        xor ch, ch
        add di, cx
        mov byte [di], 0

.loop_conv:
	push ax                 ;Save AX
	and al,0Fh              ;Keep 4 bits
	cmp al,0Ah              ;Compute the hex digit,
	sbb al,69h              ;using Improved Allison's Algorithm
	das
	dec di
	mov [di], al
	pop ax                  ;Restore AX
	shr ax,4                ;Shift it over
        loop .loop_conv

        popa
        ret

;=============================================================================
;atoh ---- ascii to hex
;input:
;     ds:si -> buffer
;output:
;     ax = hex
;     ds:si -> end of the hex number
;=============================================================================
atoh:
	push bx

	xor bx, bx
	xor ax, ax
.loop_conv:
	lodsb
	or al, al
	jz .end

	sub al, '0'
	cmp al, 10
	jb .ok
	sub al, 'A'-'0'-10
	cmp al, 16
	jb .ok
	sub al, 'a'-'A'
	cmp al, 16
	jae .end

.ok:
	shl bx, 4
	add bx, ax
	jmp .loop_conv

.end:
	dec si
	mov ax, bx
        pop bx
        ret

;=============================================================================
;count_lines ---- count how many lines in a string.
;input:
;      ds:si -> string
;output:
;      ch = number of lines
;      cl = max line length
;=============================================================================
count_lines:
        push si
        push bx
        push ax

        cld

        xor cx, cx
        xor bx, bx

        or si, si
        jz .end

        inc ch
.loop_count:
        lodsb
        or al, al
        jz .ending

        cmp al, 0x0d
        je .new_line

        inc bl
        jmp short .loop_count

.new_line:
        inc ch

        mov bh, bl
        xor bl, bl
        cmp bh, cl
        jbe .loop_count
        mov cl, bh
        jmp short .loop_count

.ending:
        cmp bl, cl
        jbe .end
        mov cl, bl

.end:
        pop ax
        pop bx
        pop si
        ret

;=============================================================================
; power_off ---- turn the power off
;input:
;       none
;output:
;       never return if successful.
;       cf = 1 on error.
;=============================================================================
power_off:
        pusha
	call check_apm_bios
        jc .end

        mov ax, 0x5301
        xor bx, bx
        int 0x15
        jc .end

        mov ax, 0x5380
        mov bh, 0x8c
        int 0x15

        mov ax, 0x40
        mov bx, 0xd8
        push ds
        mov ds, ax
        or byte [ds:bx], 0x10
        pop ds

        mov ax, 0x5307
        mov bx, 1
        mov cx, 3
        int 0x15

.end:
        popa
        ret


;=============================================================================
; check_apm_bios ---- check if the apm bios present
; output:
;	cf = 1 error, cf = 0 ok
;=============================================================================
check_apm_bios:
        pusha
        mov ax, 0x5300
        xor bx, bx
        int 0x15                                 ; check if apm present
	jc .end
	cmp bx, 0x504D
	jnz .none
	test cx, 1
	jnz .end
.none:
	stc
.end:
	popa
	ret

;=============================================================================
; leap_year ---- check if a year is leap a year
; input:
;      ax = year
; output:
;      cf = 1, it's a leap year
;      cf = 0, not a leap year
;=============================================================================
leap_year:
       pusha
       mov cx, 400
       xor dx, dx 
       push ax
       div cx
       pop ax
       or dx, dx
       jz .isleap

       mov cx, 100
       xor dx, dx
       push ax
       div cx
       pop ax
       or dx, dx
       jz .noleap

       xor dx, dx
       mov cx, 4
       div cx
       or dx, dx
       jz .isleap

.noleap:
       clc
       popa
       ret

.isleap:
       stc
       popa
       ret

;=============================================================================
; day_in_week
; input:
;      ax = year
;      dh = month
;      dl = day
; output:
;      cx = day in week
;=============================================================================
day_in_week:
	push ax
	push bx
	push dx

	push dx

	dec ax
	mov cx, ax
	xor dx, dx
	push ax
	mov bx, 4
	div bx
	add cx, ax
	pop ax

	xor dx, dx
	push ax
	mov bx, 100
	div bx
	sub cx, ax
	pop ax

	xor dx, dx
	push ax
	mov bx, 400
	div bx
	add cx, ax
	pop ax

	inc ax
	pop dx

	movzx bx, dh
	mov bl, [days_in_month_norm-1+bx]
	add cx, bx 

	call leap_year
	jnc .norm
	cmp dh, 3

	jb .norm
	inc cx

.norm:
	xor dh, dh
	add cx, dx

	mov ax, cx
	xor dx, dx
	mov cx, 7
	div cx
	mov cx, dx

	pop dx
	pop bx
	pop ax
	ret

days_in_month_norm db  0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5

;=============================================================================
; bcd_to_bin ---- convert bcd to binary
; input: ax = bcd number
; output: ax = binary number
;=============================================================================
bcd_to_bin:
       push bx
       push cx
       push dx
       push si

       lea si, [.mul_num]
       mov cx, 4
       xor bx, bx

.loop_conv:
       push ax
       and ax, 0x000f
       mov dx, [si]
       mul dx
       add bx, ax
       pop ax
       shr ax, 4
       inc si
       inc si
       loop .loop_conv

       mov ax, bx

       pop si
       pop dx
       pop cx
       pop bx
       ret

.mul_num  dw 1, 10, 100, 1000

;=============================================================================
; bcd_to_str ---- convert bcd to string
; input: ax = bcd number
;        cl = length (0 to 4)
;        es:di -> buffer
; output: none
;=============================================================================
bcd_to_str:
       pusha
       push cx
       mov bx, ax
       mov al, 4
       mul cl
       mov cl, al
       ror bx, cl
       pop cx

.loop_conv:
       or cl, cl
       jz .end
       rol bx, 4
       mov ax, bx
       and al, 0x0f
       add al, '0'
       stosb
       dec cl
       jmp .loop_conv

.end:
       xor al, al
       stosb
       popa
       ret

;=============================================================================
; reboot ---- reboot the computer
; input:
;	none
;=============================================================================
reboot:
       mov bx, 0x40
       push bx
       pop ds
       mov ax, 0x1234
       mov [0x0072], ax
       jmp 0xFFFF:0x0000

;=============================================================================
; bioskey ---- BIOS keyboard func
;=============================================================================
bioskey:
       mov byte [utils_tmp.kbd_work], 0
       or ah, ah
       je .post_trans
       cmp ah, 0x01
       je .post_trans
       cmp ah, 0x10
       je .post_trans
       cmp ah, 0x11
       jne .call_int16

.post_trans:
       inc byte [utils_tmp.kbd_work]

.call_int16:
       int 0x16
       pushf

       cmp byte [utils_tmp.kbd_work], 0
       jz .end

       push cx
       push si
       mov cx, [keymap.number]
       mov si, [keymap.data]
       or cx, cx
       jz .end_trans

.loop_trans:
       cmp ax, [si]
       jne .loop_next
       mov ax, [si+2]
       jmp short .end_trans
.loop_next:
       add si, 4
       loop .loop_trans
.end_trans:
       pop si
       pop cx
.end:
       popf       
       ret

;=============================================================================
; check_keyevent ---- check if keyboard is pressed
; input:
;	none
; output:
;	ax = keyevent (0 = no key)
;=============================================================================
check_keyevent:
	push bx

	mov bh, [utils_tmp.kbd_last_shift]
	call .check_stat_key
	mov bl, al
	mov [utils_tmp.kbd_last_shift], al

	call .check_norm_key
	or ax, ax
	jz .no_norm_key

	mov byte [utils_tmp.kbd_bypass_next_shift], 1
.end:
	pop bx
	ret

.no_norm_key:
	xor ax, ax
	cmp bl, bh
	je .end

	push cx
	mov cx, 0x0101

.loop_check_keys:
	push bx
	and bx, cx
	cmp bh, bl
	pop bx

	je .no_this_key

	test bl, cl
	jz .release
	mov ah, (EVTCODE_COMMAND | EVTCODE_KEYPRESS)
	jmp short .key_ok

.release:
	mov ah, (EVTCODE_COMMAND | EVTCODE_KEYRELEASE)

.key_ok:
	mov al, cl
	jmp short .end_check_keys

.no_this_key:
	shl cx, 1
	or cl, cl
	jnz .loop_check_keys

.end_check_keys:
	or ax, ax
	jz .end_stat

	test al, kbStateKeysMask
	jnz .dont_bypass

	cmp byte [utils_tmp.kbd_bypass_next_shift], 0
	jz .end_stat

	xor ax, ax

.dont_bypass:
	mov byte [utils_tmp.kbd_bypass_next_shift], 0

.end_stat:
	pop cx
	pop bx
	ret

.check_stat_key:
	push bx
	mov ah, 2
	or ah, [keyboard_type]
	call bioskey
	pop bx
	ret

.check_norm_key:
	push bx
        mov ah,1                                        ; if no key pressed
        or ah, [keyboard_type]
        call bioskey                                    ; go back to check
	jz .no_key
	mov ah, [keyboard_type]
	call bioskey
	pop bx
	ret

.no_key:
	xor ax, ax
	pop bx
	ret

;=============================================================================
;get_realtime ---- get the machine real time in minutes
;input:
;      none
;output:
;      cf = 0 success, ax = real time in minutes, dx = day (set a bit)
;      cf = 1 failed
;=============================================================================
get_realtime:
        push bx
        push cx

        mov ah, 0x04
        int 0x1a
        jc .end

        movzx ax, dh
        call bcd_to_bin
        mov dh, al
        mov al, dl
        call bcd_to_bin
        mov dl, al

        mov ax, cx
        call bcd_to_bin

        call day_in_week

        mov dx, 1
        shl dx, cl

        push dx
        mov ah, 0x02
        int 0x1a
        pop dx
        jc .end

        movzx ax, ch
        call bcd_to_bin
        mov ch, al

        mov al, cl
        call bcd_to_bin
        mov cl, al

;convert hour and minute into minute
        mov al, 60
        mul ch
        xor ch, ch
        add ax, cx

        clc
.end:
        pop cx
        pop bx

        ret


;=============================================================================
; get_current_time_string ---- get current time string
; input: al = show method, es:di -> buffer
;=============================================================================
get_current_time_string:
       pusha
       or al, al
       jz .end

       mov ah, 0x02
       int 0x1a
       jc .end

       mov bx, cx

       mov cx, 2

       movzx ax, bh
       call bcd_to_str
       add di, cx
       mov al, ':'
       stosb

       mov al, bl
       call bcd_to_str
       add di, cx
       
.end:
       xor al, al
       stosb
       popa
       ret      


;=============================================================================
; get_current_date_string ---- get current date string
; input: al = show method, es:di -> buffer
;        the method of show date:
;           0 = don't show date
;           1 = day mm-dd-yyyy
;           2 = day yyyy-mm-dd
;           3 = day dd-mm-yyyy
; output: none
;=============================================================================
get_current_date_string:
       pusha

       or al, al
       jz .end

       push ax
       mov ah, 0x04
       int 0x1a
       pop ax
       jc .end

       push ax
       push cx
       push dx

       movzx ax, dh
       call bcd_to_bin
       mov dh, al
       mov al, dl
       call bcd_to_bin
       mov dl, al

       mov ax, cx
       call bcd_to_bin

       call day_in_week

       mov bx, cx
       shl bx, 1
       mov si, [str_idx.sunday+bx]

       call strcpy
       mov al, ' '
       stosb

       pop dx
       pop bx
       pop ax

       xor cx, cx

       cmp al, 1
       je .mmddyy
       cmp al, 2
       je .yymmdd
       cmp al, 3
       je .ddmmyy
       jmp .end

.end:       
       xor al, al
       stosb
       popa
       ret

.mmddyy:
       mov al, '-'
       push ax
       call .write_mm
       pop ax
       stosb
       push ax
       call .write_dd
       pop ax
       stosb
       call .write_yy

       jmp .end

.yymmdd:
       mov al, '-'
       push ax
       call .write_yy
       pop ax
       stosb
       push ax
       call .write_mm
       pop ax
       stosb
       call .write_dd

       jmp .end

.ddmmyy:
       mov al, '-'
       push ax
       call .write_dd
       pop ax
       stosb
       push ax
       call .write_mm
       pop ax
       stosb
       call .write_yy

       jmp .end

.write_mm:
       movzx ax, dh
       mov cl, 2
       call bcd_to_str
       add di, cx
       ret

.write_dd:
       movzx ax, dl
       mov cl, 2
       call bcd_to_str
       add di, cx
       ret

.write_yy:
       mov ax, bx
       mov cl, 4
       call bcd_to_str
       add di, cx
       ret

;=============================================================================
;calc_checksum ---- calculate the checksum of a data block.
;input:
;      ds:si -> start of the checksum area
;      cx = checksum size
;output:
;      bl = the checksum value.
;=============================================================================
calc_checksum:
        push cx
        push ax
        push si
        xor bl, bl
        cld
.loop_calc:
        lodsb
        add bl, al
        loop .loop_calc
        pop si
        pop ax
        pop cx
        ret

;=============================================================================
; clear_memory ---- clear a memory block to zero
; input:
;	cx = size
;	ds:di -> memory
;=============================================================================
clear_memory:
	pusha
	push es
	push ds
	pop es
	xor al, al
	rep stosb
	pop es
	popa
	ret 

