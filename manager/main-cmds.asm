; asmsyntax=nasm
;
; main-cmds.asm
;
; command handles for main program
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

;=============================================================================
;main_show_help ---- show the help window
;=============================================================================
main_show_help:
        mov si, [str_idx.help_content]
        or si, si
        jz .end
        
	mov al, [color.help_msg]
	mov bx, [color.help_win]
        mov dx, str_idx.help
        call message_box
.end:
        ret

;=============================================================================
;main_show_about ---- show the about window
;=============================================================================
main_show_about:
        mov si, [str_idx.about_content]
        or si, si
        jz .end
        
        mov al, [color.about_msg]
        mov bx, [color.about_win]
        mov dx, str_idx.about
        call message_box
.end:
        ret

;=============================================================================
;main_show_main_menu ---- show the main command menu
;=============================================================================
main_show_main_menu:
	mov si, main_windows_data.main_menu
	call window_run
	ret

;=============================================================================
;main_show_record_menu ---- show the record command menu
;=============================================================================
main_show_record_menu:
	mov si, main_windows_data.record_menu
	call window_run
	ret

;=============================================================================
;main_show_sys_menu ---- show the sys command menu
;=============================================================================
main_show_sys_menu:
	mov si, main_windows_data.sys_menu
	call window_run
	ret

;=============================================================================
;main_ask_save_changes ---- save boot manager to disk
;=============================================================================
main_ask_save_changes:
        cmp byte [main_tmp.change_occured], 0
        je .no_changes
        
        mov si, [str_idx.ask_save_changes]
        call info_box
        cmp ax, kbEnter
        je main_save_changes
        cmp al, [yes_key_lower]
        je main_save_changes
        cmp al, [yes_key_upper]
        je main_save_changes
        
.no_changes:
        ret

;=============================================================================
;main_save_changes ---- save boot manager to disk
;=============================================================================
main_save_changes:

%ifndef EMULATE_PROG
        call main_save_boot_manager
        jc .disk_error
%endif

        mov byte [main_tmp.change_occured], 0       ; clear change signature.

        mov si, [str_idx.changes_saved]
        call info_box
        ret

.disk_error:
        call main_show_disk_error
.end:
        ret

%if 0
;=============================================================================
;main_change_video_mode ---- change the video mode
;=============================================================================
main_change_video_mode:

        inc byte [change_occured]               ; some changes occured.

        mov al, [video_mode]
        not al
        mov [video_mode], al
        call init_video
        call draw_screen
        ret
%endif

;=============================================================================
;main_change_name ---- change the record name
;=============================================================================
main_change_name:
        call main_get_focus_record_pointer

	mov di, si
	add di, struc_bootrecord.name

        movzx ax, byte [color.input_box_msg]
        mov bx, [color.input_box]
	mov cx, (MAX_NAME_LENGTH<<8)|MAX_NAME_LENGTH
	xor dx, dx
        mov si, [str_idx.name]
        
        call input_box
        jc .end
        inc byte [main_tmp.change_occured]          ; some changes occured.
.end:
        ret


;=============================================================================
;main_login_as_root ---- login as root
;=============================================================================
main_login_as_root:
	mov al, [main_tmp.root_login]
	or al, al
	setz al
	mov [main_tmp.root_login], al
        ret


;=============================================================================
;main_change_security_mode ---- change the secure mode
;=============================================================================
main_change_security_mode:
	xor byte [ADDR_SBMK_FLAGS], KNLFLAG_SECURITY
        inc byte [main_tmp.change_occured]
        ret

;=============================================================================
;main_change_root_password ---- change the root password
;=============================================================================
main_change_root_password:
	mov cl, MAX_PASSWORD_LENGTH
        mov si, [str_idx.new_root_passwd]
        call input_password
        jc .end
        mov bx, ax
        mov cx, dx

        push bx
        push cx
	mov cl, MAX_PASSWORD_LENGTH
        mov si, [str_idx.retype_passwd]
        call input_password
        pop cx
        pop bx
        jc .end
        cmp bx, ax
        jne .wrong
        cmp cx, dx
        jne .wrong

        mov [ADDR_SBMK_ROOT_PASSWORD], bx
        mov [ADDR_SBMK_ROOT_PASSWORD+2], cx

        mov byte [main_tmp.root_login], 0
        and byte [ADDR_SBMK_FLAGS], ~ KNLFLAG_SECURITY

        mov si, [str_idx.passwd_changed]
        call info_box

        inc byte [main_tmp.change_occured]         ; some changes occured.
        jmp short .end
