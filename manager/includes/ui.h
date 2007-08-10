;
; ui.h
;
; header file for ui.asm
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

; following flags is used in struc_window.flags

%define WINFLAG_OPEN		0x01  ; set this flag when open the window
%define WINFLAG_MODAL		0x02  ; Modal window
%define WINFLAG_FRAMED		0x04  ; the window has frame.
%define WINFLAG_NO_FOCUS	0x08  ; Cannot be focused.

%define MENUFLAG_SCROLLBAR	0x10  ; the menu has scroll bar
%define MENUFLAG_SINK_WIDTH	0x20  ; reduce the width of menu area by two char
%define MENUFLAG_SINK_UPPER	0x40  ; reduce the upper of menu area by one char
%define MENUFLAG_SINK_BOTTOM	0x80  ; ..

%define WINFLAG_HI_RUNNING	0x01  ; unsed in hi-byte of struc_window.flags

; following flags is used in struc_action.flags

%define ACTFLAG_CLOSE_WIN	0x01  ; close the window after doing the action
%define ACTFLAG_REDRAW_BODY	0x02  ; redraw window body after doing it
%define ACTFLAG_REDRAW_WIN	0x04  ; redraw entire window after doing it
%define ACTFLAG_REDRAW_SCR	0x08  ; redraw entire screen after doint it

%define ACTFLAG_CHK_RECNUM	0x10  ; check good record number before do it
%define ACTFLAG_AUTH_ROOT	0x20  ; confirm root password before do it
%define ACTFLAG_AUTH_RECORD	0x40  ; confirm record password before do it
%define ACTFLAG_AUTH_SECURITY	0x80  ; confirm password according to security
                                      ; level
%define ACTFLAG_AUTHS		0xF0

%define SIZE_OF_STRUC_WINDOW		struc_window.end_of_struc
%define SIZE_OF_STRUC_MENU_BOX		struc_menu_box.end_of_struc
%define SIZE_OF_STRUC_ACTION		struc_action.end_of_struc
%define SIZE_OF_STRUC_MESSAGE_BOX	struc_message_box.end_of_struc
%define SIZE_OF_STRUC_INPUT_BOX		struc_input_box.end_of_struc

struc struc_window
	.flags			resw 1	; flags
	.title			resw 1	; 2nd level pointer to window title
	.win_attr		resw 1  ; window attribute, 
					; high = title, low = frame
	.win_pos		resw 1	; window position, 
					; high = row, low = col
	.win_size		resw 1	; window size,
					; high = height, low = width
	.parent_win		resw 1	; pointer to parent window
	.next_win		resw 1  ; pointer to next window
	.previous_win		resw 1  ; pointer to previous window

	.act_num		resw 1  ; number of actions
	.act_table		resw 1	; pointer to action table

	.default_event_handle	resw 1	; default key event handle
	.event_handle		resw 1	; key event handle
	.draw_body_proc		resw 1	; draw window body proc
	.end_of_struc
endstruc

struc struc_action
	.flags			resb 1	; flags
	.keycode		resw 1	; keycode
	.func			resw 1	; function entry
	.end_of_struc
endstruc


; For menubox, the actions of menu items are stored in struc_window.act_table.
; First items_num actions in act_table are menu items'. Other actions are 
; hotkeys.

struc struc_menu_box
; first part is a struc_window data
	.window			resb SIZE_OF_STRUC_WINDOW

; data member of menu box
	.menu_header		resw 1	; 2nd level pointer to menu header string
	.menu_header_attr	resb 1	; attribute of menu header (if have)
	.menu_norm_attr		resw 1	; attribute of normal menu item, 
					; high = hotkey attr, low =normal attr
	.menu_focus_attr	resw 1	; attribute of focused menu item
	.menu_area_pos		resw 1	; position of menu area
	.menu_area_size		resw 1	; size of menu area
	.scrollbar_attr		resb 1	; attribute of scrollbar

	.items_num		resb 1	; number of menu items
	.focus_item		resb 1	; focused item
	.first_visible_item	resb 1	; first visible item

	.item_str_proc		resw 1	; proc of get a item's string
					; input cx = index, si -> menu
					; output si -> string
	.end_of_struc
endstruc

struc struc_message_box
	.window			resb SIZE_OF_STRUC_WINDOW
	.message		resw 1  ; pointer to the message
	.message_attr		resw 1  ; attribute of the message
	.pressed_key		resw 1  ; the key which user pressed
	.end_of_struc
endstruc

struc struc_input_box
	.window			resb SIZE_OF_STRUC_WINDOW
	.message		resw 1  ; pointer to the message
	.message_attr		resw 1  ; attribute of the message
	.input_attr		resb 1  ; attribute of input area
	.input_type		resb 1	; input type, 0=normal, 1=passwd
	.input_buf		resw 1	; pointer to input buffer
	.input_buf_len		resb 1	; length of input buffer
	.input_area_len		resb 1	; length of input area
	.input_area_pos		resw 1	; position of input area (in window)
	.input_startp		resb 1	; the first visible char in input buf
	.input_curp		resb 1	; cursor position
	.return_val		resb 1	; return val, 0 = success, 1 = cancel
	.end_of_struc
endstruc

; vi:nowrap
