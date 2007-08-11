; asmsyntax=nasm
;
; main-utils.asm
;
; utility functions for main program
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;


;=============================================================================
; >>>>>>>>>>>>>>>>>>>>>>>>> Initialization Functions <<<<<<<<<<<<<<<<<<<<<<<<<
;=============================================================================

;=============================================================================
; main_init_theme ---- initialize the theme data.
;=============================================================================
main_init_theme:
        mov bx, [icon.brand]
        or bx, bx
        jz .adjust_bkgnd                            ; no brand icon
        add word [icon.brand], theme_start          ;
.adjust_bkgnd:
        mov bx, [icon.background]
        or bx, bx
        jz .adjust_font                             ; no background icon
        add word [icon.background], theme_start
.adjust_font:
        mov bx, [font.data]
        or bx, bx
        jz .adjust_keymap
        add word [font.data], theme_start
.adjust_keymap:
        mov bx, [keymap.data]
        or bx, bx
        jz .adjust_str
        add word [keymap.data], theme_start

.adjust_str:
        lea si, [str_idx]
        mov cx, (end_of_str_idx - str_idx)/2
        
.loop_adjust:
        mov bx, [si]
        add bx, theme_start
        mov [si], bx
        add si, 2
        loop .loop_adjust

        mov al, 0x10
        and [keyboard_type], al

        ret
        
;=============================================================================
; main_init_all_menus ---- initialize the menus
;=============================================================================
main_init_all_menus:
        mov si, color.cmd_menu
;initialize main menu
        mov di, main_windows_data.main_menu
        call main_init_menu
	mov ax, [ADDR_SBMK_MAIN_MENU_POS]
	mov [main_windows_data.main_menu + struc_window.win_pos], ax
;initialize record menu
        mov di, main_windows_data.record_menu
        call main_init_menu
	mov ax, [ADDR_SBMK_RECORD_MENU_POS]
	mov [main_windows_data.record_menu + struc_window.win_pos], ax
;initialize system menu
        mov di, main_windows_data.sys_menu
        call main_init_menu
	mov ax, [ADDR_SBMK_SYS_MENU_POS]
	mov [main_windows_data.sys_menu + struc_window.win_pos], ax
;initialize boot menu
	mov ax, [ADDR_SBMK_BOOT_MENU_POS]
	mov [main_windows_data.boot_menu + struc_window.win_pos], ax
        call main_init_boot_menu
        ret

;=============================================================================
; main_init_menu
;input:
;       ds:si -> colors
;       ds:di -> struc_menu_box
;=============================================================================
main_init_menu:
        push si
        cld
        lodsw
        mov [di + struc_window.win_attr], ax
        lodsb
        mov [di + struc_menu_box.menu_header_attr], al
        lodsw
        mov [di + struc_menu_box.menu_norm_attr], ax
        lodsw
        mov [di + struc_menu_box.menu_focus_attr], ax
        lodsb
        mov [di + struc_menu_box.scrollbar_attr], al
        mov si, di
        call menubox_adjust_geometry
        pop si
        ret

;=============================================================================
; main_init_boot_menu
;=============================================================================
main_init_boot_menu:
        pusha
;initialize boot menu
        mov di, main_windows_data.boot_menu
        mov al, [size.boot_menu_win_height]
        mov [di + struc_window.win_size + 1], al        ; set boot menu height

;set boot menu header
        movzx ax, byte [ADDR_SBMK_BOOTMENU_STYLE]
        mov bx, str_idx.boot_menu_header
        cmp al, 3
        jbe .bmstyle_ok
        xor al, al

.bmstyle_ok:
        shl al, 1
        add bx, ax
        mov [di + struc_menu_box.menu_header], bx

;init the color and geometry of boot menu
        mov si, color.boot_menu
        call main_init_menu

; set position of boot menu window 

        mov ax, [di + struc_window.win_pos]
        mov bl, al

        add bl, [di + struc_window.win_size]
        add bl, 2
        cmp bl, [ui_screen_width]
        jb .bmpos_ok

        mov al, [ui_screen_width]
        sub al, [di + struc_window.win_size]
        sub al, 2

.bmpos_ok:
        mov [di + struc_window.win_pos], ax
        popa
        ret

;=============================================================================
;main_init_video ---- init the video mode
;input:
;      none
;output:
;      none
;=============================================================================
main_init_video:
	pusha
        mov al, [video_mode]
        mov bl, 8
        mov bp, [font.data]
        mov cx, [font.number]
        
        call set_video_mode
	popa
        ret