.wrong:
        mov si, [str_idx.wrong_passwd]
        call error_box
.end:
        ret

;=============================================================================
;main_change_record_password ---- change the record password
;=============================================================================
main_change_record_password:
	mov cl, MAX_PASSWORD_LENGTH
        mov si, [str_idx.new_record_passwd]
        call input_password
        jc .end
        mov bx, ax
        mov cx, dx

        push bx
        push cx
	mov cl, MAX_PASSWORD_LENGTH
        mov si, [str_idx.retype_passwd]
        call input_password
        pop cx
        pop bx
        jc .end
        cmp bx, ax
        jne .wrong
        cmp cx, dx
        jne .wrong

        call main_get_focus_record_pointer
        mov [si+struc_bootrecord.password], bx
        mov [si+struc_bootrecord.password+2], cx
        
        mov si, [str_idx.passwd_changed]
        call info_box

        inc byte [main_tmp.change_occured]         ; some changes occured.
        ret
        
.wrong:
        mov si, [str_idx.wrong_passwd]
        call error_box
.end:
        ret

;=============================================================================
;main_set_default_record ---- set the default boot record
;=============================================================================
main_set_default_record:
	mov cl, [FOCUS_RECORD]
	call main_get_record_pointer           ; get real record index

        mov [ADDR_SBMK_DEFAULT_BOOT], cl
        inc byte [main_tmp.change_occured]      ; some changes occured.
        ret

;=============================================================================
;main_unset_default_record ---- unset the default boot record
;=============================================================================
main_unset_default_record:
        mov byte [ADDR_SBMK_DEFAULT_BOOT], 0xFF
        inc byte [main_tmp.change_occured]      ; some changes occured.
        ret
        
;=============================================================================
;main_toggle_auto_active ---- toggle the auto active switch
;=============================================================================
main_toggle_auto_active:
        call main_get_focus_record_pointer
        call check_allow_act
        jc .end

	call main_auth_record_action
	jc .end

        xor word [si + struc_bootrecord.flags], INFOFLAG_AUTOACTIVE
        inc byte [main_tmp.change_occured]        ; some changes occured.
.end:
        ret

;=============================================================================
;main_toggle_auto_hide ---- toggle the auto hide switch
;=============================================================================
main_toggle_auto_hide:
        call main_get_focus_record_pointer
        call check_allow_hide
        jc .end

	call main_auth_record_action
	jc .end
        
        xor word [si + struc_bootrecord.flags], INFOFLAG_AUTOHIDE
        inc byte [main_tmp.change_occured]        ; some changes occured.

.end:
        ret

;=============================================================================
;main_mark_active ---- mark the record active
;=============================================================================
main_mark_active:
        call main_get_focus_record_pointer
        call check_allow_act
        jc .end

	call main_auth_record_action
	jc .end

        mov dl, [si + struc_bootrecord.drive_id]

        push si
        lea si, [main_tmp.good_record_list]
        lea di, [ADDR_SBMK_BOOT_RECORDS]

        movzx cx, byte [GOOD_RECORD_NUMBER]
        mov dh, SIZE_OF_BOOTRECORD
        xor ebx, ebx
        cld
.loop_clear_act:                                ; clear all active marks of
        push di                                 ; the boot records in same
        lodsb                                   ; drive and father partition.
        mul dh
        add di, ax
        cmp dl, [di + struc_bootrecord.drive_id]
        jne .do_nothing
        cmp [di + struc_bootrecord.father_abs_addr], ebx
        jne .do_nothing
        and word [di + struc_bootrecord.flags], ~ INFOFLAG_ACTIVE
