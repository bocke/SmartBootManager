; asmsyntax=nasm
;
; ui.asm
;
; Functions for User Interface
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

%ifndef HAVE_UI

%ifndef MAIN
%include "ui.h"
%include "evtcode.h"
%include "utils.asm"
	section .text
%endif

%define HAVE_UI
%define DIRECT_DRAW

%define SCR_BUF_SEG0    0xB800
%define SCR_BUF_SEG1    0xB900
%define SCR_BUF_SEG2    0xBA00
%define SCR_PAGE_SEGS   0x0100

%define SCR_BAK_SEG     0x0900
%define BIOS_DATA_SEG   0x0040

%define BIOS_KEYSTAT_OFF 0x0017

%define WINDOW_DEF_ACTION_NUM  (window_def_action_table.end_of_table - window_def_action_table) / SIZE_OF_STRUC_ACTION
%define MENUBOX_DEF_ACTION_NUM  (menubox_def_action_table.end_of_table - menubox_def_action_table) / SIZE_OF_STRUC_ACTION
%define LISTBOX_ACTION_NUM  (listbox_action_table.end_of_table - listbox_action_table) / SIZE_OF_STRUC_ACTION
%define INPUTBOX_ACTION_NUM  (inputbox_action_table.end_of_table - inputbox_action_table) / SIZE_OF_STRUC_ACTION
      bits 16


;=============================================================================
; <<<<<<<<<<<<<<<<<<< Basic Drawing and Screen functions >>>>>>>>>>>>>>>>>>>>>
;=============================================================================

%if 1
;=============================================================================
;draw_string_hl ---- Draw a zero ending string with highlighted characters 
;                    at special position
;input:
;      bl = attribute for normal characters
;           high 4 bit Background color and low 4 bit Foreground color
;      bh = attribute for hightlight characters
;      dh = start row
;      dl = start column
;      ds:si -> the string to be displayed
;output:
;      none
;=============================================================================
draw_string:
draw_string_hl:
        pusha
        push dx
        mov cx,1
        cld
.start:

        lodsb
        or al,al
        jz .end

        cmp al,0x0d                ; if need Change row
        jne .no_cr
        pop dx
        inc dh
        push dx
        jmp short .start

.no_cr:
        cmp al, '~'
        jne .draw_it
        xchg bh, bl
        jmp short .next_char

.draw_it:
        call draw_char

        inc dl
.next_char:
        jmp short .start
.end:
        pop dx
        popa
        ret
;=============================================================================
%endif

%if 0
;=============================================================================
;draw_string ---- Draw a zero ending string at special position
;input:
;      bl = high 4 bit Background color and low 4 bit Foreground color
;      dh = start row
;      dl = start column
;      ds:si -> the string to be displayed
;output:
;      none
;=============================================================================
draw_string_hl:
draw_string:
        pusha
        push dx
        mov cx,1
        cld
.start:

        lodsb
        or al,al
        jz .end

        cmp al,0x0d                ; if need Change row
        jne .no_cr
        pop dx
        inc dh
        push dx
        jmp short .start

.no_cr:
        call draw_char

        inc dl
        jmp short .start
.end:
        pop dx
        popa
        ret
;=============================================================================
%endif

;=============================================================================
;draw_char ---- Draw chars at special position
;input:
;      bl = high 4 bit Background color and low 4 bit Foreground color
;      dh = start row
;      dl = start column
;      al = the char to be displayed
;      cx = repeat times
;output:
;      none
;=============================================================================
draw_char:
%ifdef DIRECT_DRAW                            ; directly write to video buffer
        pusha
        push es
	cld

        mov ah, bl
        push ax

	push word [ui_screen_bufseg]
	pop es

        mov al, [ui_screen_width]
        mul dh
        xor dh, dh
        add ax, dx
        shl ax, 1
        mov di, ax

        pop ax
        rep stosw
        pop es
        popa
%else
        push bx
        mov ah,2
        mov bh, [ui_screen_page]
        int 0x10
        mov ah,0x09
        int 0x10
        pop bx
%endif
        ret
;=============================================================================

;=============================================================================
;clear_screen ---- clear a screen area
;input:
;      ch = row of top left corner
;      cl = column of top left corner
;      dh = row of bottom right corner
;      dl = column of bottom right corner
;      bh = attribute
;output:
;      none
;=============================================================================
clear_screen:
        pusha
%ifdef DIRECT_DRAW
        push es
	cld

        mov ah, bh
        mov al, ' '

	push word [ui_screen_bufseg]
	pop es

        sub dl, cl
        inc dl

.loop_fill:
        push cx
        push ax

        mov al, [ui_screen_width]
        mul ch
        xor ch, ch
        add ax, cx
        shl ax, 1
        mov di, ax
        mov cl, dl

        pop ax
        rep stosw
        pop cx
        inc ch
        cmp ch, dh
        jbe .loop_fill

        pop es
%else
        mov ax, 0x0600
        int 0x10
%endif
        popa
        ret

;=============================================================================
;read_scrchar ---- read a char from the screen
;input:
;       dh = row
;       dl = column
;output:
;       ax = char with attribute
;=============================================================================
read_scrchar:
%ifdef DIRECT_DRAW
        push ds
        push dx
        push si

        mov al, [ui_screen_width]
        mul dh
        xor dh, dh
        add ax, dx
        shl ax, 1
        mov si, ax

	push word [ui_screen_bufseg]
	pop ds

        lodsw
        pop si
        pop dx
        pop ds
%else
        push bx
        mov bh, [ui_screen_page]
        mov ah,0x02
        int 0x10
        mov ah,0x08
        int 0x10
        pop bx
%endif
        ret

%if 0
;=============================================================================
;draw_string_tty ---- Draw a string ending by zero ( tty mode )
;input:
;      ds:si -> string
;output:
;      none
;=============================================================================
draw_string_tty:
        pusha
        cld
.draw1:
        lodsb
        or al, al
        jz .end
        mov bx,7
        mov ah,0x0e
        int 0x10
        jmp short .draw1
.end:
        popa
        ret
;=============================================================================
%endif

;=============================================================================
;draw_window ---- Draw a framed window
;input:
;      ch = row of top left corner
;      cl = column of top left corner
;      dh = row of bottom right corner
;      dl = column of bottom right corner
;      bl = high 4 bit Background color and low 4 bit Foreground color
;      bh = title attribute (define same as bl)
;      ds:si -> title
;output:
;      none
;=============================================================================
draw_window:
        pusha
        mov [ui_tmp.left_col], cx          ;
        mov [ui_tmp.right_col], dx         ; save window pos and attribute
        mov [ui_tmp.frame_attr], bx        ;

;Clear frame background
        xchg bh,bl
        call clear_screen

        xchg dx,cx
        mov cx,1

;Draw four corners
        mov bl, [ui_tmp.frame_attr]
        cmp byte [draw_frame_method], 2             ; check draw method.
        jb .draw_top_corner
        mov bl, [ui_tmp.title_attr]
.draw_top_corner:
        mov al, [frame_char.tl_corner]
        call draw_char

        mov dl, [ui_tmp.right_col]
        mov al, [frame_char.tr_corner]
        call draw_char

        mov bl, [ui_tmp.frame_attr]
        mov dh, [ui_tmp.bottom_row]
        mov al, [frame_char.br_corner]
        call draw_char
  
        mov dl, [ui_tmp.left_col]
        mov al, [frame_char.bl_corner]
        call draw_char

;Draw bottom horizontal line
        inc dl
        mov cl, [ui_tmp.right_col]
        sub cl, dl
        mov al, [frame_char.bottom]
        call draw_char

;Draw top horizontal line
        mov bl, [ui_tmp.frame_attr]
        cmp byte [draw_frame_method], 1             ; check draw method.
        jb .draw_top_line
        mov bl, [ui_tmp.title_attr]
.draw_top_line:
        mov dh, [ui_tmp.top_row]
        mov al, [frame_char.top]
        call draw_char

;Draw title
        call strlen
        or cx,cx
        jz .no_title

        mov al, [ui_tmp.right_col]
        sub al, [ui_tmp.left_col]
        sub al, cl
        inc al
        shr al,1
        mov dl, [ui_tmp.left_col]
        add dl,al
        mov dh, [ui_tmp.top_row]

        mov bl, [ui_tmp.title_attr]
        call draw_string

.no_title:

;Draw vertical line
        mov bl, [ui_tmp.frame_attr]
        mov dh, [ui_tmp.top_row]
        inc dh

        mov cx,1

.draw_vert_line:
        mov al, [frame_char.left]
        mov dl, [ui_tmp.left_col]
        call draw_char
        mov al, [frame_char.right]
        mov dl, [ui_tmp.right_col]
        call draw_char

        inc dh
        cmp dh, [ui_tmp.bottom_row]
        jb .draw_vert_line