;=============================================================================
;main_init_good_record_list ---- init the good boot record list
;input:
;      none
;output:
;      cf = 0 sucess
;      cf = 1 failed, no good record
;=============================================================================
main_init_good_record_list:
        cld
        pusha
        mov cx, MAX_RECORD_NUM
        lea di, [main_tmp.good_record_list]
        lea si, [ADDR_SBMK_BOOT_RECORDS]
        xor ax, ax

.loop_check:
        call check_bootrecord                   ; check if it's valid
        jc .check_next
        stosb                                   ; store it's index to buffer
        inc ah
        
.check_next:
        inc al
        add si, SIZE_OF_BOOTRECORD
        loop .loop_check

        mov [GOOD_RECORD_NUMBER], ah
        or ah, ah
        jnz .ok
        stc
.ok:
        popa
        ret

;=============================================================================
;init_boot_records ---- init the boot records list
;input:
;      none
;output:
;      none
;=============================================================================
main_init_boot_records:
        pusha
        inc byte [main_tmp.change_occured]         ; some changes occured.

        cld
        mov si, ADDR_SBMK_BOOT_RECORDS
        mov di, main_tmp.records_buf

	mov cx, MAX_RECORD_NUM * SIZE_OF_BOOTRECORD
	call clear_memory

        mov ax, SIZE_OF_BOOTRECORD        ; ax = size of bootrecord
        mov cx, MAX_RECORD_NUM            ; cx = max record number

        mov bl, cl

        push si
        push cx                           ; cx = MAX_RECORD_NUM
.bkp_good_records:
        call check_bootrecord
        jc .bad_record

        push si
        push cx
        mov cx, ax
        rep movsb
        pop cx
        pop si

        dec bl
        
.bad_record:
        add si, ax
        loop .bkp_good_records

        pop cx                           ; cx = MAX_RECORD_NUM
        pop si                           ; si -> boot_records
        xchg si, di                      ; di -> boot_records

        push di
	push ax
        xor dl, dl
        test byte [ADDR_SBMK_FLAGS], KNLFLAG_ONLYPARTS
	setnz al
        call search_records
	pop ax
        pop di

;search finished, find out new records
        mov cx, MAX_RECORD_NUM
        xchg si, di                      ; si -> boot_records

        push si

        or bl, bl
        jz .no_space

.search_news:
        push di
        mov di, main_tmp.records_buf
        call main_find_record_in_buf
        pop di

        jnc .found

        push cx
        push si
        mov cx, ax
        rep movsb
        pop si
        pop cx

        dec bl

.found:
        or bl, bl
        jz .no_space
        add si, ax
        loop .search_news

.no_space:

        pop di
        mov si, main_tmp.records_buf
	mov cx, MAX_RECORD_NUM * SIZE_OF_BOOTRECORD
        rep movsb

        popa
        ret

;=============================================================================
; main_find_record_in_buf ---- find a record in a buffer
; input:
;      ds:si -> the record
;      es:di -> the buffer
; output:
;      cf = 1 not found
;=============================================================================
main_find_record_in_buf:
        pusha
	mov bx, [si]				; flags
        test bx, DRVFLAG_DRIVEOK|INFOFLAG_ISSPECIAL

        jz .not_found

        mov cx, MAX_RECORD_NUM

.compare_next:
	test bx, INFOFLAG_ISSPECIAL
	jz .normal_rec
	test word [di], INFOFLAG_ISSPECIAL
	jnz .special_rec
	jmp short .not_same

.normal_rec:
	test word [di], DRVFLAG_DRIVEOK
	jz .not_same
        mov ax, [di + struc_bootrecord.drive_id]
        cmp [si + struc_bootrecord.drive_id], ax
        jne .not_same
        mov eax, [di + struc_bootrecord.father_abs_addr]
        cmp [si + struc_bootrecord.father_abs_addr], eax
        jne .not_same
        mov eax, [di + struc_bootrecord.abs_addr]
        cmp [si + struc_bootrecord.abs_addr], eax
        jne .not_same

.special_rec:
        mov al, [di + struc_bootrecord.type]
        cmp [si + struc_bootrecord.type], al
        jne .not_same

        jmp short .found_same

.not_same:
        add di, SIZE_OF_BOOTRECORD
        loop .compare_next

