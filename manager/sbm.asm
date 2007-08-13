; 
; 
; Smart Boot Manager
; 
; 
;  developed by
;    
;       Peter Kleissner
;       Vienna Computer Products
;       Suzhe
;       Christopher Li
;       Lonius
;       Risko Gergely
;       Victor O`Muerte
;       Dirk Knop
;       Lenart Janos
;       Frédéric Bonnaud
;       brz
;       Manuel Clos
;       Benoit Mortier
;       Bill Hults
;       Andr Maldonado
;       Santiago Garcia Mantinan
;       
;       Thank you all.
;       

; asmsyntax=nasm
;
; main.asm
;
; Main programs for Smart Boot Manager
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
; Copyright (C) 2001, Suzhe. See file COPYING for details.
;

; optional Assembly:
; 
;   EMULATE_PROG
;       if defined, creates DOS executable Test-vesion
;   
;   THEME_ZH, THEME_DE, THEME_HU, THEME_RU, THEME_CZ, THEME_ES, THEME_FR, THEME_PT, else US
;       language themes
;   
;   DISABLE_CDBOOT
;       disables CD Boot and initialization of it
;   
;   Y2K_BUGFIX
;       year 2000 fix [removed since Revision 5, we write the year 2007]


; compile 16 bit code (Real Mode) and beware backward compatibility down to 386er
[bits 16]
CPU 386

%include "macros.h"
%include "ui.h"
%include "hd_io.h"
%include "knl.h"
%include "sbm.h"
%include "main.h"
%include "evtcode.h"

%define GOOD_RECORD_NUMBER    (main_windows_data.boot_menu + struc_menu_box.items_num)
%define FOCUS_RECORD          (main_windows_data.boot_menu + struc_menu_box.focus_item)
%define FIRST_VISIBLE_RECORD  (main_windows_data.boot_menu + struc_menu_box.first_visible_item)
%define BOOT_MENU_AREA_HEIGHT (main_windows_data.boot_menu + struc_menu_box.menu_area_size + 1) 

; some data definitions

%define disk_address_packet     7E00h
  %define dap                   disk_address_packet

  %define dap_Size      dap+00h
  %define dap_Reserved  dap+01h
  %define dap_Count     dap+02h
  %define dap_Buffer    dap+04h				; Segment:Offset value
  %define dap_LBA_low   dap+08h
  %define dap_LBA_high  dap+0Ch

%define Boot_stuff              7E10h
  %define Boot_Drive            Boot_stuff+0
  %define Boot_Drive_Sector     Boot_stuff+4		; ToasterOS Standalone only
  %define Boot_Drive_Type       Boot_stuff+8		; ToasterOS Standalone only
  %define Boot_Drive_Buffer     Boot_stuff+12		; ToasterOS Standalone only
  %define Boot_File_Handle      Boot_stuff+51		; ToasterOS Standalone only
  %define Temp_RM               Boot_stuff+69		; ToasterOS Standalone Bootloader only
  %define Boot_Drive_Pointer    Boot_stuff+73		; ToasterOS Standalone only
  %define Debug_RM              Boot_stuff+77		; triple-byte
  %define Boot_Last_Boot_drive  Boot_stuff+78


%ifdef EMULATE_PROG
	org 0x100
%else
	org 0
%endif

	section .text


%ifndef EMULATE_PROG

  ; include the load code for the low level Master Boot Record
  %include  'Bootloader.asm'
  
%else

  ; include DOS Source Code
  
	; set Data Segments to CS / 0000h
	push cs
	pop ax
	mov ds,ax
	mov es,ax
	
	xor ax,ax
	mov fs,ax
	mov gs,ax
	
	jmp Smart_Boot_Manager_Kernel

%endif



;=============================================================================
;  data for the Smart Boot Manager
;=============================================================================

  ADDR_SBMK_BLOCK_MAP              resb      SIZE_OF_STRUC_BLOCK_MAP * 5
  ADDR_SBMK_FLAGS                  db        KNLFLAG_FIRSTSCAN
  ADDR_SBMK_DELAY_TIME             db        30
  ADDR_SBMK_DIRECT_BOOT            db        0FFh
  ADDR_SBMK_DEFAULT_BOOT           db        0FFh
  ADDR_SBMK_ROOT_PASSWORD          dd        0
  ADDR_SBMK_BOOTMENU_STYLE         db        0, 0
  ADDR_SBMK_CDROM_IOPORTS          dw        0, 0
  ADDR_SBMK_BOOT_MENU_POS          dw        0x060E
  ADDR_SBMK_MAIN_MENU_POS          dw        0x0101
  ADDR_SBMK_RECORD_MENU_POS        dw        0x0202
  ADDR_SBMK_SYS_MENU_POS           dw        0x0303


; some huge data

  ADDR_SBMK_BOOT_RECORDS           resb      MAX_RECORD_NUM * SIZE_OF_BOOTRECORD





;=============================================================================
;  Smart Boot Manager Kernel
;=============================================================================

Smart_Boot_Manager_Kernel:


; install own interrupt 13h Handler [in-removing]
mov bl,1
call install_myint13h

;Initializing the CD-ROMs.. [in reviewing]
%ifndef DISABLE_CDBOOT
	test byte [ADDR_SBMK_FLAGS], KNLFLAG_NOCDROM
	jnz .not_set_cdrom_ports
	mov bx, [ADDR_SBMK_CDROM_IOPORTS]
	mov cx, [ADDR_SBMK_CDROM_IOPORTS+2]
	call set_io_ports
.not_set_cdrom_ports:
%endif


%ifndef EMULATE_PROG

; Set "No Int 13h Extension" flag
	xor al, al
	test byte [ADDR_SBMK_FLAGS], KNLFLAG_NOINT13EXT
	jnz .no_int13_ext
        inc al
.no_int13_ext:
	mov [use_int13_ext], al

; Do some initialization
	call main_init_theme		; initialize the theme
	call main_init_video		; initialize the video mode.
        call window_initialize

; Check if needs scan boot records.
	test byte [ADDR_SBMK_FLAGS], KNLFLAG_FIRSTSCAN
	jz .no_first_scan

	call main_init_boot_records	; if it's the first time
					; to run this program,
					; call the init_boot_records.
	call main_init_good_record_list

	and byte [ADDR_SBMK_FLAGS], ~ KNLFLAG_FIRSTSCAN
	jmp short .show_menu

.no_first_scan:

; go ahead!

; Initialize the good record list
	call main_init_good_record_list

; Initialize the keyboard shift var, and test if Ctrl is pressed down.
	mov ah, 0x02			; test the keyboard status,
	call bioskey			; if ctrl pressed then show
        mov [utils_tmp.kbd_last_shift], al ; Initialize the kbd stat reg.
	test al, kbCtrlMask		; menu directly,
	jnz .show_menu			;

; Check direct boot, and schedule boot
	mov al, [ADDR_SBMK_DIRECT_BOOT]	; check if need boot directly.
	cmp al, MAX_RECORD_NUM		;
	jb .go_direct_boot

	call main_do_schedule		; implement the schedule table.

	cmp byte [ADDR_SBMK_DELAY_TIME], 0
	jnz .show_menu			; delay_time = 0, boot the
					; default record directly.
	mov al, [ADDR_SBMK_DEFAULT_BOOT]
	cmp al, MAX_RECORD_NUM
	jb .go_def_boot
	jmp short .show_menu
        
.go_direct_boot:
	mov byte [ADDR_SBMK_DIRECT_BOOT], 0xff ; clear the direct boot sig.
	call main_save_boot_manager
	jc .disk_error

	mov [ADDR_SBMK_DEFAULT_BOOT], al

.go_def_boot:
	call main_boot_default
	jmp short .show_menu

.disk_error:
	call main_show_disk_error

%else
 
 ; DOS Emulation Source Code

    call main_init_video
    call main_init_boot_records
    call main_init_good_record_list
    call main_do_schedule

%endif


.show_menu:
	call main_init_all_menus	; initialize the command menus

;Initialize  time count var
	mov al, [ADDR_SBMK_DELAY_TIME]
	cmp al, 255
	jae .not_count_time			; if delay_time = 255
	mov [main_tmp.time_count], al		; then do not count time.
	xor al, al

.not_count_time:
	mov [main_tmp.key_pressed], al

; Set focus bar to the default record
	mov bl, [ADDR_SBMK_DEFAULT_BOOT]
	lea si, [main_tmp.good_record_list]
	mov cl, [GOOD_RECORD_NUMBER]
	xor ch, ch
	xor bh, bh
        
.loop_search_def:
	lodsb
	cmp al, bl
	je .found_def
	inc bh
	loop .loop_search_def
	jmp short .go_ahead

.found_def:
	mov [FOCUS_RECORD], bh
	cmp bh, [BOOT_MENU_AREA_HEIGHT]
	jb .go_ahead
	inc bh
	sub bh, [BOOT_MENU_AREA_HEIGHT]
	mov [FIRST_VISIBLE_RECORD], bh

; Run the UI system
.go_ahead:
        mov bx, main_windows_data.root_window
        mov si, main_windows_data.boot_menu
        call window_execute

.halt:
        jmp short .halt

;=============================================================================
;  include area (mostly commands)
;=============================================================================

%include "main-cmds.asm"
%include "main-utils.asm"
%include "ui.asm"
%include "utils.asm"
%include "knl.asm"
%include "hd_io.asm"
%include "myint13h.asm"

;=============================================================================
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  DATA AREA  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;=============================================================================

%define ROOT_WINDOW_ACTION_NUMBER (main_action_table.end_of_root_window - main_action_table.root_window) / SIZE_OF_STRUC_ACTION
%define BOOT_MENU_ACTION_NUMBER (main_action_table.end_of_boot_menu - main_action_table.boot_menu) / SIZE_OF_STRUC_ACTION
%define MAIN_MENU_ACTION_NUMBER (main_action_table.end_of_main_menu - main_action_table.main_menu) / SIZE_OF_STRUC_ACTION
%define RECORD_MENU_ACTION_NUMBER (main_action_table.end_of_record_menu - main_action_table.record_menu) / SIZE_OF_STRUC_ACTION
%define SYS_MENU_ACTION_NUMBER (main_action_table.end_of_sys_menu - main_action_table.sys_menu) / SIZE_OF_STRUC_ACTION

%define MAIN_MENU_ITEMS_NUMBER   11
%define RECORD_MENU_ITEMS_NUMBER 16
%define SYS_MENU_ITEMS_NUMBER    18
;=============================================================================
;  Windows data
;=============================================================================
main_windows_data:
.root_window    istruc struc_window
		at struc_window.flags,                  dw WINFLAG_OPEN | WINFLAG_NO_FOCUS
		at struc_window.title,                  dw 0
		at struc_window.win_attr,               dw 0
		at struc_window.win_pos,                dw 0
		at struc_window.win_size,               dw 0
		at struc_window.parent_win,             dw 0
		at struc_window.next_win,               dw 0
		at struc_window.previous_win,           dw 0
		at struc_window.act_num,                dw ROOT_WINDOW_ACTION_NUMBER
		at struc_window.act_table,              dw main_action_table.root_window
		at struc_window.default_event_handle,   dw window_default_event_handle
		at struc_window.event_handle,           dw window_event_handle
		at struc_window.draw_body_proc,         dw root_window_draw_body_proc
		iend

.boot_menu      istruc struc_menu_box
		at struc_window.flags,                  dw WINFLAG_FRAMED | MENUFLAG_SCROLLBAR | MENUFLAG_SINK_UPPER | MENUFLAG_SINK_WIDTH | MENUFLAG_SINK_BOTTOM
		at struc_window.title,                  dw str_idx.boot_menu_title
		at struc_window.win_attr,               dw 0x3FF1
		at struc_window.win_pos,                dw 0
		at struc_window.win_size,               dw 0
		at struc_window.parent_win,             dw .root_window
		at struc_window.next_win,               dw 0
		at struc_window.previous_win,           dw 0
		at struc_window.act_num,                dw BOOT_MENU_ACTION_NUMBER
		at struc_window.act_table,              dw main_action_table.boot_menu
		at struc_window.default_event_handle,   dw menubox_default_event_handle
		at struc_window.event_handle,           dw window_event_handle
		at struc_window.draw_body_proc,         dw menubox_draw_body_proc
		at struc_menu_box.menu_header,          dw str_idx.boot_menu_header
		at struc_menu_box.menu_header_attr,     db 0x1F
		at struc_menu_box.menu_norm_attr,       dw 0x7C70
		at struc_menu_box.menu_focus_attr,      dw 0x0C0F
                at struc_menu_box.menu_area_pos,        dw 0
                at struc_menu_box.menu_area_size,       dw 0
		at struc_menu_box.scrollbar_attr,       db 0x3F
		at struc_menu_box.items_num,            db 0
		at struc_menu_box.focus_item,           db 0
		at struc_menu_box.first_visible_item,   db 0
		at struc_menu_box.item_str_proc,        dw boot_menu_item_str_proc
		iend

.main_menu      istruc struc_menu_box
		at struc_window.flags,                  dw WINFLAG_FRAMED
		at struc_window.title,                  dw str_idx.main_menu_title
		at struc_window.win_attr,               dw 0x30F1
		at struc_window.win_pos,                dw 0x0101
		at struc_window.win_size,               db 0, MAIN_MENU_ITEMS_NUMBER+2
		at struc_window.parent_win,             dw .boot_menu
		at struc_window.next_win,               dw 0
		at struc_window.previous_win,           dw 0
		at struc_window.act_num,                dw MAIN_MENU_ACTION_NUMBER
		at struc_window.act_table,              dw main_action_table.main_menu
		at struc_window.default_event_handle,   dw menubox_default_event_handle
		at struc_window.event_handle,           dw window_event_handle
		at struc_window.draw_body_proc,	        dw menubox_draw_body_proc
		at struc_menu_box.menu_header,          dw 0
		at struc_menu_box.menu_header_attr,     db 0x3F
		at struc_menu_box.menu_norm_attr,       dw 0x3C30
		at struc_menu_box.menu_focus_attr,      dw 0x0C07
                at struc_menu_box.menu_area_pos,        dw 0
                at struc_menu_box.menu_area_size,       dw 0
		at struc_menu_box.scrollbar_attr,       db 0x3F
		at struc_menu_box.items_num,            db MAIN_MENU_ITEMS_NUMBER
		at struc_menu_box.focus_item,           db 0
		at struc_menu_box.first_visible_item,   db 0
		at struc_menu_box.item_str_proc,        dw main_menu_item_str_proc
		iend

.record_menu    istruc struc_menu_box
		at struc_window.flags,                  dw WINFLAG_FRAMED
		at struc_window.title,                  dw str_idx.record_menu_title
		at struc_window.win_attr,               dw 0x30F1
		at struc_window.win_pos,                dw 0x0202
		at struc_window.win_size,               db 0, RECORD_MENU_ITEMS_NUMBER+2
		at struc_window.parent_win,             dw .boot_menu
		at struc_window.next_win,               dw 0
		at struc_window.previous_win,           dw 0
		at struc_window.act_num,                dw RECORD_MENU_ACTION_NUMBER
		at struc_window.act_table,              dw main_action_table.record_menu
		at struc_window.default_event_handle,   dw menubox_default_event_handle
		at struc_window.event_handle,           dw window_event_handle
		at struc_window.draw_body_proc,	        dw menubox_draw_body_proc
		at struc_menu_box.menu_header,          dw 0
		at struc_menu_box.menu_header_attr,     db 0x3F
		at struc_menu_box.menu_norm_attr,       dw 0x3C30
		at struc_menu_box.menu_focus_attr,      dw 0x0C07
                at struc_menu_box.menu_area_pos,        dw 0
                at struc_menu_box.menu_area_size,       dw 0
		at struc_menu_box.scrollbar_attr,       db 0x3F
		at struc_menu_box.items_num,            db RECORD_MENU_ITEMS_NUMBER
		at struc_menu_box.focus_item,           db 0
		at struc_menu_box.first_visible_item,   db 0
		at struc_menu_box.item_str_proc,        dw record_menu_item_str_proc
		iend

.sys_menu       istruc struc_menu_box
		at struc_window.flags,                  dw WINFLAG_FRAMED
		at struc_window.title,                  dw str_idx.sys_menu_title
		at struc_window.win_attr,               dw 0x30F1
		at struc_window.win_pos,                dw 0x0303
		at struc_window.win_size,               db 0, SYS_MENU_ITEMS_NUMBER+2
		at struc_window.parent_win,             dw .boot_menu
		at struc_window.next_win,               dw 0
		at struc_window.previous_win,           dw 0
		at struc_window.act_num,                dw SYS_MENU_ACTION_NUMBER
		at struc_window.act_table,              dw main_action_table.sys_menu
		at struc_window.default_event_handle,   dw menubox_default_event_handle
		at struc_window.event_handle,           dw window_event_handle
		at struc_window.draw_body_proc,         dw menubox_draw_body_proc
		at struc_menu_box.menu_header,          dw 0
		at struc_menu_box.menu_header_attr,     db 0x3F
		at struc_menu_box.menu_norm_attr,       dw 0x3C30
		at struc_menu_box.menu_focus_attr,      dw 0x0C07
                at struc_menu_box.menu_area_pos,        dw 0
                at struc_menu_box.menu_area_size,       dw 0
		at struc_menu_box.scrollbar_attr,       db 0x3F
		at struc_menu_box.items_num,            db SYS_MENU_ITEMS_NUMBER
		at struc_menu_box.focus_item,           db 0
		at struc_menu_box.first_visible_item,   db 0
		at struc_menu_box.item_str_proc,        dw sys_menu_item_str_proc
		iend

.end_of_windows_data:

;=============================================================================
;  Action table
;=============================================================================
main_action_table:

.root_window:

.main_menu:
        db  ACTFLAG_REDRAW_SCR
        dw  kbF1
        dw  main_show_help

        db  ACTFLAG_REDRAW_SCR
        dw  kbCtrlF1
        dw  main_show_about

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_SECURITY
        dw  kbF2
        dw  main_save_changes

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_AUTH_RECORD | ACTFLAG_CHK_RECNUM
        dw  0
        dw  main_boot_it

        db  ACTFLAG_REDRAW_WIN
        dw  0
        dw  main_boot_prev_in_menu

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_SCR
        dw  kbAltR
        dw  main_show_record_menu

        db  ACTFLAG_REDRAW_SCR
        dw  kbAltS
        dw  main_show_sys_menu

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_AUTH_ROOT
        dw  kbCtrlQ
        dw  main_return_to_bios

        db  0
        dw  kbCtrlF12
        dw  main_power_off

.end_of_main_menu

.record_menu:
        db  ACTFLAG_REDRAW_WIN
        dw  kbSlash
        dw  main_show_record_info

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF3
        dw  main_change_name

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF9
        dw  main_change_record_password

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlS
        dw  main_toggle_schedule

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlK
        dw  main_toggle_keystrokes

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_SCR 
        dw  kbF4
        dw  main_mark_active

        db  ACTFLAG_REDRAW_SCR
        dw  kbF5
        dw  main_toggle_hidden

        db  ACTFLAG_REDRAW_SCR
        dw  kbF6
        dw  main_toggle_auto_active

        db  ACTFLAG_REDRAW_SCR
        dw  kbF7
        dw  main_toggle_auto_hide

        db  ACTFLAG_REDRAW_SCR
        dw  kbCtrlX
        dw  main_toggle_swapid

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlD
        dw  main_delete_record

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlP
        dw  main_dup_record

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY
        dw  kbCtrlU
        dw  main_move_record_up

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY
        dw  kbCtrlN
        dw  main_move_record_down


.end_of_record_menu

.sys_menu:
        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbF10
        dw  main_change_root_password

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT | ACTFLAG_AUTH_SECURITY
        dw  kbCtrlF10
        dw  main_login_as_root

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_SECURITY
        dw  kbAltF10
        dw  main_change_security_mode

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbF8
        dw  main_set_default_record

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbShiftF8
        dw  main_unset_default_record

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbCtrlT
        dw  main_set_delay_time

        db  ACTFLAG_REDRAW_SCR
        dw  kbCtrlF
        dw  main_change_bootmenu_style

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbCtrlL
        dw  main_toggle_rem_last

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  0
        dw  main_toggle_int13ext

        db  0
        dw  0
        dw  0

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbCtrlI
        dw  main_rescan_all_records

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        dw  kbCtrlH
        dw  main_rescan_all_partitions

        db  ACTFLAG_REDRAW_SCR
        dw  0
        dw  main_set_cdrom_ioports

        ;db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        ;dw  0
        ;dw  main_set_y2k_year

        db  0
        dw  0
        dw  0

        ;db  ACTFLAG_REDRAW_SCR
        ;dw  0
        ;dw  main_install_sbm

        ;db  ACTFLAG_REDRAW_SCR | ACTFLAG_AUTH_ROOT
        ;dw  0
        ;dw  main_uninstall_sbm

.end_of_sys_menu

        db  ACTFLAG_REDRAW_SCR
        dw  EVENT_REDRAW_ROOT
        dw  0

        db  ACTFLAG_REDRAW_SCR | ACTFLAG_CHK_RECNUM
        dw  EVENT_BOOT_DEFAULT
        dw  main_boot_default

.end_of_root_window
        
.boot_menu:
        db  ACTFLAG_REDRAW_SCR
        dw  kbEnhAltUp
        dw  menubox_focus_up

        db  ACTFLAG_REDRAW_SCR
        dw  kbEnhAltDown
        dw  menubox_focus_down

        db  ACTFLAG_REDRAW_WIN
        dw  kbQuestion
        dw  main_show_record_info

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF3
        dw  main_change_name

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF9
        dw  main_change_record_password

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlS
        dw  main_toggle_schedule

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlK
        dw  main_toggle_keystrokes

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF4
        dw  main_mark_active

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF5
        dw  main_toggle_hidden

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF6
        dw  main_toggle_auto_active

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbF7
        dw  main_toggle_auto_hide

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlX
        dw  main_toggle_swapid

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlD
        dw  main_delete_record

        db  ACTFLAG_REDRAW_BODY | ACTFLAG_CHK_RECNUM | ACTFLAG_AUTH_SECURITY | ACTFLAG_AUTH_RECORD
        dw  kbCtrlP
        dw  main_dup_record

        db  ACTFLAG_REDRAW_BODY
        dw  kbCtrlU
        dw  main_move_record_up

        db  ACTFLAG_REDRAW_BODY
        dw  kbCtrlN
        dw  main_move_record_down

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_AUTH_RECORD | ACTFLAG_CHK_RECNUM
        dw  kbEnter
        dw  main_boot_it

        db  ACTFLAG_REDRAW_WIN | ACTFLAG_CHK_RECNUM
        dw  kbEsc
        dw  main_boot_default

        db  ACTFLAG_REDRAW_SCR
        dw  EVENT_ALT_RELEASE
        dw  main_show_main_menu
.end_of_boot_menu




;=============================================================================
;  include the language theme, specified as macro definition
;=============================================================================
theme_start:

%ifdef THEME_ZH
 %include "themes/theme-zh.asm"
%elifdef THEME_DE
 %include "themes/theme-de.asm"
%elifdef THEME_HU
 %include "themes/theme-hu.asm"
%elifdef THEME_RU
 %include "themes/theme-ru.asm"
%elifdef THEME_CZ
 %include "themes/theme-cz.asm"
%elifdef THEME_ES
 %include "themes/theme-es.asm"
%elifdef THEME_FR
 %include "themes/theme-fr.asm"
%elifdef THEME_PT
 %include "themes/theme-pt.asm"
%else
 %include "themes/theme-us.asm"
%endif




;=============================================================================
;  Temporary Data Area (pre-initialized data)
;=============================================================================
 
%include "tempdata.asm"





%ifndef EMULATE_PROG

 ; make the binary (Master Boot Record) 63 sectors long (don't care about the DOS emulation exec size)
 
  times 63*512-($-$$) db 0

%endif