.do_nothing:
        pop di
        loop .loop_clear_act

        pop si
        
        call mark_record_active
        jc .error                                ; mark active ok
        call main_recheck_same_records           ; recheck same records
        jc .disk_error
        ret

.error:
        or ax, ax
        jz .cannot_act

.disk_error:
        call main_show_disk_error
        ret

.cannot_act:
        mov si, [str_idx.mark_act_failed]
        call error_box
.end:
        ret

;=============================================================================
;main_toggle_hidden ---- toggle a record's hidden attribute
;=============================================================================
main_toggle_hidden:
        call main_get_focus_record_pointer
        call check_allow_hide
        jc .end

	call main_auth_record_action
	jc .end

        call toggle_record_hidden
        jc .error                                 ; toggle hidden ok
        call main_recheck_same_records            ; recheck same records
        jc .disk_error
        ret

.error:
        or ax, ax
        jz .cannot_hide

.disk_error:
        call main_show_disk_error
        ret

.cannot_hide:
        mov si, [str_idx.toggle_hid_failed]
        call error_box
.end:
        ret

;=============================================================================
;main_delete_record ---- delete a boot record
;=============================================================================
main_delete_record:
        call main_get_focus_record_pointer
        test word [si + struc_bootrecord.flags], INFOFLAG_HIDDEN
        jz .del_it

        call toggle_record_hidden           ; unhide it first.
        jnc .del_it                         ; unhide ok, del it.

        or ax, ax
        jz .cannot_hide
        call main_show_disk_error
        ret

.cannot_hide:
        mov si, [str_idx.toggle_hid_failed]
        call error_box
        ret

.del_it:
        xor al, al
        mov di, si
        mov cx, SIZE_OF_BOOTRECORD
        cld
        rep stosb

        inc byte [main_tmp.change_occured]               ; some changes occured.

        call main_init_good_record_list
        mov al, [GOOD_RECORD_NUMBER]
        or al, al
        jz .no_record
        
        dec al
        cmp al, [FIRST_VISIBLE_RECORD]                  ; adjust the cursor
        jae .check_focus_pos                            ; and menu position.
        mov [FIRST_VISIBLE_RECORD], al                  ;
.check_focus_pos:                                       ;
        cmp al, [FOCUS_RECORD]                          ;
        jae .end                                        ;
        mov [FOCUS_RECORD], al                          ;
        ret

.no_record:
        mov [FIRST_VISIBLE_RECORD], al
        mov [FOCUS_RECORD], al
.end:
        ret
        

;=============================================================================
;main_rescan_all_drives ---- research all drives for boot records
;=============================================================================
main_rescan_all_records:
        and byte [ADDR_SBMK_FLAGS], ~ KNLFLAG_ONLYPARTS
        jmp short main_rescan_records
        
;=============================================================================
;rescan_fixed_drives ---- research fixed drives for boot records
;=============================================================================
main_rescan_all_partitions:
        or byte [ADDR_SBMK_FLAGS], KNLFLAG_ONLYPARTS
        
;=============================================================================
;rescan_records ---- research all drives for boot records
;=============================================================================
main_rescan_records:
        movzx cx, byte [GOOD_RECORD_NUMBER]
        or cl, cl                               ; if no good record then go to
        jz .init_it                             ; init directly.
        
        lea di, [main_tmp.good_record_list]
        mov dl, SIZE_OF_BOOTRECORD

; unhide all hidden partition first.
.loop_unhide:
        mov al, [di]
        inc di
        mul dl
        lea si, [ADDR_SBMK_BOOT_RECORDS]
        add si, ax
        test word [si + struc_bootrecord.flags], INFOFLAG_HIDDEN
        jz .not_hidden
        call toggle_record_hidden
        jc .hidden_error
        call main_recheck_same_records
        jc .disk_error

.not_hidden:
        loop .loop_unhide
        
.init_it:
        inc byte [main_tmp.change_occured]               ; some changes occured.

        call main_init_boot_records
        call main_init_good_record_list

        xor al, al
        mov byte [FOCUS_RECORD], al
        mov byte [FIRST_VISIBLE_RECORD], al
	ret
        