.not_found:
        stc
        popa
        ret

.found_same:
        clc
        popa
        ret


;=============================================================================
; >>>>>>>>>>>>>>>>>>>>>>>>> User Interface Functions <<<<<<<<<<<<<<<<<<<<<<<<<
;=============================================================================

;=============================================================================
;root_window_draw_body_proc ---- draw the root window
;input:
;      none
;output:
;      none
;=============================================================================
root_window_draw_body_proc:
        mov bh, [color.background]              ;
        mov si, [icon.background]               ; draw background
        mov cx, [icon.background_size]          ;
        call draw_background                    ;

        xor dx, dx                              ;
        mov bx, [color.copyright]               ;
        mov al, [ui_screen_width]               ; draw copyright message
        push ax                                 ; save screen width
        mov cl, [size.copyright]
        mul cl
        mov cx, ax
        mov al, ' '                             ;
        call draw_char                          ;
        mov si, [str_idx.copyright]
        call draw_string_hl
        
        mov bx, [color.hint]                    ;
        mov dh, [ui_screen_height]              ;
        mov cl, [size.hint]                     ;
        sub dh, cl                              ; draw hint message
        pop ax                                  ; get screen width
        mul cl                                  ;
        mov cx, ax                              ;
        mov al, ' '                             ;
        call draw_char                          ;
        mov si, [str_idx.hint]                  ;
        call draw_string_hl                     ;

        mov dx, [position.brand]                ; draw brand icon
        mov cx, [icon.brand_size]               ;
        cmp dl, 0xFF                            ;
        jne .not_justify                        ;
        mov dl, [ui_screen_width]               ; right justify
        sub dl, cl                              ;
.not_justify:                                   ;
        mov si, [icon.brand]                    ;
        call draw_icon                          ;

        call root_window_draw_date
        call root_window_draw_time
        call root_window_draw_delay_time
        call root_window_draw_knl_flags

        ret
        
;=============================================================================
;root_window_draw_date ---- draw the date string
;input:
;      none
;output:
;      none
;=============================================================================
root_window_draw_date:
        pusha
        mov di, main_tmp.root_buf               ; draw date
        mov al, [show_date_method]              ;
        call get_current_date_string            ;
        mov si, di                              ;
        mov bl, [color.date]                    ;
        mov dx, [position.date]                 ;
        call draw_string                        ;
        popa
        ret

;=============================================================================
;draw_time ---- draw the time string
;input:
;      none
;output:
;      none
;=============================================================================
root_window_draw_time:
        pusha
        mov di, main_tmp.root_buf               ; draw date
        mov al, [show_time_method]              ;
        call get_current_time_string            ;
        mov si, di                              ;
        mov bl, [color.time]                    ;
        mov dx, [position.time]                 ;
        call draw_string                        ;
        popa
        ret

;=============================================================================
;root_window_draw_knl_flags ---- draw root passwd, login, secure mode, 
;                                remember last and int13 ext flags.
;=============================================================================
root_window_draw_knl_flags:
        mov dx, [ui_screen_size]
        sub dx, 0x0113
        mov cx, 1

; draw seperators
        mov bl, [color.hint]
        mov al, '|'
        call draw_char
	add dl,4
	call draw_char
	add dl,6
	call draw_char
	sub dl,9

; draw driver id
        mov di, main_tmp.root_buf
	push di
	push dx
	mov dl, [ADDR_SBMK_DRVID]
	call get_drvid_str
	pop dx
	pop si

        mov bl, [color.knl_drvid]

        call draw_string
        add dl, 4

; draw flags
        mov bl, [color.knl_flags]
        cmp dword [ADDR_SBMK_ROOT_PASSWORD], 0
        jz .no_root_password
        
        mov al, 'P'
        jmp short .draw_pwd
.no_root_password:
        mov al, '-'
.draw_pwd:
        call draw_char
        inc dl

	mov ah, [ADDR_SBMK_FLAGS]

        test ah, KNLFLAG_SECURITY
        jz .no_security

        mov al, 'S'
        jmp short .draw_security
.no_security:
        mov al, '-'
.draw_security:
        call draw_char
        inc dl

        cmp byte [main_tmp.root_login],0
        jz .no_root_login

        mov al, 'A'
        jmp short .draw_login
.no_root_login:
        mov al, '-'