;Draw shadow
        mov bl, 0x08
        mov ch, [ui_tmp.bottom_row]
        mov cl, [ui_tmp.left_col]
        inc ch
	add cl, 2
        mov dh, [ui_tmp.bottom_row]
        mov dl, [ui_tmp.right_col]
        inc dh
        call draw_shadow
        mov ch, [ui_tmp.top_row]
        mov cl, [ui_tmp.right_col]
        inc ch
        inc cl
	add dl, 2
        call draw_shadow

        popa
        ret
;=============================================================================

;=============================================================================
;draw_shadow ---- Draw shadow block
;input:
;      ch = row of top left corner
;      cl = column of top left corner
;      dh = row of bottom right corner
;      dl = column of bottom right corner
;      bl = high 4 bit Background color and low 4 bit Foreground color
;output:
;      none
;=============================================================================
draw_shadow:
        pusha
.loop_row:
        push dx
.loop_col:
        push cx
        mov cx,1
        call read_scrchar
        call draw_char
        pop cx
        dec dl
        cmp cl, dl
        jbe .loop_col
        pop dx
        dec dh
        cmp ch, dh
        jbe .loop_row

        popa
        ret
;=============================================================================


;=============================================================================
;set_video_mode ---- Set the Alphabet Video Mode
;input:
;      al = 0 , set screen resolution to 90x25,
;           otherwise set to 80x25
;      bl = character bit size ( 8 or 9 )
;      cx = fonts number
;      es:bp -> fonts data
;output:
;      none
;=============================================================================
BIOS_CRT_COLS        equ 0x4A
BIOS_ADDR_6845       equ 0x63

set_video_mode:
        push es
        push bx
        push ax

        call reset_video_mode

;Establish CRTC vertical timing and cursor position in character matrix
;and set user fonts table
        or cx, cx
        jz .set_res                          ; no font data
        or bp, bp
        jz .set_res                          ; no font data
        
.loop_set_fonts:                             ; set user defined chars
        push cx
        xor cx,cx
        inc cl
        movzx dx, byte [es:bp]
        inc bp
        mov ax,0x1100
        mov bx,0x1000
        int 0x10
        pop cx
        add bp, 16
        loop .loop_set_fonts

.set_res:
        mov byte [ui_screen_width], 80
        mov byte [ui_screen_height], 25

        mov ax,0x40
        mov es,ax
        pop ax

        or al,al
        jnz .skip_res_set

        mov dx,[es:BIOS_ADDR_6845]                   ; CRTC I/O port

;Enable I/O writes to CRTC registers
        mov al,0x11
        out dx,al
        inc dx
        in al,dx
        dec dx
        mov ah,al
        mov al,0x11
        push ax
        and ah,01111111b
        out dx,ax

;Establish CRTC horizontal timing
        lea si, [ui_VideoHorizParams]

        mov cx,7
        
        cld
.set_CRTC:
        lodsw
        out dx,ax
        loop .set_CRTC

;write-protect CRTC registers
        pop ax
        out dx,ax

;Program the Sequencer and Attribute Controller for 9 dots per character
        
        mov dx, 0x3c4
        mov ax, 0x0100
        cli
        out dx,ax

        mov ax,0x0101
        out dx,ax
        mov ax,0x0300
        out dx,ax
        sti

        mov bx,0x0013
        mov ax,0x1000
        int 0x10

        mov byte [ui_screen_width], 90
.skip_res_set:

;Program the Attribute Controller for 8- or 9-bit character codes
        mov ax,0x1000
        mov bx,0x0f12
        pop dx
        cmp dl,8
        je .svm01
        mov bh,7
.svm01:
        int 0x10

;Update video BIOS data area
        mov al,[ui_screen_width]
        mov [es:BIOS_CRT_COLS],al

;Set background highlight attribute
        pop es
        mov ax,0x1003
        xor bl,bl
        int 0x10
        call hide_cursor

        ret
;=============================================================================

;=============================================================================
;set_cursor ---- move the cursor
;input:
;       dh = row
;       dl = column
;=============================================================================
set_cursor:
	pusha
        mov bh, [ui_screen_page]
        mov ah, 0x02
        int 0x10
	popa
        ret

;=============================================================================
;hide_cursor ---- Hide the cursor
;input:
;      none
;output:
;      none
;=============================================================================
hide_cursor:
        pusha
        mov ah,1
        mov cx,0x6f00
        int 0x10
        popa
        ret
;=============================================================================

;=============================================================================
;show_cursor ---- Show the cursor
;input:
;      none
;output:
;      none
;=============================================================================
show_cursor:
        pusha
        mov ah,1
        mov cx,0x0e0f
        int 0x10
        popa
        ret
;=============================================================================

;=============================================================================
;reset_video_mode ---- Reset the VideoMode
;input:
;      none
;output:
;      none
;=============================================================================
reset_video_mode
        pusha
        mov ax,3
        int 0x10
        call show_cursor
        popa
        ret
;=============================================================================


;=============================================================================
;draw_icon ---- Draw a icon at special position
;input:
;      dh = start row
;      dl = start column
;      ch = number of row
;      cl = number of column
;      ds:si -> icon data , which is a two dim word array, each elements
;               indicates a char. high byte is the attribute, low byte is
;               is the char code.
;output:
;      none
;=============================================================================
draw_icon:
        or si, si
        jz .end
        or cx, cx
        jz .end
        
        pusha
        cld
.loop_row:
        push dx
        push cx
.loop_col:
        push cx
        mov cx,1
        lodsw
        xchg ah,bl
        call draw_char
        
        pop cx
        inc dl
        dec cl
        jnz .loop_col
        
        pop cx
        pop dx
        inc dh
        dec ch
        jnz .loop_row

        popa
.end:
        ret
;=============================================================================

;=============================================================================
;draw_background ---- Draw the background using specified icon
;input:
;      bh = background color when no icon
;      cx = icon size (ch = row, cl = col)
;      ds:si -> icon data , which is a two dim word array, each elements
;               indicates a char. high byte is the attribute, low byte is
;               is the char code.
;output:
;      none
;=============================================================================
draw_background:
        pusha
        or si,si
        jnz .normal_bg

;no icon. clear background.
        xor cx,cx
        mov dh,[ui_screen_height]
        mov dl,[ui_screen_width]
        dec dh
        dec dl
        call clear_screen
        popa
        ret

.normal_bg:
        xor dx,dx

.loop_row:
        push dx
.loop_col:
        call draw_icon
        add dl, cl
        cmp dl, [ui_screen_width]
        jb .loop_col
        pop dx
        add dh, ch
        cmp dh, [ui_screen_height]
        jb .loop_row
        popa
        ret
;=============================================================================

;=============================================================================
;turnon_scrolllock ---- turn on the scroll lock key
;input: none
;output: none
;=============================================================================
turnon_scrolllock:
        pusha
        push es
        push word BIOS_DATA_SEG
	pop es
        or byte [es: BIOS_KEYSTAT_OFF], kbScrollMask
        pop es
        popa
        ret

;=============================================================================
;turnoff_scrolllock ---- turn off the scroll lock key
;input: none
;output: none
;=============================================================================
turnoff_scrolllock:
        pusha
        push es
        push word BIOS_DATA_SEG
	pop es
        and byte [es: BIOS_KEYSTAT_OFF], ~ kbScrollMask
        pop es
        popa
        ret

;=============================================================================
;lock_screen ---- lock the screen, any output will be stored in SCR_BAK_SEG
;=============================================================================
lock_screen:
	pusha 
	cmp byte [ui_screen_lock], 0
	jnz .no_swap_page

        mov al, [ui_screen_page]
        xor al, 0x02
        mov word [ui_screen_bufseg], SCR_BUF_SEG0
        or al, al
        jz .set_seg0
        mov word [ui_screen_bufseg], SCR_BUF_SEG2
.set_seg0:
        mov [ui_screen_page], al

.no_swap_page:
	inc byte [ui_screen_lock]
	popa
        ret

;=============================================================================
;unlock_screen ---- unlock the screen, copy SCR_BAK_SEG to SCR_BUF_SEG
;=============================================================================
unlock_screen:
	pusha
	dec byte [ui_screen_lock]
	jnz .no_swap_page

        mov ah, 0x05
        mov al, [ui_screen_page]
        int 0x10
.no_swap_page:
	popa
        ret


;=============================================================================
;<<<<<<<<<<<<<<<<<<<<<<<<< Standard Dialog functions >>>>>>>>>>>>>>>>>>>>>>>>>
;=============================================================================