.hidden_error:
        or ax, ax
        jz .cannot_hide

.disk_error:
        call main_show_disk_error
        ret

.cannot_hide:
        mov si, [str_idx.toggle_hid_failed]
        call error_box
.end:
        ret

;=============================================================================
;main_set_delay_time ---- set the delay time
;=============================================================================
main_set_delay_time:
        movzx ax, [color.input_box_msg]
        mov bx, [color.input_box]
        mov cx, 0x0303
	xor dx, dx
        mov si, [str_idx.delay_time]
        mov di, main_tmp.dialog_buf
        mov [di], dh
        call input_box
        jc .end

        mov si, di
        call atoi

        cmp ax, 255
        jbe .set_time
        mov al, 255
.set_time:
        mov [ADDR_SBMK_DELAY_TIME], al
        inc byte [main_tmp.change_occured]         ; some changes occured.
.end:
        ret

;=============================================================================
;main_boot_it ---- boot the selected record
;=============================================================================
main_boot_it:
	mov cl, [FOCUS_RECORD]
	call main_get_record_pointer
	mov al, cl
	push ax

        test byte [ADDR_SBMK_FLAGS], KNLFLAG_REMLAST
        jz .no_remlast

        mov [ADDR_SBMK_DEFAULT_BOOT], al
       
        call main_save_boot_manager
        jnc .cont_boot

        call main_show_disk_error
        jmp short .cont_boot

.no_remlast:
        call main_ask_save_changes              ; ask if save the changes.

.cont_boot:
        call main_hide_auto_hides
        pop ax
        jc .end
 
        call main_do_boot_record
.end:
        ret

;=============================================================================
;main_return_to_bios ---- give control back to BIOS
;=============================================================================
main_return_to_bios:
        call main_ask_save_changes              ; ask if save the changes.
        
        call reset_video_mode
        
	call uninstall_myint13h
%ifdef EMULATE_PROG
        mov ax, 0x4c00                          ; exit to dos
        int 0x21                                ;
%else
        int 0x18                                ; return to BIOS
%endif

.end:
        ret


;=============================================================================
; Duplicate the boot record
;=============================================================================
main_dup_record:
        mov ax, SIZE_OF_BOOTRECORD
        mov cx, MAX_RECORD_NUM
        mov di, ADDR_SBMK_BOOT_RECORDS

.search_empty_slot:
        test byte [di + struc_bootrecord.flags], DRVFLAG_DRIVEOK | INFOFLAG_ISSPECIAL
        jz .found_empty
        add di, ax
        loop .search_empty_slot
	ret

.found_empty:

        inc byte [main_tmp.change_occured]

        call main_get_focus_record_pointer
        mov cx, ax
        cld
        rep movsb
        call main_init_good_record_list
        ret



;=============================================================================
; move the boot record down 
;=============================================================================
main_move_record_down:
        movzx bx, byte [FOCUS_RECORD]
        mov al, [main_tmp.good_record_list + bx]
        inc bl
        mov ah, [main_tmp.good_record_list + bx]
        cmp bl, [GOOD_RECORD_NUMBER]
        jae .end

        cmp al, [ADDR_SBMK_DEFAULT_BOOT]
        jne .chknext
        mov [ADDR_SBMK_DEFAULT_BOOT], ah
        jmp short .swap_record
.chknext:
        cmp ah, [ADDR_SBMK_DEFAULT_BOOT]
        jne .swap_record
        mov [ADDR_SBMK_DEFAULT_BOOT], al

.swap_record:
        mov [FOCUS_RECORD], bl
        call main_swap_records
.end:
        ret

;=============================================================================
; move the boot record up
;=============================================================================
main_move_record_up:
        movzx bx, byte [FOCUS_RECORD]
        or bl, bl
        jz .end
        mov al, [main_tmp.good_record_list + bx]
        dec bl
        mov ah, [main_tmp.good_record_list + bx]

        cmp al, [ADDR_SBMK_DEFAULT_BOOT]
        jne .chknext
        mov [ADDR_SBMK_DEFAULT_BOOT], ah
        jmp short .swap_record