.draw_login:
        call draw_char

        inc dl

        test ah, KNLFLAG_REMLAST
        jz .no_remlast
        mov al, 'L'
        jmp short .draw_remlast
.no_remlast:
        mov al, '-'
.draw_remlast:
        call draw_char

        inc dl

        test ah, KNLFLAG_NOINT13EXT
        jnz .no_int13ext
        mov al, 'E'
        jmp .draw_int13ext
.no_int13ext:
        mov al, '-'
.draw_int13ext:
        call draw_char
        ret

;=============================================================================
;root_window_draw_delay_time ---- draw the delay_time and time_count
;=============================================================================
root_window_draw_delay_time:
        movzx ax, byte [main_tmp.time_count]
        mov cx, 3
        mov di, main_tmp.root_buf
        call itoa
        
        mov bl, [color.delay_time]
        mov dx, [ui_screen_size]
        sub dx, 0x0108
        mov si, di
        call draw_string

        movzx ax, byte [ADDR_SBMK_DELAY_TIME]
        mov cx, 3
        call itoa

        mov al, ':'
        mov cl, 1
        add dl, 3
        call draw_char
        inc dl
        call draw_string
        mov al, ' '
        add dl, 3
        call draw_char
        ret


;=============================================================================
; boot_menu_item_str_proc ---- get item string of boot menu
; input:
;	cx = index
; output:
;	ds:si -> item string
;=============================================================================
boot_menu_item_str_proc:
	call main_get_record_pointer

	cld
        lea di, [main_tmp.record_string]
	push di

	cmp cl, [ADDR_SBMK_DEFAULT_BOOT]
	jne .not_def
	mov al, '*'
.not_def:
	stosb

        mov al, [ADDR_SBMK_BOOTMENU_STYLE]
        call get_record_string
	pop si
	ret

;=============================================================================
; main_menu_item_str_proc ---- get item string of main menu
; input:
;	cx = index
; output:
;	ds:si -> item string
;=============================================================================
main_menu_item_str_proc:
	mov si, str_idx.main_menu_strings
	jmp short main_get_cmd_menu_item_str

;=============================================================================
; record_menu_item_str_proc ---- get item string of record menu
; input:
;	cx = index
; output:
;	ds:si -> item string
;=============================================================================
record_menu_item_str_proc:
	mov si, str_idx.record_menu_strings
	jmp short main_get_cmd_menu_item_str

;=============================================================================
; sys_menu_item_str_proc ---- get item string of sys menu
; input:
;	cx = index
; output:
;	ds:si -> item string
;=============================================================================
sys_menu_item_str_proc:
	mov si, str_idx.sys_menu_strings
	jmp short main_get_cmd_menu_item_str

;=============================================================================
; main_get_cmd_menu_item_str ---- get item string of a command menu
; input:
;	cx = index
;	ds:si -> str_idx
; output:
;	ds:si -> item string
;=============================================================================
main_get_cmd_menu_item_str:
	shl cx,1
	add si, cx
	mov si, [si]
	ret

;=============================================================================
;main_check_update_time ---- check if the time message needs update.
;output:
;	cf = 0 not changed
;	cf = 1 changed
;=============================================================================
main_check_update_time:
	push ax
        mov ah, 0x02
        int 0x1a

        cmp [main_tmp.last_time], cx
        je .end

        mov [main_tmp.last_time], cx
	stc
	pop ax
	ret
.end:
	clc
	pop ax
        ret


;=============================================================================
;main_check_delay_time ---- check if the delay time is up
; output:
;	cf = 0 not zero
;	cf = 1 zero
;=============================================================================
main_check_delay_time:
        xor ah, ah                                      ; get time ticks
        int 0x1a                                        ;

        cmp dx, [main_tmp.ticks_count]
        jae .next_time                                  ; dx must greater than
        mov [main_tmp.ticks_count], dx                  ; ticks_count
.next_time:
	xor ax, ax
        mov cx, dx                                      ; every 18 ticks approxmiately
        sub cx, [main_tmp.ticks_count]                  ; equal to 1 second,
        cmp cx, 18                                      ; decrease time_count
        jbe .not_add                                    ; until to zero.
        mov [main_tmp.ticks_count], dx
        dec byte [main_tmp.time_count]
	inc ax
.not_add:
        cmp byte [main_tmp.time_count], 0               ; if time is up, then
        jne .no_up                                      ; send ESC key.
	stc
	ret

.no_up:
	clc
	ret