;=============================================================================
; msgbox_draw_body_proc ---- draw body proc of message box
; input:
;	ds:si -> the window
; output:
;	none
;=============================================================================
msgbox_draw_body_proc:
	pusha
	mov di, si
	mov bx, [si + struc_message_box.message_attr]
	mov dx, 0x0203
	mov si, [si + struc_message_box.message]
	call window_draw_string
	popa
	ret

;=============================================================================
; msgbox_default_event_handle ---- default event handle for message box
; input:
;	ax    -> event
;	ds:si -> the window
; output:
;	none
;=============================================================================
msgbox_default_event_handle:
	call window_default_event_handle
	jnc .end

	cmp ah, EVTCODE_COMMAND
	jb .exit

	stc
	ret

.exit:
	mov [si + struc_message_box.pressed_key], ax
	call window_close
.end:
	clc
	ret

;=============================================================================
; msgbox_prepare ---- prepare a message box
; input:
;	al    =  message attribute
;	bx    =  window attribute
;	ds:dx -> 2nd level pointer to title
;	ds:si -> message
;	ds:di -> pointer to the struc_message_box
; output:
;	none
;=============================================================================
msgbox_prepare:
	pusha
	mov cx, SIZE_OF_STRUC_MESSAGE_BOX
	call clear_memory

	mov [di + struc_message_box.message], si
	mov [di + struc_message_box.message_attr], ax
	mov [di + struc_window.win_attr], bx
	mov [di + struc_window.title], dx

	call count_lines

	add cl, [size.box_width]
	add ch, [size.box_height]
	mov [di + struc_window.win_size], cx
	xchg si, di
	call window_center_window

	mov byte [si], WINFLAG_FRAMED | WINFLAG_MODAL

	mov word [si + struc_window.default_event_handle], msgbox_default_event_handle
	mov word [si + struc_window.event_handle], window_event_handle
	mov word [si + struc_window.draw_body_proc], msgbox_draw_body_proc
	popa
	ret


;=============================================================================
;message_box ---- Show a message box
;input:
;	al = message attribute
;	bx = window attribute
;	ds:dx -> 2nd level pointer to title
;	ds:si -> message
;output:
;	ax = user pressed key
;=============================================================================
message_box:
	push si
	push di
	mov di, ui_tmp.tmp_msgbox
	xchg si, di
	call winlist_remove
	xchg si, di
	call msgbox_prepare
	xchg si, di
	call window_run
	mov ax, [si + struc_message_box.pressed_key]
	pop di
	pop si
        ret
;=============================================================================

;=============================================================================
;error_box ---- draw error message box.
;input:
;      ds:si -> error message
;output:
;      ax = return keycode
;=============================================================================
error_box:
        push bx
        push dx
        mov al, [color.error_box_msg]
        mov bx, [color.error_box_frame]
        mov dx, str_idx.error
        call message_box
        pop dx
        pop bx
        ret

;=============================================================================
;info_box ---- draw infomation message box.
;input:
;      ds:si -> infomation message
;output:
;      ax = return keycode
;=============================================================================
info_box:
        push bx
        push dx
        mov al, [color.info_box_msg]
        mov bx, [color.info_box_frame]
        mov dx, str_idx.info
        call message_box
        pop dx
        pop bx
        ret

;=============================================================================
; inputbox_set_cursor
; input:
;	ds:si -> input box
; output:
;	none
;=============================================================================
inputbox_set_cursor:
	mov dx, [si + struc_input_box.input_area_pos]
	add dl, [si + struc_input_box.input_curp]
	sub dl, [si + struc_input_box.input_startp]
	call window_set_cursor
	call show_cursor
	ret
	
;=============================================================================
; inputbox_draw_body_proc ---- draw_body_proc of input box
; input:
;	ds:si -> pointer to struc_input_box
; output:
;	none
;=============================================================================
inputbox_draw_body_proc:
	pusha
	mov di, si
	mov bx, [si + struc_input_box.message_attr]
	mov dx, 0x0202
	mov si, [si + struc_input_box.message]
	call window_draw_string
	popa
	call inputbox_draw_input_area
	call inputbox_set_cursor
	ret

;=============================================================================
; inputbox_draw_input_area ---- draw the input area of a input box
; input:
;	ds:si -> pointer to struc_input_box
; output:
;	none
;=============================================================================
inputbox_draw_input_area:
	pusha
	movzx cx, byte [si + struc_input_box.input_area_len]
	mov dx, [si + struc_input_box.input_area_pos]
	mov al, 0x20
	mov bl, [si + struc_input_box.input_attr]
	call window_draw_char

	movzx ax, byte [si + struc_input_box.input_startp]
	mov di, [si + struc_input_box.input_buf]
	add di, ax
	mov bh, [si + struc_input_box.input_type]

.loop_draw:
	mov al, [di]
	or al, al
	jz .end_draw
	or bh, bh
	jz .draw_normal
	mov al, '*'
.draw_normal:
	push cx
	mov cl, 1
	call window_draw_char
	pop cx
	inc dl
	inc di
	loop .loop_draw

.end_draw:
	popa
	ret


;=============================================================================
; inputbox_get_strlen 
; input:
;	ds:si -> input box
; output:
;	cx = input buf strlen
;=============================================================================
inputbox_get_strlen:
	push si
	mov si, [si + struc_input_box.input_buf]
	call strlen
	pop si
	ret

;=============================================================================
; inputbox_delete_char
; input:
;	ds:si -> input box
;	cl = position to be deleted
; output:
;	none
;=============================================================================
inputbox_delete_char:
	pusha
	xor ch, ch
	mov di, [si + struc_input_box.input_buf]
	add di, cx
	mov si, di
	cmp byte [si], 0
	jz .end
	inc si
	mov cl, 255
	call strncpy
.end:
	popa
	ret

;=============================================================================
; inputbox_post_input
;=============================================================================
inputbox_post_input:
	mov al, [si + struc_input_box.input_curp]
	mov cl, [si + struc_input_box.input_startp]
	cmp cl, al
	jb .below_cur
	mov [si + struc_input_box.input_startp], al
	jmp short .end

.below_cur:
	sub al, cl
	cmp al, [si + struc_input_box.input_area_len]
	jbe .end
	sub al, [si + struc_input_box.input_area_len]
	add [si + struc_input_box.input_startp], al
.end:
	ret

;=============================================================================
; inputbox_backspace 
;=============================================================================
inputbox_backspace:
	call inputbox_get_strlen
	or cx, cx
	jz .end
	mov cl, [si + struc_input_box.input_curp]
	or cl, cl
	jz .end
	dec cl
	mov [si + struc_input_box.input_curp], cl
	call inputbox_delete_char
	call inputbox_post_input
.end:
	ret

;=============================================================================
; inputbox_delete
;=============================================================================
inputbox_delete:
	call inputbox_get_strlen
	or cx, cx
	jz .end
	mov cl, [si + struc_input_box.input_curp]
	call inputbox_delete_char
	call inputbox_post_input
.end:
	ret

;=============================================================================
; inputbox_right_arrow
;=============================================================================
inputbox_right_arrow:
	call inputbox_get_strlen
	cmp cl, [si + struc_input_box.input_curp]
	jbe .end

	inc byte [si + struc_input_box.input_curp]
	call inputbox_post_input
.end:
	ret

;=============================================================================
; inputbox_left_arrow
;=============================================================================
inputbox_left_arrow:
	cmp byte [si + struc_input_box.input_curp], 0
	jz .end

	dec byte [si + struc_input_box.input_curp]
	call inputbox_post_input
.end:
	ret

;=============================================================================
; inputbox_end_key
;=============================================================================
inputbox_end_key:
	call inputbox_get_strlen
	mov [si + struc_input_box.input_curp], cl
	call inputbox_post_input
	ret

;=============================================================================
; inputbox_home_key
;=============================================================================
inputbox_home_key:
	mov byte [si + struc_input_box.input_curp], 0
	call inputbox_post_input
	ret


;=============================================================================
; inputbox_cancel
;=============================================================================
inputbox_cancel:
	mov byte [si + struc_input_box.return_val], 1
	call hide_cursor
	ret

;=============================================================================
; inputbox_enter
;=============================================================================
inputbox_enter:
	mov byte [si + struc_input_box.return_val], 0
	call hide_cursor
	ret

;=============================================================================
; inputbox_insert_char
; input:
;	al = char
;	cl = position
;	ds:si -> input box
;=============================================================================
inputbox_insert_char:
	pusha
	xor ch, ch
	push cx
	call inputbox_get_strlen
	mov si, [si + struc_input_box.input_buf]
	add si, cx
	pop dx
	sub cx, dx
	or cx, cx
	jz .no_move

.loop_move:
	mov ah, [si]
	mov [si + 1], ah
	dec si
	loop .loop_move