.chknext:
        cmp ah, [ADDR_SBMK_DEFAULT_BOOT]
        jne .swap_record
        mov [ADDR_SBMK_DEFAULT_BOOT], al

.swap_record:
  
        call main_swap_records
        mov [FOCUS_RECORD],bl
.end:
        ret

;=============================================================================
; swap current and previous boot record
;=============================================================================
main_swap_records:
	pusha
        dec byte [FOCUS_RECORD]
        call main_get_focus_record_pointer
	mov di, si
	inc byte [FOCUS_RECORD]
	call main_get_focus_record_pointer	; si -> current  di -> prev

        mov cx, SIZE_OF_BOOTRECORD

.loop_swap:
	mov al, [si]
	mov bl, [di]
	mov [si], bl
	mov [di], al
	inc si
	inc di
	loop .loop_swap
	popa

        ret

;=============================================================================
;main_toggle_swapid ---- toggle the swap driver id flag 
;=============================================================================
main_toggle_swapid:
	call main_get_focus_record_pointer
	or si, si
	jz .end
	test word [si + struc_bootrecord.flags], DRVFLAG_ISCDROM | INFOFLAG_ISSPECIAL
	jnz .end

	call main_auth_record_action
	jc .end

        xor word [si + struc_bootrecord.flags], INFOFLAG_SWAPDRVID
        call check_bootrecord
        inc byte [main_tmp.change_occured]
.end:
        ret

;=============================================================================
;main_toggle_schedule ---- toggle the schedule of the bootrecord
;=============================================================================
main_toggle_schedule:
        call main_get_focus_record_pointer
        test word [si + struc_bootrecord.flags], INFOFLAG_SCHEDULED
        jnz .clear_schedule

        push si
        call main_input_schedule_time
        pop si
        jc .end

        or dx, dx
        jnz .set_schedule
        not dx

.set_schedule:
        call set_record_schedule
        jmp short .end_ok

.clear_schedule:
        and word [si + struc_bootrecord.flags], ~INFOFLAG_SCHEDULED

.end_ok:
        inc byte [main_tmp.change_occured]
.end:
        ret

;=============================================================================
;main_input_schedule_time ---- input the schedule time
;input:
;      none
;output:
;      cf = 0 success, 
;           ax = begin time (in minutes)
;           bx = end time (in minutes)
;           dx = days info (bit 0 to bit 7 indicate Mon to Sun)
;      cf = 1 cancel
;=============================================================================
main_input_schedule_time:
        pusha

        xor ax, ax
	mov cx, 4
	cld
	mov di, main_tmp.schedule_begin
	rep stosw

        mov al, [color.input_box_msg]
        mov bx, [color.input_box_frame]
        mov cx, 0x1313
	xor dx, dx
        mov si, [str_idx.input_schedule]
        mov di, main_tmp.dialog_buf
	mov byte [di], 0 
        
        call input_box
        jc .exit

;convert begin time
        mov si, di
	call main_str_to_schtime
	jc .invalid_input
        mov [main_tmp.schedule_begin], ax

;convert end time
	lodsb
	cmp al,'-'
	jne .invalid_input

	call main_str_to_schtime
	jc .invalid_input
        mov [main_tmp.schedule_end], ax

;convert day info
        lodsb
        or al, al
        jz .end

        cmp al, ';'
        jne .invalid_input

        mov cx, 7
        xor dx, dx

.loop_get_days:
        lodsb
        or al, al
        jz .end_get_days
        sub al, '0'
        cmp al, 7
        jae .invalid_input
        mov bx, 1
        push cx
        mov cl, al
        shl bx, cl
        pop cx
        or dx, bx
        loop .loop_get_days

.end_get_days:
        mov [main_tmp.schedule_day], dx

.end:
	clc
	jmp short .exit

.invalid_input:
        mov si, [str_idx.invalid_schedule]
        call error_box
        stc