;=============================================================================
;get_event ---- get a event, if no key is pressed then count down the 
;               delay time until to zero and send an EVENT_BOOT_DEFAULT event
;input:
;      none
;output:
;      ax = the key code
;=============================================================================
get_event:
	pusha

	xor ax, ax

.loop_get_event:
	call main_check_update_time
	jnc .no_update_time

	mov ax, EVENT_REDRAW_ROOT
	jmp short .cont_loop

.no_update_time:

	cmp byte [ADDR_SBMK_DELAY_TIME], 0
	je .no_count
	cmp byte [main_tmp.key_pressed], 0
	jne .no_count

	call main_check_delay_time
	jnc .has_delay
	mov ax, EVENT_BOOT_DEFAULT
	inc byte [main_tmp.key_pressed]
	jmp short .cont_loop

.has_delay
	or ax, ax
	jz .no_count
	mov ax, EVENT_REDRAW_ROOT
	jmp short .cont_loop

.no_count:
	call check_keyevent
	or ax, ax
	jz .cont_loop

.key_pressed:
	mov byte [main_tmp.key_pressed], 1

.cont_loop:
	or ax, ax
	jz .loop_get_event

	mov [main_tmp.keycode], ax
	popa
	mov ax, [main_tmp.keycode]
	ret
        

;=============================================================================
; main_auth_record_action
;=============================================================================
main_auth_record_action:
	mov al, ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD

;=============================================================================
; main_auth_action  ---- auth an action
; input:
;	al = auth type
; output:
;	cf = 0, success
;	cf = 1, failed
;=============================================================================
main_auth_action:
	pusha

	test al, ACTFLAG_CHK_RECNUM
	jz .test_security

	cmp byte [GOOD_RECORD_NUMBER], 0
	jz .auth_failed

.test_security:
        cmp byte [main_tmp.root_login], 0
        jnz .auth_ok

	test byte [ADDR_SBMK_FLAGS], KNLFLAG_SECURITY
	jz .test_root

	test al, ACTFLAG_AUTH_SECURITY
	jnz .auth_root

.test_root:
	test al, ACTFLAG_AUTH_ROOT
	jz .test_record

.auth_root:
	call main_confirm_root_passwd
	jc .auth_failed

.auth_ok:
	clc
	popa
	ret

.test_record:
	test al, ACTFLAG_AUTH_RECORD
	jz .auth_ok
	call main_confirm_record_passwd
	jnc .auth_ok

.auth_failed:
	stc
	popa
	ret

	
;=============================================================================
;main_confirm_root_passwd ---- confirm the root password
;input:
;      none
;output:
;      cf = 0 success
;      cf = 1 failed or cancel
;=============================================================================
main_confirm_root_passwd:
        pusha
        mov bx, [ADDR_SBMK_ROOT_PASSWORD]
        mov cx, [ADDR_SBMK_ROOT_PASSWORD+2]
        or bx, bx
        jnz .have_password
        or cx, cx
        jnz .have_password
        jmp short .auth_ok
        
.have_password:                                     
        mov si, [str_idx.root_passwd]               ; check root
        call main_confirm_passwd                    ; password
.auth_ok:
        popa
        ret

;=============================================================================
;main_confirm_record_passwd ---- confirm the record password
;=============================================================================
main_confirm_record_passwd:
        pusha
        call main_get_focus_record_pointer
        mov bx, [si + struc_bootrecord.password]
        mov cx, [si + struc_bootrecord.password+2]
        or bx, bx
        jnz .have_password
        or cx, cx
        jnz .have_password
        jmp short .auth_ok
        
.have_password:
        mov si, [str_idx.record_passwd]             ; check record
        call main_confirm_passwd                    ; password
.auth_ok:
        popa
        ret

;=============================================================================
;main_confirm_passwd ---- let user input a password and confirm it.
;input:
;      bx:cx = password
;      ds:si -> message string
;output:
;      cf = 0 success
;      cf = 1 failed or cancel
;=============================================================================
main_confirm_passwd:
        cmp byte [main_tmp.root_login],0       ; check if root has logined
        jnz .ok

	push cx
	mov cl, MAX_PASSWORD_LENGTH
        call input_password
	pop cx
        jc .cancel

        cmp bx, ax
        jne .cmp_root
        cmp cx, dx
        jne .cmp_root
        jmp .ok
        