.no_move:
	mov ah, [si]
	mov [si], ax
	popa
	ret
	
;=============================================================================
; inputbox_default_event_handle
; input:
;	ax = event code
;	ds:si -> input box
; output:
;	none
;=============================================================================
inputbox_default_event_handle:
	call window_default_event_handle
	jnc .end
	or al, al
	jz .no_action
	cmp ah, EVTCODE_COMMAND
	jae .no_action
	cmp al, 0x20
	jb .no_action
	cmp al, 0xE0
	je .no_action

	call inputbox_get_strlen
	sub cl, [si + struc_input_box.input_buf_len]
	or cl, cl
	jz .end

	mov cl, [si + struc_input_box.input_curp]
	call inputbox_insert_char
	inc byte [si + struc_input_box.input_curp]
	call inputbox_post_input
	call window_draw_body
	ret

.no_action:
	stc
.end:
	ret

;=============================================================================
; inputbox_prepare
; input:
;	ah = input method ( 0 = normal, 1 = security )
;	al = message attribute
;	bh = title attribute
;	bl = frame attribute
;	ch = input area length
;	cl = max input length
;	ds:si -> message ( no more than one line )
;	ds:di -> pointer to struc_input_box
;	ds:dx -> buffer to store input string
;=============================================================================
inputbox_prepare:
	pusha
	or ch, ch
	jnz .go_prepare
	mov ch, cl
.go_prepare:

	push cx
	mov cx, SIZE_OF_STRUC_INPUT_BOX
	call clear_memory
	pop cx

	mov byte [di], WINFLAG_FRAMED | WINFLAG_MODAL		; win flag
	mov word [di + struc_window.title], str_idx.input	; win title
	mov [di + struc_window.win_attr], bx			; win attr
	mov [di + struc_input_box.message], si
	mov [di + struc_input_box.message_attr], al
	mov al, 0x0F
	mov [di + struc_input_box.input_attr], ax
	mov [di + struc_input_box.input_buf], dx
	mov [di + struc_input_box.input_buf_len], cx		; input buf 
								; and area len

	mov bx, [size.box_width]
	inc bh
	add bl, ch

	call strlen
	add bl, cl
	mov [di + struc_window.win_size], bx			; win size
	mov [di + struc_input_box.input_area_pos],cx		; input area pos
	add word [di + struc_input_box.input_area_pos], 0x0202

	mov word [di + struc_window.act_num], INPUTBOX_ACTION_NUM
	mov word [di + struc_window.act_table], inputbox_action_table
	mov word [di + struc_window.default_event_handle], inputbox_default_event_handle
	mov word [di + struc_window.event_handle], window_event_handle
	mov word [di + struc_window.draw_body_proc], inputbox_draw_body_proc

	inc byte [di + struc_input_box.return_val]

	mov si, di
	call window_center_window
	popa
	ret

;=============================================================================
;input_box ---- draw a input box and input a string
;input:
;      ah = input method ( 0 = normal, 1 = security )
;      al = message attribute
;      bh = title attribute
;      bl = frame attribute
;      ch = input area length
;      cl = max input length
;      ds:si -> message ( no more than one line )
;      ds:di -> buffer to store input text
;      ds:dx -> parent window
;output:
;      cf = 0 , ah = 0 ok, ch = number of inputed character
;      cf = 1 , ah != 0 cancel, ch = 0
;=============================================================================
input_box:
	push si
	push di
	push di
	push dx

	mov dx, ui_tmp.tmp_buf
	mov di, ui_tmp.tmp_inputbox
	xchg si, di
	call winlist_remove
	xchg si, di
	call inputbox_prepare

	pop word [di + struc_window.parent_win]
	xchg di, dx
	pop si

	push es
	push ds
	pop es

	push si
	push di

	call strcpy
	
	mov si, dx
	call window_run
	mov ah, [si + struc_input_box.return_val]
	call inputbox_get_strlen
	mov ch, cl
	mov cl, [si + struc_input_box.input_buf_len]
	or ah, ah

	pop si
	pop di
	jz .ok
	stc
	jmp short .end
.ok:
	call strcpy
	clc
.end:
	pop es
	pop di
	pop si
	ret

;=============================================================================
;input_password ---- input a password
;input:
;      cl = max password length
;      ds:si -> message string
;output:
;      cf = 0 success, ax:dx = password
;      cf = 1 cancel
;=============================================================================
input_password:
        push bx
        push cx
        
        mov ah, 1
        mov al, [color.input_box_msg]
        mov bx, [color.input_box_frame]
        mov ch, cl
        xor dx, dx
        mov di, ui_tmp.tmp_buf1

        mov byte [di], 0

        call input_box
        jc .cancel_input

        mov si, di
        movzx cx, ch
        call calc_password
        clc

.cancel_input:
        pop cx
        pop bx
        ret
;=============================================================================

;=============================================================================
; menubox_adjust_geometry ---- adjust the size and position of the menu box
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_adjust_geometry:
	call menubox_adjust_menu_area
	call menubox_adjust_win_width
	ret

;=============================================================================
; menubox_adjust_menu_area ---- adjust the size and position of the menu area
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_adjust_menu_area:
	pusha

;adjust menu area position
	mov cx, 0x0101
	mov al, [si]
	test al, MENUFLAG_SINK_UPPER
	jz .no_sink_upper
	inc ch
.no_sink_upper:
	cmp word [si + struc_menu_box.menu_header], 0
	jz .no_header
	inc ch
.no_header:
	test al, MENUFLAG_SINK_WIDTH
	jz .no_sink_width
	inc cl
.no_sink_width:
	mov [si + struc_menu_box.menu_area_pos], cx

;adjust menu area size
	mov dx, [si + struc_window.win_size]
	sub dh, ch
	dec dh
	test al, MENUFLAG_SINK_BOTTOM
	jz .no_sink_bottom
	dec dh
.no_sink_bottom:

	xor dl, dl
	movzx cx, byte [si + struc_menu_box.items_num]
	or cx, cx
	jz .end_calc
	mov bx, [si + struc_menu_box.item_str_proc]
	or bx, bx
	jz .end_calc

.loop_calc_item_width:
	push si
	push bx
	push cx
	dec cx

	push dx
	call bx
	pop dx

	call strlen_hl
	cmp dl, cl
	jae .cont_calc
	mov dl, cl
.cont_calc:
	pop cx
	pop bx
	pop si
	loop .loop_calc_item_width

.end_calc:

	push si
	mov si, [si + struc_menu_box.menu_header]
	or si, si
	jz .no_header_len
	mov si, [si]
	call strlen_hl
	cmp dl, cl
	jae .header_short
	mov dl, cl
.header_short:
.no_header_len:
	add dl, 2
	pop si
	mov [si + struc_menu_box.menu_area_size], dx

	popa
	ret


;=============================================================================
; menubox_adjust_win_width ---- adjust the width the menu window. 
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_adjust_win_width:
	pusha
	mov al, [si]
	mov bx, [si + struc_menu_box.menu_area_size]

; calculate window width
	add bl, 2

	test al, MENUFLAG_SINK_WIDTH
	jz .no_sink_width
	add bl, 2
.no_sink_width:
	test al, MENUFLAG_SCROLLBAR
	jz .no_scrollbar
	inc bl
.no_scrollbar:
	mov [si + struc_window.win_size], bl
	mov cl, [ui_screen_width]
	sub cl, bl
	sub cl, 2

	cmp [si + struc_window.win_pos], cl
	jbe .no_adjust_pos
	mov [si + struc_window.win_pos], cl
.no_adjust_pos:
	popa
	ret

;=============================================================================
; menubox_draw_body_proc ---- draw the window body of a menu box
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_draw_body_proc:
	pusha
	call menubox_draw_menu
	cmp word [si + struc_menu_box.menu_header], 0
	jz .no_header
	call menubox_draw_header
.no_header:
	test byte [si], MENUFLAG_SCROLLBAR
	jz .no_scrollbar
	call menubox_draw_scrollbar
.no_scrollbar:
	popa
	ret


;=============================================================================
; menubox_draw_scrollbar ---- draw the scrollbar
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_draw_scrollbar:
	mov ax, [si + struc_menu_box.items_num]
	mov bl, [si + struc_menu_box.scrollbar_attr]
	mov cx, [si + struc_menu_box.menu_area_pos]
	mov dx, [si + struc_menu_box.menu_area_size]
	add cl, dl
	xor dl, dl
	call window_draw_scrollbar
	ret