.exit:
        popa
        mov ax, [main_tmp.schedule_begin]
        mov bx, [main_tmp.schedule_end]
        mov dx, [main_tmp.schedule_day]
        ret


;=============================================================================
;input ds:si -> string
;output cf =0 ok, ax = time in minutes
;       cf =1 fail
;=============================================================================
main_str_to_schtime:
	xor bx, bx
	xor cx, cx

        call atoi
        cmp al, 24                          ; hh must be less than 24
        ja .fail

        mov bl, al
	lodsb
	cmp al, ':'
	jne .fail

        call atoi
        cmp al, 60                          ; mm must be less than 60
        jae .fail
        mov cl, al

        mov al, 60
        mul bl
        add ax, cx
        cmp ax, 24*60                       ; begin time must be no more than
        ja .fail                            ; 24*60 minutes
	clc
	ret
.fail:
	stc
	ret

;=============================================================================
;main_toggle_keystrokes ---- toggle the keystrokes switch of the bootrecord
;=============================================================================
main_toggle_keystrokes:

        call main_get_focus_record_pointer
        test word [si + struc_bootrecord.flags], INFOFLAG_HAVEKEYS
        jz .input_keys

        and word [si + struc_bootrecord.flags], ~INFOFLAG_HAVEKEYS
        jmp short .end_ok

.input_keys:
        lea di, [si + struc_bootrecord.keystrokes]
        mov cl, MAX_KEYSTROKES
        push si
        call main_input_keystrokes
        pop si
        or ch, ch
        jz .end

        or word [si + struc_bootrecord.flags], INFOFLAG_HAVEKEYS

.end_ok:
        inc byte [main_tmp.change_occured]
.end:
        ret

;=============================================================================
; main_ikbox_event_handle ---- event handle for Input keystroke box
;=============================================================================
main_ikbox_event_handle:
        cmp ah, EVTCODE_COMMAND
        jb .normal_key

        cmp ax, EVENT_SCROLL_OFF
        jne .end

        call window_close
        clc
        ret

.normal_key:
        cld
        mov di, [main_tmp.keystroke_ptr]
        movzx cx, [main_tmp.keystroke_num]
        cmp cl, [main_tmp.keystroke_max]
        jae .end

        shl cx, 1
        add di, cx
        stosw

        inc byte [main_tmp.keystroke_num]
        call main_ikbox_prepare
        call window_draw_body
.end:
        clc
        ret

;=============================================================================
;main_ikbox_prepare
;input:
;       ds:si -> the message_box struc
;=============================================================================
main_ikbox_prepare:
        mov word [si + struc_window.event_handle],main_ikbox_event_handle
	xor ax, ax

        push si
        mov di, [si + struc_message_box.message]
        mov si, [str_idx.input_keystrokes]
        push di

        call strcpy
        push di
        movzx cx, byte [main_tmp.keystroke_num]

        shl cx,1
        mov di, [main_tmp.keystroke_ptr]
        add di, cx
	or cx, cx
	jz .first_prepare
	sub di, 2
.first_prepare:
	mov ax, [di]

        pop di
        push cx
        
        mov cl, 4
        call htoa                          ; fill in the key code string
        add di, 4

        mov si, [str_idx.key_count]
        call strcpy

        pop cx
        shr cx, 1
        movzx ax, cl
        mov cl, 2
        call itoa                          ; fill in the key cound string

        pop si

	call count_lines

	add cl, [size.box_width]
	add ch, [size.box_height]

        pop si
	mov [si + struc_window.win_size], cx
	call window_center_window
        ret


;=============================================================================
;main_input_keystrokes ---- input a set of key strokes
;input:
;      cl = max key strokes number
;      es:di -> the buffer
;output:
;      es:di -> the buffer filled by key strokes
;      ch = number of key strokes that inputed
;=============================================================================
main_input_keystrokes:
        push di

        xor ax, ax
        mov [main_tmp.keystroke_ptr], di
        mov [main_tmp.keystroke_max], cl
        mov [main_tmp.keystroke_num], al
        mov [di], ax

        mov al, [color.input_box_msg]
        mov bx, [color.input_box]
        mov dx, str_idx.input
        mov si, main_tmp.dialog_buf
        mov di, main_tmp.ikbox

        mov [si], ah
        call msgbox_prepare
        mov si, di
        call main_ikbox_prepare

        call turnon_scrolllock
        call window_run
        call turnoff_scrolllock

        mov ch, [main_tmp.keystroke_num]
        pop di
        ret