.cmp_root:
        cmp [ADDR_SBMK_ROOT_PASSWORD], ax
        jne .failed
        cmp [ADDR_SBMK_ROOT_PASSWORD+2], dx
        jne .failed
.ok:
        clc
        ret
        
.failed:
        mov si, [str_idx.wrong_passwd]
        call error_box
        
.cancel:
        stc
        ret

;=============================================================================
; main_show_disk_error ---- show the disk error box.
;=============================================================================
main_show_disk_error:
        mov si, [str_idx.disk_error]
        mov di, main_tmp.dialog_buf
        push di
        call strcpy
	call get_last_disk_errno
        mov cl, 2
        call htoa
        pop si
        call error_box
        ret


;=============================================================================
;>>>>>>>>>>>>>>>>>>>>>>>>>> Miscellaneous Functions <<<<<<<<<<<<<<<<<<<<<<<<<<
;=============================================================================

;=============================================================================
;main_recheck_same_records ---- recheck all records that same as given record
;input:
;      ds:si -> record
;output:
;      cf = 0  success
;      cf = 1  failed
;=============================================================================
main_recheck_same_records:
        pusha
        mov ax, [si + struc_bootrecord.drive_id]
        mov ebx, [si + struc_bootrecord.father_abs_addr]
        mov edx, [si + struc_bootrecord.abs_addr]

        lea si, [ADDR_SBMK_BOOT_RECORDS]
        mov cx, MAX_RECORD_NUM

.loop_check:
        test byte [si + struc_bootrecord.flags], DRVFLAG_DRIVEOK
        jz .check_next
        cmp [si + struc_bootrecord.drive_id], ax
        jne .check_next
        cmp [si + struc_bootrecord.father_abs_addr], ebx
        jne .check_next
        cmp [si + struc_bootrecord.abs_addr], edx
        jne .check_next

        call check_bootrecord
        jc .end

.check_next:
        add si, SIZE_OF_BOOTRECORD
        loop .loop_check
        clc
.end:
        popa
        ret

;=============================================================================
;main_get_focus_record_pointer ---- get current boot record's pointer
;input:
;	none
;output:
;       ds:si -> record pointer
;=============================================================================
main_get_focus_record_pointer:
        xor si, si
        cmp byte [GOOD_RECORD_NUMBER], 0
        jz .end
	push cx
	mov cl, [FOCUS_RECORD]
	call main_get_record_pointer
	pop cx
.end:
	ret

;=============================================================================
;main_get_record_pointer ---- get boot record's pointer
;input:
;      cl = record index in good record list
;output:
;      cl = real index in boot_records list
;      ds:si -> record pointer
;=============================================================================
main_get_record_pointer:
        push ax
        xor ch, ch
        mov si, main_tmp.good_record_list       ;
        add si, cx                              ;
        lodsb                                   ;
	push ax

        mov cl, SIZE_OF_BOOTRECORD              ; get the pointer to
        mul cl                                  ; the record.
        mov si, ADDR_SBMK_BOOT_RECORDS          ;
        add si, ax                              ;
	pop cx
	xor ch, ch
        pop ax
        ret

;=============================================================================
;main_boot_default ---- boot the default record
;=============================================================================
main_boot_default:
        mov ah, [ADDR_SBMK_DEFAULT_BOOT]
        mov si, main_tmp.good_record_list
        movzx cx, [GOOD_RECORD_NUMBER]
        or cl, cl
        jz .no_default
        cld

.loop_search:
        lodsb
        cmp al, ah
        je .found_it
        loop .loop_search
        
.no_default:                                ; no default record, do nothing.
        ret
        
.found_it:
	push ax
	call main_hide_auto_hides
	pop ax
	xor ah, ah
        call main_do_boot_record
        ret
        
;=============================================================================
;main_do_boot_record ---- really boot the given record.
;input:
;      ax =  the boot record number.
;=============================================================================
main_do_boot_record:
        mov bl, SIZE_OF_BOOTRECORD
        mul bl

        mov si, ADDR_SBMK_BOOT_RECORDS
        add si, ax

	mov bx, [si + struc_bootrecord.flags]

	test bx, INFOFLAG_ISSPECIAL
	jz .boot_drv_part

	call main_do_special_record
	jmp short .end