;=============================================================================
; menubox_draw_menu ---- draw the menu area
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_draw_menu:
	pusha
	mov cx, [si + struc_menu_box.menu_area_pos]
	mov dx, [si + struc_menu_box.menu_area_size]
	push dx
	push cx
	add cx, [si + struc_window.win_pos]
	add dx, cx

	sub dx, 0x0101
	mov bh, [si + struc_menu_box.menu_norm_attr]
	call clear_screen

	pop dx
	pop ax

	movzx cx, [si + struc_menu_box.first_visible_item]
	cmp byte [si + struc_menu_box.items_num], 0
	je .end

	mov di, si

.loop_draw_item:
	cmp cl, [si + struc_menu_box.focus_item]
	je .focused
	mov bx, [si + struc_menu_box.menu_norm_attr]
	jmp short .draw_item
.focused:
	mov bx, [si + struc_menu_box.menu_focus_attr]
.draw_item:
	pusha
	push cx
	mov cl, al
	mov al, ' '
	call window_draw_char
	pop cx
	inc dl
	push bx
	push dx
	push di
	call word [si + struc_menu_box.item_str_proc]
	pop di
	pop dx
	pop bx
	call window_draw_string
	popa
	inc dh
	inc cl
	dec ah
	cmp cl, [si + struc_menu_box.items_num]
	jae .end
	or ah, ah
	jz .end
	jmp short .loop_draw_item
.end:
	popa
	ret

;=============================================================================
; menubox_draw_header ---- draw the menu header
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_draw_header:
	pusha
	mov bx, [si + struc_menu_box.menu_header_attr]
	mov dx, [si + struc_menu_box.menu_area_pos]
	dec dh
	movzx cx, byte [si + struc_menu_box.menu_area_size]
	mov al, ' '
	test byte [si], MENUFLAG_SCROLLBAR
	jz .no_scrollbar
	inc cl
.no_scrollbar:
	call window_draw_char
	mov di, si
	mov si, [si + struc_menu_box.menu_header]
	mov si, [si]
	inc dl
	call window_draw_string
	popa
	ret

;=============================================================================
; menubox_do_focus ---- do the focused menu item, get the pointer of item action
;                    from action_table, then call window_do_action to do it.
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_do_focus:
	mov bx, [si + struc_window.act_table]
	mov al, SIZE_OF_STRUC_ACTION
	mov cl, [si + struc_menu_box.focus_item]
	mul cl
	add bx, ax
	mov ax, [bx + struc_action.keycode]
	call window_do_action
	ret
	

;=============================================================================
; menubox_adjust_visible_boundary
;input:
;	ds:si -> pointer to struc_menu_box
;=============================================================================
menubox_adjust_visible_boundary:
	mov ax, [si + struc_menu_box.focus_item] ; al = focus_item, ah = first_visible_item

.check_upper:
	cmp al, ah
	jae .check_bottom
	mov [si + struc_menu_box.first_visible_item], al
.check_bottom:
	add ah, [si + struc_menu_box.menu_area_size + 1]
	cmp al, ah
	jb .end
	sub al, ah
	inc al
	add [si + struc_menu_box.first_visible_item], al
.end:	
	ret

;=============================================================================
; menubox_focus_up ---- move the focus bar up one line
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_focus_up:
	mov ax, [si + struc_menu_box.items_num]	;al = items_num, ah = focus_item
	or ah, ah
	jnz .up
	mov ah, al
.up:
	dec ah
	mov [si + struc_menu_box.focus_item], ah
	call menubox_adjust_visible_boundary
	ret

;=============================================================================
; menu_focus_pageup ---- move the focus bar up one page
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_focus_pageup:
	mov al, [si + struc_menu_box.focus_item]
	mov cl, byte [si + struc_menu_box.menu_area_size+1]
	dec cl
	cmp cl, al
	jb .loop_up

	mov cl, al
	or cl, cl
	jz .end

.loop_up:
	xor ch, ch
	call menubox_focus_up
	loop .loop_up
.end:
	ret

;=============================================================================
; menu_focus_down ---- move the focus bar down one line
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_focus_down:
	mov ax, [si + struc_menu_box.items_num]	;al = items_num, ah = focus_item
	inc ah
	cmp ah, al
	jb .down
	xor ah, ah
.down:
	mov [si + struc_menu_box.focus_item], ah
	call menubox_adjust_visible_boundary
	ret

;=============================================================================
; menu_focus_pagedown ---- move the focus bar down one page
; input:
;	ds:si -> pointer to struc_menu_box
; output:
;	none
;=============================================================================
menubox_focus_pagedown:
	mov ax, [si + struc_menu_box.items_num]
	or al, al
	jz .end

	sub al, ah
	dec al

	mov cl, byte [si + struc_menu_box.menu_area_size+1]
	dec cl

	cmp cl, al
	jb .loop_down
	mov cl, al
	or cl, cl
	jz .end

.loop_down:
	xor ch, ch
	call menubox_focus_down
	loop .loop_down
.end:
	ret

;=============================================================================
;menubox_default_event_handle
;=============================================================================
menubox_default_event_handle:
	pusha
	mov cx, MENUBOX_DEF_ACTION_NUM
	mov bx, menubox_def_action_table
	call window_generic_event_handle
	jnc .end
	call window_default_event_handle
.end:
	popa
	ret
;=============================================================================

;=============================================================================
; listbox_prepare ---- prepare a list box
; input:
;	cl = number of items
;	ch = height of list box
;	ds:bx -> 2nd level pointer to title
;	ds:dx -> 2nd level pointer to header
;	ds:si -> items string proc
;	ds:di -> struc_menu_box
;=============================================================================
listbox_prepare:
	pusha
	push cx
	mov cx, SIZE_OF_STRUC_MENU_BOX
	call clear_memory
	pop cx

	mov byte [di], WINFLAG_FRAMED | WINFLAG_MODAL | MENUFLAG_SCROLLBAR
	mov [di + struc_window.title], bx
	mov [di + struc_menu_box.menu_header], dx
	mov [di + struc_menu_box.item_str_proc], si

	mov si, color.list_box
	cld
	lodsw
	mov word [di + struc_window.win_attr], ax
	lodsb
	mov byte [di + struc_menu_box.menu_header_attr], al
	lodsw
	mov word [di + struc_menu_box.menu_norm_attr], ax
	lodsw
	mov word [di + struc_menu_box.menu_focus_attr], ax
	lodsb
	mov byte [di + struc_menu_box.scrollbar_attr], al

	mov [di + struc_menu_box.items_num], cl
	mov [di + struc_window.win_size + 1], ch
	mov word [di + struc_window.act_num], LISTBOX_ACTION_NUM
	mov word [di + struc_window.act_table], listbox_action_table
	mov word [di + struc_window.default_event_handle], menubox_default_event_handle
	mov word [di + struc_window.event_handle], window_event_handle
	mov word [di + struc_window.draw_body_proc], menubox_draw_body_proc

	mov si, di
	call menubox_adjust_geometry
	call window_center_window
	popa
	ret
	
;=============================================================================
; list_box ---- run a list box
; input:
;	cl = number of items
;	ch = height of list box
;	ds:bx -> 2nd level pointer to title
;	ds:dx -> 2nd level pointer to header
;	ds:si -> items string proc
; output:
;	cl = selected item, 0xff means canceled
;	cf = 0 success, cf = 1 canceled
;=============================================================================
list_box:
	pusha
	mov di, ui_tmp.tmp_menubox
	call listbox_prepare
	mov si, di
	call window_run
	popa
	mov cl, [ui_tmp.tmp_menubox + struc_menu_box.focus_item]
	cmp cl, 0xFF
	je .cancel
	clc
	ret
.cancel:
	stc
	ret

;=============================================================================
; listbox_cancel
;=============================================================================
listbox_cancel:
	mov byte [si + struc_menu_box.focus_item], 0xFF
	ret
;=============================================================================



;=============================================================================
;<<<<<<<<<<<<<<<<<<<<<<<<<< Window System functions >>>>>>>>>>>>>>>>>>>>>>>>>>
;=============================================================================

;=============================================================================
; window_draw_all ---- draw all windows
; input:
;	none
; output:
;	none
;=============================================================================
window_draw_all:
	pusha
	mov si, [ui_tmp.root_win]
	or si, si
	jz .end
	call lock_screen
	call window_draw_window
	call unlock_screen
.end:
	popa
	ret

;=============================================================================
; window_draw_body ---- draw the window body
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_draw_body:
	pusha
	or si, si
	jz .no_win

	test byte [si], WINFLAG_OPEN
	jz .no_win

	mov bx, [si + struc_window.draw_body_proc]
	or bx, bx
	jz .no_win

	push si
	call bx
	pop si

	mov si, [si + struc_window.next_win]
	or si, si
	jz .no_win
	call window_draw_window		; draw top windows.

.no_win:
	popa
	ret
