; tempdata.asm
;
; some temp data for Smart Boot Manager
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

;==============================================================================
;temp data area for hd_io.asm
;==============================================================================
%ifdef HAVE_HD_IO
%ifndef HD_IO_TEMPDATA
%define HD_IO_TEMPDATA

hdio_tmp:
.cdbc_cmd	resb SIZE_OF_CDBC_CMD
.extparam	resb SIZE_OF_EXTPARAM
.int13ext	resb SIZE_OF_INT13EXT
.driveinfo	resb SIZE_OF_DRIVEINFO
.disk_errno	resb 1

%endif
%endif

;==============================================================================
;temp data area for knl.asm
;==============================================================================
%ifdef HAVE_KNL
%ifndef KNL_TEMPDATA
%define KNL_TEMPDATA

knl_tmp:
.good_record_num	resb 1
.max_record_num		resb 1
.part_id		resb 1
.logi_father		resd 1

.floppy_num		resb 1
.cdemu_spec		resb SIZE_OF_CDEMU_SPEC

.disk_buf1		resb 2048
.disk_buf2		resb 2048

%endif
%endif

;==============================================================================
;temp data area for ui.asm
;==============================================================================
%ifdef HAVE_UI
%ifndef UI_TEMPDATA
%define UI_TEMPDATA

ui_tmp:
.left_col	resb  1
.top_row	resb  1
.right_col	resb  1
.bottom_row	resb  1
.frame_attr	resb  1
.title_attr	resb  1
.focus_win	resw  1
.root_win	resw  1
.def_root_win	resb SIZE_OF_STRUC_WINDOW
.tmp_msgbox	resb SIZE_OF_STRUC_MESSAGE_BOX
.tmp_inputbox	resb SIZE_OF_STRUC_INPUT_BOX
.tmp_menubox	resb SIZE_OF_STRUC_MENU_BOX
.tmp_buf	resb  256
.tmp_buf1	resb  256

%endif
%endif

;==============================================================================
;temp data area for utils.asm
;==============================================================================
%ifdef HAVE_UTILS
%ifndef UTILS_TEMPDATA
%define UTILS_TEMPDATA

utils_tmp:
.kbd_work	       resb  1
.kbd_last_shift        resb  1
.kbd_bypass_next_shift resb 1

%endif
%endif

;=============================================================================
;temp data area for main.asm
;=============================================================================
%ifdef HAVE_MAIN_PROG
%ifndef MAIN_TEMPDATA
%define MAIN_TEMPDATA

main_tmp:
.good_record_list    resb MAX_RECORD_NUM

.time_count         resb  1                       ;
.ticks_count        resw  1                       ; used in get_key func
.key_pressed        resb  1                       ;
.keycode            resw  1

.change_occured     resb  1                       ; if change occured.
.root_login         resb  1                       ; root login state.

.last_time          resw  1

.schedule_begin  resw  1
.schedule_end    resw  1
.schedule_day    resw  1

.keystroke_ptr   resw  1
.keystroke_num   resb  1
.keystroke_max   resb  1
.ikbox           resb SIZE_OF_STRUC_MENU_BOX

.records_buf     resb MAX_RECORD_NUM * SIZE_OF_BOOTRECORD
.record_string   resb 80
.dialog_buf      resb 256
.root_buf        resb 80

%endif
%endif

%ifdef HAVE_MYINT13H
%ifndef MYINT13H_TEMPDATA
%define MYINT13H_TEMPDATA

myint13h_tmp:
.edd30_off  resw 1
.edd30_seg  resw 1

%endif
%endif