.boot_drv_part:
%ifndef DISABLE_CDBOOT
	test bx, DRVFLAG_ISCDROM
	jz .normal_boot

	mov dl, [si + struc_bootrecord.drive_id]
	mov di, knl_tmp.disk_buf2
	call get_cdrom_boot_catalog
	jc .disk_error

	push si
	mov si, di
	mov di, knl_tmp.disk_buf1
	call find_cdboot_catalog
	pop si

	or cx, cx
	jz .no_system
	cmp cx, 1
	je .go_boot_cdrom

	push si
	mov si, di
	call main_choose_cdimg
	pop si
	jc .end

	mov cl, SIZE_OF_BOOT_CATALOG
	mul cl

	add di, ax

.go_boot_cdrom:
	push dx
	push di
        call preload_keystrokes     ; preload the keystrokes into key buffer.
        call reset_video_mode
	pop di
	pop dx
	call boot_cdrom
	jmp short .boot_fail

%endif

.normal_boot:
        call boot_normal_record

.boot_fail:
	call main_init_video

        or al, al
        jz .no_system

.disk_error:
        call main_show_disk_error
        ret

.no_system:
        mov si, [str_idx.no_system]
        call error_box

.end:
        ret
        

;=============================================================================
;main_do_special_record ---- execute a special boot record.
;input:
;      si ->  the boot record.
;=============================================================================
main_do_special_record:
	call reset_video_mode
	mov al, [si + struc_bootrecord.type]

	cmp al, SPREC_POWEROFF
	jne .chk_rst
	call power_off

.chk_rst:
	cmp al, SPREC_RESTART
	jne .chk_quit
	call reboot

.chk_quit:
	cmp al, SPREC_QUIT
	jne .chk_bootprev

%ifdef EMULATE_PROG
        mov ax, 0x4c00                          ; exit to dos
        int 0x21                                ;
%else
        int 0x18                                ; return to BIOS
%endif

.chk_bootprev:
	cmp al, SPREC_BOOTPREV
	jne .end
	call main_boot_prev_mbr

.end:
	ret

;=============================================================================
;main_do_schedule ---- implement the schedule table
;input:
;      none
;output:
;      default_boot set to the scheduled record
;=============================================================================
main_do_schedule:
        pusha
        call get_realtime
        jc .end

        mov [main_tmp.schedule_begin], ax
        mov [main_tmp.schedule_day], dx
        xor cx, cx
        mov si, ADDR_SBMK_BOOT_RECORDS

.loop_check:
        test word [si + struc_bootrecord.flags], INFOFLAG_SCHEDULED
        jz .check_next

        call check_bootrecord
        jc .check_next

        call get_record_schedule

        cmp [main_tmp.schedule_begin], ax 
        jb .check_next
        cmp [main_tmp.schedule_begin], bx
        ja .check_next

        test dx, [main_tmp.schedule_day]
        jz .check_next

        mov [ADDR_SBMK_DEFAULT_BOOT], cl

.check_next:
        inc cl
        add si, SIZE_OF_BOOTRECORD
        cmp cl, MAX_RECORD_NUM
        jb .loop_check

.end:
        popa
        ret

;=============================================================================
;main_save_boot_manager ---- save boot manager to disk.
;input:
;      none
;output:
;      cf = 0 success
;      cf = 1 failed
;=============================================================================
main_save_boot_manager:
	pusha
	push es
	push ds

; Backup the menus' pos
	mov ax, [main_windows_data.boot_menu + struc_window.win_pos]
	mov [ADDR_SBMK_BOOT_MENU_POS], ax
	mov ax, [main_windows_data.main_menu + struc_window.win_pos]
	mov [ADDR_SBMK_MAIN_MENU_POS], ax
	mov ax, [main_windows_data.record_menu + struc_window.win_pos]
	mov [ADDR_SBMK_RECORD_MENU_POS], ax
	mov ax, [main_windows_data.sys_menu + struc_window.win_pos]
	mov [ADDR_SBMK_SYS_MENU_POS], ax

; ;calculate checksum
; 	push es
; 	pop ds
; 
; 	xor si, si
; 	mov cx, end_of_kernel - start_of_kernel
; 	mov byte [ADDR_SBMK_CHECKSUM], 0
; 	call calc_checksum                      ; calculate the checksum.
; 	neg bl
; 	mov [ADDR_SBMK_CHECKSUM], bl

	mov dl, [ADDR_SBMK_DRVID]
	lea si, [ADDR_SBMK_BLOCK_MAP]
	mov cx, SBM_SAVE_NBLKS
	xor di, di

	pop ds