;=============================================================================
; window_draw_window ---- draw the window and window body
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_draw_window:
	pusha

	call hide_cursor

	or si, si
	jz .no_next_win

	test byte [si], WINFLAG_OPEN
	jz .no_body
	test byte [si], WINFLAG_FRAMED
	jz .no_frame
	call window_draw_frame
.no_frame:
	mov bx, [si + struc_window.draw_body_proc]
	or bx, bx
	jz .no_body
        push si
	call bx
        pop si
.no_body:
	mov si, [si + struc_window.next_win]
	or si, si
	jz .no_next_win
	call window_draw_window		; draw top windows.

.no_next_win:
	popa
	ret

;=============================================================================
; window_draw_frame ---- draw the window frame and clear the window body
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_draw_frame:
	pusha
	mov cx, [si + struc_window.win_pos]	; window position
	mov dx, [si + struc_window.win_size]	;
	add dx, cx				; calculate window bottom
	sub dx, 0x0101				; right corner.

	mov bx, [si + struc_window.win_attr]	; window attribute

	cmp si, [ui_tmp.focus_win]
	je .focused

	mov bh, [color.win_title_inactive]	; use another title attr for 
						; inactive window.
.focused:
	mov si, [si + struc_window.title]	; get window title pointer
	or si, si
	jz .no_title
	mov si, [si]
.no_title:
	call draw_window
	popa
	ret

;=============================================================================
; window_set_cursor
; input:
;	dx = cursor position
;	ds:si -> window
; output:
;	none
;=============================================================================
window_set_cursor:
	push dx
	test byte [si], WINFLAG_OPEN
	jz .no_cursor

	add dx, [si + struc_window.win_pos]
	call set_cursor

.no_cursor:
	pop dx
	ret

;=============================================================================
; window_draw_char ---- Draw chars at special position in a window
;input:
;      bl = high 4 bit Background color and low 4 bit Foreground color
;      dh = start row
;      dl = start column
;      al = the char to be displayed
;      cx = repeat times
;      ds:si -> the window
;output:
;      none
;=============================================================================
window_draw_char:
	push dx
	test byte [si], WINFLAG_OPEN
	jz .not_draw

	add dx, [si + struc_window.win_pos]
	call draw_char

.not_draw:
	pop dx
	ret

;=============================================================================
;window_draw_string ---- Draw a zero ending string in a window 
;                    at special position
;input:
;      bl = attribute for normal characters
;           high 4 bit Background color and low 4 bit Foreground color
;      bh = attribute for hightlight characters
;      dh = start row
;      dl = start column
;      ds:si -> the string to be displayed
;      ds:di -> the window
;output:
;      none
;=============================================================================
window_draw_string:
	pusha
	test byte [di], WINFLAG_OPEN
	jz .not_draw

	add dx, [di + struc_window.win_pos]
	call draw_string
.not_draw:
	popa
	ret

;=============================================================================
; window_draw_scrollbar ---- draw a scroll bar in a window
; input:
;	ds:si -> pointer to struc_window
;	al    -> total amount
;	ah    -> current value
;	bl    -> attribute 
;	ch    -> row of top of the scroll bar (relative to window position)
;	cl    -> col of top of the scroll bar (relative to window position)
;	dh    -> height of the scroll bar ( vertical bar, dl = 0 )
;	dl    -> length of the scroll bar ( horizontal bar, dh = 0 )
; output:
;	none
;=============================================================================
window_draw_scrollbar:
	pusha

; ================== do some initialization. ==================
	push cx
	xor cx, cx
	mov [.bar_type], cl
	inc cl

	or dh, dh
	jz .horiz1
	mov [.bar_type], cl
	xchg dl, dh
.horiz1:

	mov [.bar_length], dl
	pop dx

	push ax
	push dx

; ==================== draw blank bar =================
	mov ah, [.bar_length]
	mov al, ' '

.loop_draw_blank:
	call window_draw_char
	dec ah

	cmp byte [.bar_type], 0
	jz .horiz2
	inc dh
	jmp near .cont_draw_blank
.horiz2:
	inc dl

.cont_draw_blank:
	or ah, ah
	jnz .loop_draw_blank

	cmp byte [.bar_type], 0
	jz .horiz3
	mov ax, 0x1f1e
	jmp near .draw_arrow
.horiz3:
	mov ax, '<>'

.draw_arrow:
	pop dx
	push dx

	call window_draw_char
	xchg al, ah

	cmp byte [.bar_type], 0
	jz .horiz4
	add dh, [.bar_length]
	dec dh
	jmp near .draw_end_arrow
.horiz4:
	add dl, [.bar_length]
	dec dl
.draw_end_arrow:

	call window_draw_char
	pop dx

; ================= draw scroll block ===============
	pop cx
	cmp [.bar_length], cl
	jae .no_cursor
	cmp byte [.bar_length], 3
	jb .no_cursor

	movzx ax, ch			; block position =
	mov ch, [.bar_length]		; cur value * bar length / value max
	sub ch, 2			; 
	mul ch				;
	div cl				;

	cmp byte [.bar_type], 0
	jz .horiz5
	add dh, al
	inc dh
	jmp near .draw_scroll_block
.horiz5:
	add dl, al
	inc dl

.draw_scroll_block:
	mov al, 'O'
	xor cx, cx
	inc cl
	call window_draw_char

.no_cursor:
	popa
	ret

.bar_type	db 0		; 1 = vertical, 0 =horizontal
.bar_length	db 0


;=============================================================================
; window_initialize ---- initialize the window system.
; input:
;	none
; output:
;	none
;=============================================================================
window_initialize:
	pusha
	xor al, al
	mov di, ui_tmp.def_root_win
	mov cx, SIZE_OF_STRUC_WINDOW
	call clear_memory
	mov byte [di], WINFLAG_OPEN | WINFLAG_NO_FOCUS
	mov word [di + struc_window.draw_body_proc], window_clear_win_area
	mov ax, [ui_screen_size]
	mov [di + struc_window.win_size], ax

	mov [ui_tmp.root_win], di
	popa
	ret


;=============================================================================
; window_clear_win_area:
; input:
;	ds:si -> root win
; output:
;	none
;=============================================================================
window_clear_win_area:
	pusha
	mov cx, [si + struc_window.win_pos]
	mov dx, [si + struc_window.win_size]
	add dx, cx
	sub dx, 0x0101
	mov bh, [si + struc_window.win_attr]
	call clear_screen
	popa
	ret

;=============================================================================
; window_execute ---- execute the  window system, no return.
; input:
;	ds:bx -> pointer to root window
;	ds:si -> pointer to current window
; output:
;	none
;=============================================================================
window_execute:
	or bx, bx
	jnz .has_root
	mov bx, ui_tmp.def_root_win
.has_root:
	or si, si
	jz .end

	xchg si, bx
	call winlist_setroot
	call window_draw_window
	xchg si, bx

.loop_exec:
	test byte [si], WINFLAG_NO_FOCUS
	jnz .find_focusable

	call window_run
	mov si, [ui_tmp.focus_win]
	or si, si
	jz .end

	call winlist_findwin
	jc .reset_focus

.find_focusable:
	call winlist_find_focusable
	or si, si
	jnz .loop_exec
	ret

.reset_focus:
	call winlist_findtop
	mov si, di
	jmp short .loop_exec
.end:
	ret

;=============================================================================
; window_run ---- run a window, open it, and loop get key until the window
;                 is closed (WINFLAG_OPEN is cleared). It passes the key to 
;                 function window_event_handle. If window_event_handle failed
;                 to handle this key, then the key will be passed to its 
;                 parent window.
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_run:
	call winlist_findwin
	jc .run_this_win

	test byte [si + 1], WINFLAG_HI_RUNNING
	jz .run_this_win

	mov [ui_tmp.focus_win], si
	call winlist_raise
	ret

.run_this_win:
	pusha
	or byte [si + 1], WINFLAG_HI_RUNNING

	push word [ui_tmp.focus_win]
	call window_open

.loop_run:	
	cmp [ui_tmp.focus_win], si		; if current win is switched
	jne .end_run				; just return.

	call get_event
	cmp ah, EVTCODE_COMMAND
	jb .keycode
	test ah, EVTCODE_BROADCAST
	jz .keycode
	call winlist_broadcast_event
	jmp short .cont_run
.keycode:
	call window_event_dispatcher
.cont_run:
	test byte [si], WINFLAG_OPEN
	jnz .loop_run

	pop word [ui_tmp.focus_win]		; if window is closed, restore
	jmp short .end				; focus_win and return.

.end_run:
	pop ax
.end:
	and byte [si + 1], ~ WINFLAG_HI_RUNNING
	popa
	ret