;=============================================================================
;main_show_record_info ---- show the information of the boot record
;=============================================================================
main_show_record_info:
        call main_get_focus_record_pointer
        mov di, main_tmp.dialog_buf

        call get_record_schedule
        push dx
        push bx
        push ax

        push dword [si + struc_bootrecord.password]

        mov bx, [si + struc_bootrecord.flags]
        mov ax, [si + struc_bootrecord.drive_id]

        mov dx, si
        add si, struc_bootrecord.name
        push si                               ; save record name pointer
        push dx                               ; save record pointer
        push ax                               ; save drive_id and part_id

;write drive id
        mov si, [str_idx.drive_id]
        call strcpy

	test bx, INFOFLAG_ISSPECIAL
	jz .drvid_ok

	mov al, '-'
	stosb
	stosb
	stosb
	jmp short .write_partid

.drvid_ok:
	mov dl, al
	call get_drvid_str

.write_partid:
;write part id
        mov si, [str_idx.part_id]
        call strcpy

        pop ax                          ; ax = drive id, partition id
	test bx, INFOFLAG_ISSPECIAL
	jz .partid_ok
	mov al, '-'
	stosb
	stosb
	jmp short .write_rectype

.partid_ok:
        movzx ax, ah
        mov cx, 2
        call itoa
        add di, cx

.write_rectype:
;write record type
        mov si, [str_idx.record_type]
        call strcpy

        mov si, di
        call strlen

        mov ax, cx
        pop si                          ; si -> record pointer
        call get_record_typestr
        mov si, di
        call strlen
        sub cx, ax
        add di, cx

;write record name 
        mov si, [str_idx.record_name]
        call strcpy
        pop si
        call strcpy

;write flags
	mov cx, 7
	mov dx, bx
	xor bx, bx
.loop_copy_flags:
	mov si, [str_idx.auto_active + bx]
	mov ax, [.flag_val + bx]
	call .copy_flag_stat
	inc bx
	inc bx
	loop .loop_copy_flags

;write password flag
        mov si, [str_idx.password]
        call strcpy
        pop ecx
        or ecx, ecx
        jz .no_pswd
        mov si, [str_idx.yes]
        jmp short .pswd
.no_pswd:
        mov si, [str_idx.no]
.pswd:
        call strcpy

;write schedule time
        mov si, [str_idx.schedule]
        call strcpy
        mov cx, dx

        pop ax
        pop bx
        pop dx

        test cx, INFOFLAG_SCHEDULED
        jz .no_sched
        call schedule_to_str
        jmp short .show_info

.no_sched:
        mov si, [str_idx.no]
        call strcpy

.show_info:
        mov si, main_tmp.dialog_buf
        call info_box
.end:
        ret

; si -> flag string
; ax = flag
.copy_flag_stat:
	call strcpy
        test dx, ax
        jz .no_this_flag
        mov si, [str_idx.yes] 
        jmp short .copy_flag
.no_this_flag:
        mov si, [str_idx.no]
.copy_flag:
        call strcpy
	ret

.flag_val	dw INFOFLAG_AUTOACTIVE, INFOFLAG_ACTIVE, INFOFLAG_AUTOHIDE, INFOFLAG_HIDDEN, INFOFLAG_SWAPDRVID
		dw INFOFLAG_LOGICAL, INFOFLAG_HAVEKEYS

       
;=============================================================================
;main_power_off ---- turn of the power
;=============================================================================
main_power_off:
        jmp power_off


;=============================================================================
;main_change_bootmenu_style ---- change the boot menu's draw style
;=============================================================================
main_change_bootmenu_style:
	mov al, [ADDR_SBMK_BOOTMENU_STYLE]
	inc al
	cmp al, 4
	jb .ok
	xor al, al