.loop_save_blk:
	push cx

	lodsb
	mov cl, al			; number of sectors for this block
	lodsd
	mov ebx,eax			; lba address for this block
        
	mov ax, ( INT13H_WRITE << 8 ) | 1 

	clc
	or cx, cx
	jz .write_end

.loop_write:
	call disk_access
	jc .write_end
        
	add di, SECTOR_SIZE
	inc ebx
	loop .loop_write

	pop cx
	loop .loop_save_blk

	clc
	jmp short .end

.write_end:
	pop cx

.end:
	pop es
	popa
	ret


;=============================================================================
;main_hide_auto_hides ---- hide all partitions that marked auto hide,
;                          except the focus record.
;input:
;      none
;output:
;      cf = 0 success
;      cf = 1 failed
;=============================================================================
main_hide_auto_hides:
        movzx cx, byte [GOOD_RECORD_NUMBER]
        or cl, cl                               ; if no good record then go to
        jz .end_ok                              ; init directly.

	xchg ch, cl
        
; hide all auto hide partitions.
.loop_hide:
        cmp cl, [FOCUS_RECORD]                  ; do not hide the focus record.
        je .not_hide

	push cx
	call main_get_record_pointer
	pop cx

        mov ax, [si + struc_bootrecord.flags]
        test ax, INFOFLAG_AUTOHIDE
        jz .not_hide
        test ax, INFOFLAG_HIDDEN
        jnz .not_hide

        call toggle_record_hidden
        jc .hidden_error

        call main_recheck_same_records
        jc .disk_error

.not_hide:
        inc cl
        cmp cl, ch
        jb .loop_hide
        
.end_ok:
        clc
        ret
        
.hidden_error:
        or ax, ax
        jz .cannot_hide

.disk_error:
        call main_show_disk_error
        jmp short .end

.cannot_hide:
        mov si, [str_idx.toggle_hid_failed]
        call error_box
.end:
        stc
        ret

;=============================================================================
; main_boot_prev_mbr ---- boot previous MBR
;=============================================================================
main_boot_prev_mbr:
; read partition table
        push es
        xor ebx, ebx
        mov es, bx
        mov dl, [ADDR_SBMK_DRVID]
        mov di, 7C00h
        mov ax, (INT13H_READ << 8) | 0x01
        call disk_access
        pop es
        jc .disk_failed

        push dx
        push di
        call main_ask_save_changes
        call main_hide_auto_hides
        call reset_video_mode
        pop di
        pop dx

	call uninstall_myint13h

; copy previous mbr to Boot Offset 0x7c00
        cld
        mov cx, SIZE_OF_MBR
;        lea si, [ADDR_SBMK_PREVIOUS_MBR]
        xor ax, ax
        push ax
        pop es
        rep movsb

        push ax
        pop ds

        xor bp, bp                          ; might help some boot problems
        mov ax, BR_GOOD_FLAG                ; boot signature (just in case ...)
        jmp 0:7C00h                         ; jump to the  boot sector

.disk_failed:
        call main_show_disk_error
.end:
        ret


;==============================================================================
; CD-ROM Boot Stuff
;==============================================================================

%ifndef DISABLE_CDBOOT
;==============================================================================
;main_choose_cdimg ---- let user choose a cdimg to boot
;input ds:si -> buffer to store boot catalogs
;      cl = number of entries
;output cf =0 ok, al = user choice
;       cf =1 cancel
;==============================================================================
main_choose_cdimg:
	push bx
	push cx
	push dx
	push si

	xor dx, dx
	mov [.catalogs_buf], si
	mov ch, [size.list_box_win_height]
	mov bx, str_idx.cdimg_menu_title

	mov si, .item_str_proc
	call list_box
	mov al, cl

	pop si
	pop dx
	pop cx
	pop bx
	ret

.item_str_proc:
	mov si, [.catalogs_buf]
	mov di, main_tmp.dialog_buf
	push di
	mov ax, SIZE_OF_BOOT_CATALOG
	mul cl
	add si, ax

	mov ax, cx
	mov cl, 2
	call itoa
	add di, 2
	mov ax, '. '
	cld
	stosw

	movzx ax, [si + struc_boot_catalog.media_type]

	shl al, 1

	mov si, str_idx.cdimg_menu_strings
	add si, ax
	mov si, [si]
	call strcpy
	pop si
	ret

.catalogs_buf dw 0

%endif