;=============================================================================
; window_open ---- open a window, draw the window and set flag WINFLAG_OPEN, 
;                  and insert it into the windows list.
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_open:
	pusha
	call winlist_raise
	or byte [si], WINFLAG_OPEN
	call winlist_set_focus_win
	popa
	ret

;=============================================================================
; window_close ---- close a window, clear flag WINFLAG_OPEN, and remove it
;                   from the windows list.
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_close:
	pusha
	call winlist_remove
	and byte [si], ~ WINFLAG_OPEN
	call window_draw_all
	popa
	ret

;=============================================================================
; window_move_up ---- move the window up one row
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_move_up:
	push ax
	mov al, [si + struc_window.win_pos + 1]
	or al, al
	jz .no_move
	dec al
	mov [si + struc_window.win_pos + 1], al
.no_move:
	pop ax
	ret

;=============================================================================
; window_move_down ---- move the window down one row
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_move_down:
	push ax
	mov al, [si + struc_window.win_pos + 1]
	mov ah, [ui_screen_height]
	dec ah

	cmp al, ah
	jae .no_move
	inc al
	mov [si + struc_window.win_pos + 1], al
.no_move:
	pop ax
	ret


;=============================================================================
; window_move_left ---- move the window left one column
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_move_left:
	push ax
	mov al, [si + struc_window.win_pos]
	or al, al
	jz .no_move
	dec al
	mov [si + struc_window.win_pos], al
.no_move:
	pop ax
	ret


;=============================================================================
; window_move_right ---- move the window right one column
; input:
;	ds:si -> pointer to struc_window
; output:
;	none
;=============================================================================
window_move_right:
	push ax
	mov al, [si + struc_window.win_pos]
	mov ah, [ui_screen_width]
	sub ah, [si + struc_window.win_size]
	sub ah, 2

	cmp al, ah
	jae .no_move
	inc al
	mov [si + struc_window.win_pos], al
.no_move:
	pop ax
	ret


;=============================================================================
; window_switch_window ---- switch to the next window
; input:
;	ds:si -> pointer to current window
; output:
;	none
;=============================================================================
window_switch_window:
	pusha
	test byte [si], WINFLAG_MODAL
	jnz .no_switch
	call winlist_findwin
	jc .no_switch
	mov si, [ui_tmp.root_win]
	or si, si
	jz .no_switch

	mov [ui_tmp.focus_win], si

.no_switch:
	popa
	ret

;=============================================================================
; move a window to center of the screen.
;input:
;	ds:si -> pointer to window
;output:
;	none
;=============================================================================
window_center_window:
	pusha
	mov dx, [si + struc_window.win_size]
	mov cx, [ui_screen_size]                   ; calculate the coordinate

	sub ch, dh                              ; of input box.
	shr ch, 1                               ; cx = top left pos
	sub cl, dl                              ; 
	shr cl, 1                               ;

	mov [si + struc_window.win_pos], cx
	popa
	ret


;=============================================================================
; window_default_event_handle ---- default event handle for a normal window, it
;                           handles some normal events, such as move window.
; input:
;	ax    -> keycode
;	ds:si -> pointer to struc_window
; output:
;	cf = 0, success
;	cf = 1, fail, no such action
;=============================================================================
window_default_event_handle:
	pusha
	mov cx, WINDOW_DEF_ACTION_NUM
	mov bx, window_def_action_table
	call window_generic_event_handle
	popa
	ret

;=============================================================================
; window_event_handle ----  event handle for a normal window, it finds 
;                           the corresponding action for a key event from
;                           action_table then call window_do_action to run it.
;                           If the event is not in action_table, then
;                           .defkey_handle will be called to handle it.
; input:
;	ax    -> keycode
;	ds:si -> pointer to struc_window
; output:
;	cf = 0, success
;	cf = 1, fail, no such action
;=============================================================================
window_event_handle:
	pusha
	mov bx, [si + struc_window.act_table]
	mov cx, [si + struc_window.act_num]
	call window_generic_event_handle
	jnc .success
	mov bx, [si + struc_window.default_event_handle]
	or bx, bx
	jz .failed
	call bx
	jnc .success
.failed:
	stc
.success:
	popa
	ret

;=============================================================================
; window_generic_event_handle ---- generic event handle, it find a key from 
;                                  an action list, then run it.
; input:
;	ax    -> keycode
;	ds:si -> pointer to struc_window
;	ds:bx -> action list
;	cx    -> action number
; output:
;	cf = 0, success
;	cf = 1, fail, no such action
;=============================================================================
window_generic_event_handle:
	or cx, cx
	jz .no_action
	or bx, bx
	jz .no_action

.loop_find_act:
	cmp [bx + struc_action.keycode], ax
	jne .cont_find
	call window_do_action
	clc
	ret

.cont_find:
	add bx, SIZE_OF_STRUC_ACTION
	loop .loop_find_act

.no_action:
	stc
	ret

;=============================================================================
; window_event_dispatcher ---- dispatch event to event handle 
; input:
;	ax    -> keycode
;	ds:si -> pointer to struc_window
; output:
;	cf = 0, success
;	cf = 1, fail, no such action
;=============================================================================
window_event_dispatcher:
	pusha
	mov bx, [si + struc_window.event_handle]
	or bx, bx
	jz .no_event_handle

	push si
	call bx
	pop si

	jnc .action_ok

.no_event_handle:
	mov si, [si + struc_window.parent_win]
	or si, si
	jz .no_parent
	call window_event_dispatcher
	jnc .action_ok

.no_parent:
	stc

.action_ok:
	popa
	ret

;=============================================================================
; window_do_action ---- do a window action
; input:
;	ax    =  event code
;	ds:si -> pointer to struc_window
;	ds:bx -> pointer to struc_action
; output:
;	none
;=============================================================================
window_do_action:
	pusha

	or si, si
	jz .end
	or bx, bx
	jz .end

	mov dl, [bx]

	test dl, ACTFLAG_AUTHS		; check action flags
	jz .no_auth

	pusha
	mov al, dl
	call main_auth_action		; check if the action is ready to do
					; al = auth type
	popa
	jc .no_action

.no_auth:
	mov bx, [bx + struc_action.func]
	or bx, bx
	jz .no_action

	pusha
	call bx				; do the action
	popa

.no_action:

	test dl, ACTFLAG_CLOSE_WIN
	jz .no_close
	call window_close
	jmp short .end
.no_close:
	test dl, ACTFLAG_REDRAW_BODY
	jz .no_redraw_body
	call window_draw_body
	jmp short .end
.no_redraw_body:
	test dl, ACTFLAG_REDRAW_WIN
	jz .no_redraw_win
	call window_draw_window
	jmp short .end
.no_redraw_win:
	test dl, ACTFLAG_REDRAW_SCR
	jz .end
	call window_draw_all
.end:
	popa
	ret

;=============================================================================
; winlist_setroot ---- set root window
; input:
;	ds:si -> pointer to root window
; output:
;	none
;=============================================================================
winlist_setroot:
	push bx

	or si, si
	jz .invalid_root

	mov bx, [ui_tmp.root_win]
	or bx, bx
	jz .no_root
	mov bx, [bx + struc_window.next_win]

.no_root:
	mov [ui_tmp.root_win], si
	mov [si + struc_window.next_win], bx
	xor bx, bx
	mov [si + struc_window.previous_win], bx
	mov [si + struc_window.parent_win], bx

.invalid_root:
	pop bx
	ret

;=============================================================================
; winlist_insert ---- insert a window
; input:
;	ds:si -> pointer to the window
; output:
;	none
;=============================================================================
winlist_insert:
	push di
	or si, si
	jz .invalid_win
	call winlist_findwin
	jnc .invalid_win

	call winlist_findtop
	or di, di
	jz .invalid_win

	mov [di + struc_window.next_win], si
	mov [si + struc_window.previous_win], di
	xor di, di
	mov [si + struc_window.next_win], di

.invalid_win:
	pop di
	ret

;=============================================================================
; winlist_remove ---- remove a window
; input:
;	ds:si -> pointer to the window
; output:
;	none
;=============================================================================
winlist_remove:
	or si, si
	jz .invalid_win
	cmp [ui_tmp.root_win], si
	je .invalid_win
	call winlist_findwin
	jc .invalid_win

	push bx
	push si
	mov bx, [si + struc_window.next_win]
	mov si ,[si + struc_window.previous_win]
	or bx, bx
	jz .no_next
	mov [bx + struc_window.previous_win], si
.no_next:
	or si, si
	jz .no_previous
	mov [si + struc_window.next_win], bx
.no_previous:
	pop si
	xor bx, bx
	mov [si + struc_window.next_win], bx
	mov [si + struc_window.previous_win], bx
	pop bx

.invalid_win:
	ret