.ok:
	mov [ADDR_SBMK_BOOTMENU_STYLE], al
	call main_init_boot_menu

        inc byte [main_tmp.change_occured]
        ret

;=============================================================================
;main_toggle_rem_last ---- toggle the remember last switch.
;=============================================================================
main_toggle_rem_last:
        xor byte [ADDR_SBMK_FLAGS], KNLFLAG_REMLAST
        inc byte [main_tmp.change_occured]
        ret


;=============================================================================
;main_boot_prev_in_menu ---- boot previous MBR in command menu
;=============================================================================
main_boot_prev_in_menu:
	call check_prev_mbr
	jc .end

        call main_confirm_root_passwd
        jc .end

	call main_boot_prev_mbr
.end:
	ret


;=============================================================================
; main_toggle_int13ext
;=============================================================================
main_toggle_int13ext:
        mov al, [ADDR_SBMK_FLAGS]
        xor al, KNLFLAG_NOINT13EXT
        mov [ADDR_SBMK_FLAGS], al

        test al, KNLFLAG_NOINT13EXT
        jnz .no_int13ext
        mov byte [use_int13_ext], 1
        jmp short .endok

.no_int13ext:
        mov byte [use_int13_ext], 0
.endok:
        inc byte [main_tmp.change_occured]
        ret

;=============================================================================
; main_set_cdrom_ioports
;=============================================================================

main_set_cdrom_ioports:
%ifndef DISABLE_CDBOOT
	test byte [ADDR_SBMK_FLAGS], KNLFLAG_NOCDROM
	jnz .end

        call main_confirm_root_passwd
        jc .end

        lea di, [main_tmp.dialog_buf]
	push di
	mov byte [di], 0 
	mov ax, [ADDR_SBMK_CDROM_IOPORTS]
	or ax, ax
	jz .no_ports
	mov cl, 4
	call htoa
	add di, 4
	mov al, ','
	stosb
	mov ax, [ADDR_SBMK_CDROM_IOPORTS+2]
	call htoa
.no_ports:
	pop di

        movzx ax, [color.input_box_msg]
        mov bx, [color.input_box]
        mov cx, 0x0909
        xor dx, dx
        mov si, [str_idx.io_port]
	
        call input_box
        jc .end

        mov si, di
	call atoh
	cmp byte [si], ','
	jne .invalid
	mov bx, ax
	inc si
	call atoh
	cmp byte [si], 0
	jne .invalid

	mov cx, ax
	mov [ADDR_SBMK_CDROM_IOPORTS], bx
	mov [ADDR_SBMK_CDROM_IOPORTS+2], cx

        inc byte [main_tmp.change_occured]               ; some changes occured.
	call set_io_ports
	jmp short .end

.invalid:
	mov si, [str_idx.invalid_ioports]
	call error_box
	jmp .end
.end:
%endif
        ret

;=============================================================================
;main_set_y2k_year
;=============================================================================

main_set_y2k_year:
%ifdef Y2K_BUGFIX
        lea di, [main_tmp.dialog_buf]
	mov byte [di], 0 
	mov cl,4
	mov ax,[ADDR_SBMK_Y2K_LAST_YEAR]
	or ax,ax
	jz .nofix
	call bcd_to_str
.nofix:
        movzx ax, [color.input_box_msg]
        mov bx, [color.input_box]
        mov si, [str_idx.year]
        mov ch, cl
	xor dx, dx

        call input_box
        jc .end

	xor bx,bx
	or ch,ch
	jz .set

        mov si,di
.loop:
	shl bx,cl
	lodsb
	sub al,'0'
	or bl,al
	dec ch
	jnz .loop

	mov ah,4
	int 0x1a
	jc .end

	mov cx,bx
	mov ah,5
	int 0x1a
.set:
	mov [ADDR_SBMK_Y2K_LAST_YEAR],bx
        inc byte [main_tmp.change_occured]               ; some changes occured.
.end:
%endif
        ret