;=============================================================================
; winlist_findtop ---- find the top window
; input:
;	none
; output:
;	ds:di -> the top window
;=============================================================================
winlist_findtop:
	push ax
	mov di, [ui_tmp.root_win]

.loop_find:
	mov ax, [di + struc_window.next_win]
	or ax, ax
	jz .find_it
	mov di, ax
	jmp short .loop_find

.find_it:
	pop ax
	ret

;=============================================================================
; winlist_raise ---- raise a window to top
; input:
;	ds:si -> the window
; output:
;	none
;=============================================================================
winlist_raise:
	call winlist_remove
	call winlist_insert
	ret

;=============================================================================
; winlist_set_focus_win ---- set the focus window
; input:
;	ds:si -> the window
; output:
;	none
;=============================================================================
winlist_set_focus_win:
	push bx
	push si
	mov si, [ui_tmp.focus_win]
	mov bx, si
	call winlist_findwin
	pop si
	jc .ok

	test byte [si], WINFLAG_MODAL
	jnz .ok
	test byte [bx], WINFLAG_MODAL
	jnz .end

.ok:
	call winlist_findwin
	jc .end
	mov [ui_tmp.focus_win], si
.end:
	mov si, [ui_tmp.focus_win]
	call winlist_raise
	call window_draw_all
	pop bx
	ret

;=============================================================================
; winlist_findwin ---- find a window in winlist
; input:
;	ds:si -> the window
; output:
;	cf = 0  found
;	cf = 1  not found
;=============================================================================
winlist_findwin:
	push bx
	mov bx, [ui_tmp.root_win]
.loop_find:
	cmp bx, si
	je .found
	mov bx, [bx + struc_window.next_win]
	or bx, bx
	jnz .loop_find
	stc
	pop bx
	ret
.found:
	clc
	pop bx
	ret

;=============================================================================
; winlist_find_focusable ---- find a focusable window
; input:
;	ds:si -> the first win
; output:
;	ds:si -> the focusable win
;=============================================================================
winlist_find_focusable:
	call winlist_findwin
	jc .failed

.loop_find:
	test byte [si], WINFLAG_NO_FOCUS
	jz .found
	mov si, [si + struc_window.next_win]
	or si, si
	jnz .loop_find
.failed:
	xor si, si
.found:
	ret


;=============================================================================
; winlist_broadcast_event ---- broadcast an event to all opened windows
; input:
;	ax = event code
; output:
;	none
;=============================================================================
winlist_broadcast_event:
	pusha
	mov si, [ui_tmp.root_win]

.loop_broadcast:
	call window_event_dispatcher
	jnc .end
	mov si, [si + struc_window.next_win]
	or si, si
	jnz .loop_broadcast
.end:
	popa
	ret


%ifndef MAIN
get_event:

.loop_get_event:
	call check_keyevent
	or ax, ax
	jz .loop_get_event
	ret


;=============================================================================
; main_auth_action  ---- auth an action
; input:
;	al =  auth type
; output:
;	cf =  0 auth ok
;	cf =  1 auth failed.
;=============================================================================
main_auth_action:
	clc
	ret
%endif


;=============================================================================
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Private Data Area >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;=============================================================================
ui_VideoHorizParams dw 0x6B00,0x5901,0x5A02,0x8E03,0x5F04,0x8C05,0x2D13 ;8-wide

ui_screen_size:
ui_screen_width     db     90
ui_screen_height    db     25

ui_screen_bufseg     dw     SCR_BUF_SEG0
ui_screen_page       db     0
ui_screen_lock       db     0


window_def_action_table:
	db	ACTFLAG_REDRAW_SCR
	dw	kbCtrlUp
	dw	window_move_up

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhCtrlUp
	dw	window_move_up

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhHome
	dw	window_move_up

	db	ACTFLAG_REDRAW_SCR
	dw	kbCtrlDown
	dw	window_move_down

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhCtrlDown
	dw	window_move_down

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhEnd
	dw	window_move_down

	db	ACTFLAG_REDRAW_SCR
	dw	kbCtrlLeft
	dw	window_move_left

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhCtrlLeft
	dw	window_move_left

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhDel
	dw	window_move_left

	db	ACTFLAG_REDRAW_SCR
	dw	kbCtrlRight
	dw	window_move_right

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhCtrlRight
	dw	window_move_right

	db	ACTFLAG_REDRAW_SCR
	dw	kbEnhPgDn
	dw	window_move_right

	db	0
	dw	kbCtrlTab
	dw	window_switch_window

	db	0
	dw	kbAltTab
	dw	window_switch_window
.end_of_table

inputbox_action_table:
	db	ACTFLAG_REDRAW_BODY
	dw	kbBack
	dw	inputbox_backspace

	db	ACTFLAG_REDRAW_BODY
	dw	kbDel
	dw	inputbox_delete

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhDel
	dw	inputbox_delete

	db	ACTFLAG_REDRAW_BODY
	dw	kbHome
	dw	inputbox_home_key

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhHome
	dw	inputbox_home_key

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnd
	dw	inputbox_end_key

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhEnd
	dw	inputbox_end_key

	db	ACTFLAG_REDRAW_BODY
	dw	kbLeft
	dw	inputbox_left_arrow

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhLeft
	dw	inputbox_left_arrow

	db	ACTFLAG_REDRAW_BODY
	dw	kbRight
	dw	inputbox_right_arrow

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhRight
	dw	inputbox_right_arrow

	db	ACTFLAG_CLOSE_WIN
	dw	kbEsc
	dw	inputbox_cancel

	db	ACTFLAG_CLOSE_WIN
	dw	kbEnter
	dw	inputbox_enter

	db	ACTFLAG_CLOSE_WIN
	dw	kbEnhEnter
	dw	inputbox_enter

.end_of_table

listbox_action_table:
	db	ACTFLAG_CLOSE_WIN
	dw	kbEnter
	dw	0

	db	ACTFLAG_CLOSE_WIN
	dw	kbEnhEnter
	dw	0

	db	ACTFLAG_CLOSE_WIN
	dw	kbEsc
	dw	listbox_cancel
.end_of_table

menubox_def_action_table:
	db	ACTFLAG_REDRAW_BODY
	dw	kbUp
	dw	menubox_focus_up

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhUp
	dw	menubox_focus_up

	db	ACTFLAG_REDRAW_BODY
	dw	kbDown
	dw	menubox_focus_down

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhDown
	dw	menubox_focus_down

	db	ACTFLAG_REDRAW_BODY
	dw	kbPgUp
	dw	menubox_focus_pageup

	db	ACTFLAG_REDRAW_BODY
	dw	kbPgDn
	dw	menubox_focus_pagedown

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnter
	dw	menubox_do_focus

	db	ACTFLAG_REDRAW_BODY
	dw	kbEnhEnter
	dw	menubox_do_focus

	db	ACTFLAG_CLOSE_WIN
	dw	kbEsc
	dw	0

        db      ACTFLAG_CLOSE_WIN
        dw      EVENT_ALT_RELEASE
        dw      0
.end_of_table



; ===========================================================================
%ifndef MAIN

; how to draw window frame
keyboard_type       db  0x10       ; keyboard type, 0x10 = enhanced keyboard
draw_frame_method   db  0          ; = 0 means draw all frame using frame attr.
                                   ; = 1 means draw top horizontal line using
                                   ;     title attr.
                                   ; = 2 means draw top corner and horizontal
                                   ;     line using title attr.
color:
.win_title_inactive db  0x70        ; title attribute for inactive window.

.list_box:
.list_box_frame      db  0x30
.list_box_title      db  0xBF
.list_box_header     db  0x30
.list_box_normal     dw  0x3C30
.list_box_focus      dw  0x0C0F
.list_box_scrollbar  db  0x3F

.input_box:
.input_box_frame        db  0xB0        ;
.input_box_title        db  0xF1        ; input box
.input_box_msg          db  0xB0        ;

.error_box:
.error_box_frame        db  0xCF        ;
.error_box_title        db  0xF1        ; error box
.error_box_msg          db  0xCF        ;

.info_box:
.info_box_frame         db  0xB0        ;
.info_box_title         db  0xF1        ; info box
.info_box_msg           db  0xB0        ;



frame_char:
.top             db     0x020
.bottom          db     0x0CD
.left            db     0x0BA
.right           db     0x0BA
.tl_corner       db     0x0C9               ; top left corner
.tr_corner       db     0x0BB               ; top right corner
.bl_corner       db     0x0C8               ; bottom left corner
.br_corner       db     0x0BC               ; bottom right corner

size:
.box_width       db  5
.box_height      db  4

str_idx:
.input          dw  string.input

string:
.input          db     'Input',0

	section .bss
%include "tempdata.asm"

%endif

%endif	;End of HAVE_UI

; vi:nowrap
