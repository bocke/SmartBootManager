; asmsyntax=nasm
;
; theme-us.asm
;
; English theme data for Smart Boot Manager
;
; Copyright (C) 2001, Suzhe. See file COPYING for details.
;

; some constant used in this theme.

; PLEASE DO NOT CHANGE THESE, UNLESS YOU KNOW WHAT YOU ARE DOING!
%define SBMT_MAGIC      0x544D4253         ; magic number of
                                           ; Smart Boot Manager theme.
%define SBMT_VERSION    0x035A             ; version of theme ( 3.90 ).

start_font              equ     219
brand_char1             equ     start_font
brand_char2             equ     start_font+1
brand_char3             equ     start_font+2
brand_char4             equ     start_font+3


start_of_theme:

;!!! PLEASE DON NOT CHANGE THE SIZE AND ORDER OF FOLLOWING DATA !!!

;=============================================================================
;the header of Smart Boot Manager theme ( 16 bytes )
;=============================================================================
theme_magic             dd  SBMT_MAGIC ; magic number = 'SBMT', 4 bytes.
                                       ; it's abbr. of 'Smart Boot Manager Theme'
                        dw  0          ;
theme_lang              db  'en-US',0  ; language of this theme, 6 bytes.
theme_version           dw  SBMT_VERSION ; version, high byte is major version,
                                         ; low byte is minor version. should be
                                         ; equal to the version of Smart Boot Manager.
theme_size              dw  (end_of_theme - start_of_theme)
                                         ; size of the theme (bytes).

;=============================================================================
; fix size data and index tables of variable size data
;=============================================================================

video_mode              db  0xff        ; 0 = 90x25, 0xff = 80x25
                                        ; do not use other value!!!

keyboard_type           db  0x10        ; = 0x10 means use enhanced keyboard
                                        ; = 0x00 means use normal keyboard
                                        ; CAUTION: cannot use other value!!!

show_date_method        db  1           ; the method of show date:
                                        ; 0 = don't show date
                                        ; 1 = day mm-dd-yyyy
                                        ; 2 = day yyyy-mm-dd
                                        ; 3 = day dd-mm-yyyy

show_time_method        db  1           ; the method of show time:
                                        ; 0 = don't show time
                                        ; 1 = hh:mm (24 hours)

yes_key_lower	        db  'y'
yes_key_upper	        db  'Y'
 
; position of screen elements, low byte = column, high byte = row
position:
.brand                  dw  0x00FF      ; start position of brand icon
                                        ; low = column, high = row
                                        ; if low = 255 then brand will be
                                        ; right justify in the screen.
.date                   dw  0x0037

.time                   dw  0x0046

; size of screen elements
size:
.copyright              db  1           ; number of rows used by copyright info
.hint                   db  1           ; number of rows used by hint info
.box_width              db  5           ; the minimal width of info/error/input box
                                        ; (when no info string)
.box_height             db  4           ; the minimal height of info/error/input box
                                        ; (when no info string)
.boot_menu_win_height   db  13          ; the height of the boot menu window
.list_box_win_height    db  10          ; the height of the list box window

;Black          = 0
;Blue           = 1
;Green          = 2
;Cyan           = 3
;Red            = 4
;Violet         = 5
;Yellow (brown) = 6
;White          = 7
;Black (gray)   = 8
;Intense blue   = 9
;Intense green  = a
;Intense cyan   = b
;Intense red    = c
;Intense violet = d
;Intense yellow = e
;Intense white  = f

; color of screen elements
; high 4 bits is background color, low 4 bits is foreground color

color:
.win_title_inactive     db  0x70        ; title attribute for inactive window.

.boot_menu:
.boot_menu_frame        db  0x3F        ; attributes of boot menu window
.boot_menu_title        db  0xF1        ;
.boot_menu_header       db  0x1F        ;
.boot_menu_normal       dw  0x7C70      ;
.boot_menu_focus        dw  0x0C0F      ; 
.boot_menu_scrollbar    db  0x3F        ; scroll bar

.cmd_menu:
.cmd_menu_frame         db  0x30        ;
.cmd_menu_title         db  0xF1        ; the colors used 
.cmd_menu_header        db  0x3F        ;
.cmd_menu_normal        dw  0x3C30      ; in command menu
.cmd_menu_focus         dw  0x0C07      ;
.cmd_menu_scrollbar     db  0x3F        ;

.list_box:
.list_box_frame         db  0x30        ;
.list_box_title         db  0xF1        ; list box
.list_box_header        db  0x1F        ;
.list_box_normal        dw  0x3C30      ;
.list_box_focus         dw  0x0C07      ;
.list_box_scrollbar     db  0x3F        ;

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

.help_win:
.help_win_frame         db  0x3F        ;
.help_win_title         db  0xF1        ; help window
.help_msg               db  0x30        ;

.about_win:
.about_win_frame        db  0x3F        ;
.about_win_title        db  0xF1        ; about window
.about_msg              db  0x3E        ;

.delay_time             db  0x70        ; delay time
.background             db  0x00        ; background (if no background icon)
.copyright              dw  0x7470      ; copyright string
.hint                   dw  0x7470      ; hint string
.knl_flags              db  0x7C        ; the color of kernal fags.
.knl_drvid              db  0x70        ; the color of kernel drive id.
.date                   db  0x70        ; color of date string
.time                   db  0x70        ; color of time string

; icon data
icon:
.brand_size         dw  0x0104              ; the size of brand icon,
                                            ; high byte = row, low byte = col.
.brand              dw  icon_data.brand     ; offset of brand icon data, set to
                                            ; zero if no brand icon.

.background_size    dw  0x0104              ; the size of background icon,
                                            ; high byte = row, low byte = col.
.background         dw  icon_data.background; offset of background icon data,
                                            ; set to zero if no background icon.

; font data
font:
.number             dw  (font_data.end-font_data)/17
                                            ; number of chars to be replaced,
                                            ; should <= (256 - start).
.data               dw  font_data           ; offset of font set data, set to
                                            ; zero if no font to be replaced.

; chars used by window frame
frame_char:
.top                db     0x20            ; top horizontal
.bottom             db     0xCD            ; bottom horiztontal
.left               db     0xBA            ; left vertical
.right              db     0xBA            ; right vertical
.tl_corner          db     0xC9            ; top left corner
.tr_corner          db     0xBB            ; top right corner
.bl_corner          db     0xC8            ; bottom left corner
.br_corner          db     0xBC            ; bottom right corner

; how to draw window frame
draw_frame_method   db  1          ; = 0 means draw all frame using frame attr.
                                   ; = 1 means draw top horizontal line using
                                   ;     title attr.
                                   ; = 2 means draw top corner and horizontal
                                   ;     line using title attr.

; keymap data
keymap:                                  ; entry of keymap
.number             dw  (keymap_data.end-keymap_data)/4
                                           ; number of keymap entries
.data               dw  keymap_data      ; pointer to keymap

; index table of strings
str_idx:
.boot_menu_title                dw  string.boot_menu_title
.boot_menu_header               dw  string.boot_menu_header
.boot_menu_header_noflags       dw  string.boot_menu_header_noflags
.boot_menu_header_nonumber      dw  string.boot_menu_header_nonumber
.boot_menu_header_notype        dw  string.boot_menu_header_notype

.about              dw  string.about
.error              dw  string.error
.help               dw  string.help
.info               dw  string.info
.input              dw  string.input

.delay_time         dw  string.delay_time
.name               dw  string.name
.new_root_passwd    dw  string.new_root_passwd
.root_passwd        dw  string.root_passwd
.new_record_passwd  dw  string.new_record_passwd
.record_passwd      dw  string.record_passwd
.retype_passwd      dw  string.retype_passwd
.input_schedule     dw  string.input_schedule
.input_keystrokes   dw  string.input_keystrokes
.key_count          dw  string.key_count
.io_port            dw  string.io_port
.year               dw  string.year

.drive_id           dw  string.drive_id
.part_id            dw  string.part_id
.record_type        dw  string.record_type
.record_name        dw  string.record_name
.auto_active        dw  string.auto_active
.active             dw  string.active
.auto_hide          dw  string.auto_hide
.hidden             dw  string.hidden
.swap_drv           dw  string.swap_drv
.logical            dw  string.logical
.key_strokes        dw  string.key_strokes
.password           dw  string.password
.schedule           dw  string.schedule
.yes                dw  string.yes
.no                 dw  string.no

.copyright          dw  string.copyright
.hint               dw  string.hint
.about_content      dw  string.about_content
.help_content       dw  string.help_content

.changes_saved      dw  string.changes_saved
.passwd_changed     dw  string.passwd_changed
.ask_save_changes   dw  string.ask_save_changes

.wrong_passwd       dw  string.wrong_passwd
.disk_error         dw  string.disk_error
.mark_act_failed    dw  string.mark_act_failed
.toggle_hid_failed  dw  string.toggle_hid_failed
.no_system          dw  string.no_system
.invalid_record     dw  string.invalid_record
.invalid_schedule   dw  string.invalid_schedule
.inst_confirm       dw  string.inst_confirm
.inst_ok            dw  string.inst_ok
.inst_abort         dw  string.inst_abort
.uninst_confirm     dw  string.uninst_confirm
.uninst_ok          dw  string.uninst_ok
.uninst_abort       dw  string.uninst_abort
.confirm            dw  string.confirm
.no_sbml            dw  string.no_sbml
.invalid_ioports    dw  string.invalid_ioports

; command menu str_idx
; main menu
.main_menu_title    dw string.main_menu_title
.main_menu_strings:
                    dw string.main_menu_help
                    dw string.main_menu_about
                    dw string.main_menu_save
                    dw string.main_menu_bootit
                    dw string.main_menu_bootprev
                    dw string.main_menu_bar
                    dw string.main_menu_recordset
                    dw string.main_menu_sysset
                    dw string.main_menu_bar
                    dw string.main_menu_quit
                    dw string.main_menu_poweroff

; record settings menu
.record_menu_title  dw string.record_menu_title
.record_menu_strings:
                    dw string.record_menu_info
                    dw string.record_menu_name
                    dw string.record_menu_passwd
                    dw string.record_menu_schedule
                    dw string.record_menu_keys
                    dw string.record_menu_bar
                    dw string.record_menu_act
                    dw string.record_menu_hide
                    dw string.record_menu_autoact
                    dw string.record_menu_autohide
                    dw string.record_menu_swapdrv
                    dw string.record_menu_bar
                    dw string.record_menu_del
                    dw string.record_menu_dup
                    dw string.record_menu_moveup
                    dw string.record_menu_movedown

; system setting menu
.sys_menu_title     dw string.sys_menu_title
.sys_menu_strings:
                    dw string.sys_menu_rootpasswd
                    dw string.sys_menu_admin
                    dw string.sys_menu_security
                    dw string.sys_menu_bar
                    dw string.sys_menu_setdef
                    dw string.sys_menu_unsetdef
                    dw string.sys_menu_delay
                    dw string.sys_menu_bmstyle
                    dw string.sys_menu_remlast
                    dw string.sys_menu_int13ext
                    dw string.sys_menu_bar
                    dw string.sys_menu_rescanall
                    dw string.sys_menu_rescanpart
                    dw string.sys_menu_set_ioports
                    dw string.sys_menu_set_y2kfix
                    dw string.sys_menu_bar
                    dw string.sys_menu_inst
                    dw string.sys_menu_uninst

.cdimg_menu_title   dw string.cdimg_menu_title
.cdimg_menu_strings dw string.cdimg_menu_noemu
                    dw string.cdimg_menu_120m
                    dw string.cdimg_menu_144m
                    dw string.cdimg_menu_288m

.sunday             dw string.sunday
.monday             dw string.monday
.tuesday            dw string.tuesday
.wednesday          dw string.wednesday
.thursday           dw string.thursday
.friday             dw string.friday
.saturday           dw string.saturday

end_of_str_idx:

;=============================================================================
; variable size data
;=============================================================================

; icon data

; two bytes corresponding to a char,
; high byte is color, low byte is char code.
icon_data:
.brand:
db  brand_char1, 0x7C, brand_char2, 0x7C, brand_char3, 0x7C, brand_char4, 0x7C

.background:
db  0xB0, 0x71, 0xB0, 0x71, 0xB0, 0x71, 0xB0, 0x71

; font data
; each char occupied 17 bytes
; the first bytes is the ascii code used by this char
; the following 16 bytes is font data
;
; NOTE:
;   Do not replace ascii char 0 and 0x0d, 0x1e and 0x1f,
;   these chars have special use.
;
font_data:
  db  start_font
  db  0x00,0x00,0x00,0x00,0x07,0x0c,0x08,0x08,0x0c,0x07,0x00,0x00,0x00,0x00,0xfe,0x00
  db  start_font+1
  db  0x01,0x01,0x01,0x01,0xfd,0x01,0x1f,0x1f,0x03,0xf7,0x0d,0x19,0x31,0x61,0xff,0xff
  db  start_font+2
  db  0x80,0x80,0x80,0x80,0xbf,0x80,0xf0,0xf8,0x98,0x9b,0x98,0x98,0x98,0x98,0x9e,0x9e
  db  start_font+3
  db  0x00,0x00,0x00,0x00,0xff,0x00,0x00,0x00,0x00,0xf0,0x18,0x08,0x08,0x18,0xf0,0x00
.end:

; keymap
; each entry has two words, the first is original keycode, 
; the second is new keycode.
keymap_data:
%ifdef KEYMAP_AZERTY
  %include "azerty.kbd"
%elifdef KEYMAP_QWERTZ
  %include "qwertz.kbd"
%elifdef KEYMAP_DVORAK
  %include "dvorak.kbd"
%elifdef KEYMAP_DVORAK_ANSI
  %include "dvorak-ansi.kbd"
%endif
.end:

; strings
; all strings are zero ending,
; use 0x0d to break string into multi-lines.
string:
; used in main window and boot menu.
.boot_menu_title                db  'Boot Menu',0
.boot_menu_header               db  '     Flags  '
.boot_menu_header_noflags       db  '  Number'
.boot_menu_header_nonumber      db  '  Type   '
.boot_menu_header_notype        db  '  Name',0

; window titles.
.about                          db  'About',0
.error                          db  'Error',0
.help                           db  'Help',0
.info                           db  'Infomation',0
.input                          db  'Input',0

; used in input boxes.
.delay_time                     db  'Delay time: ',0
.name                           db  'Name: ',0
.new_root_passwd                db  'New '
.root_passwd                    db  'Root password: ',0
.new_record_passwd              db  'New '
.record_passwd                  db  'Record password: ',0
.retype_passwd                  db  'Retype password: ',0
.input_schedule                 db  'Schedule (hh:mm-hh:mm;days): ',0
.input_keystrokes               db  'Input keystrokes (max 13 keys)',0x0d
                                db  'Press <Scroll Lock> to finish,',0x0d
                                db  'Key code = 0x',0
.key_count                      db  0x0d,'Key count = ',0
.io_port                        db  'I/O Base Ports (hex1,hex2): ',0
.year                           db  'Year: ',0

; used in record info box.
.drive_id                       db       '   Drive ID: ',0
.part_id                        db  '   Part ID: ',0
.record_type                    db  0x0d,'Record Type: ',0
.record_name                    db  0x0d,'Record Name: ',0

.auto_active                    db  0x0d,0x0d,'Auto Active: ',0
.active                         db  '    Active: ',0
.auto_hide                      db  0x0d,'  Auto Hide: ',0
.hidden                         db  '    Hidden: ',0
.swap_drv                       db  0x0d,'Swap driver: ',0
.logical                        db  '   Logical: ',0
.key_strokes                    db  0x0d,0x0d,'Key Strokes: ',0
.password                       db  '  Password: ',0
.schedule                       db  0x0d,'   Schedule: ',0

.yes                            db  'Yes',0
.no                             db  'No ',0

; copyright infomation, displayed at the top of the screen.
.copyright          db  ' Smart Boot Manager 3.90.1 | Copyright (C) 2001 Suzhe',0

; hint message, displayed at the bottom of the screen.
.hint               db  ' ~F1~-Help  ~F2~-Save  ~F3~-Rename  ~F4~-Active  ~F5~-Hide  ~Tab~-Menu',0

; about infomation.
.about_content      db  '           Smart Boot Manager 3.90.1',0x0d
                    db  '  Copyright (C) 2001 Suzhe <su_zhe@sina.com>',0x0d,0x0d
                    db  ' This is free software, you can redistribute',0x0d
                    db  '  it and/or modify it under the terms of the',0x0d
                    db  '     GNU General Public License version 2.',0x0d,0x0d
                    db  'This program comes with ABSOLUTELY NO WARRANTY!',0

; help infomation.
.help_content:
        db '      F1 = Help                  Ctrl+F1 = About',0x0d
        db '      F2 = Save                       F3 = Rename',0x0d
        db '      F4 = Mark active                F5 = Hide/unhide',0x0d
        db '      F6 = Toggle auto active         F7 = Toggle auto hide',0x0d
        db '      F8 = Set default          Shift+F8 = Unset default',0x0d
        db '  Ctrl+D = Delete                 Ctrl+P = Duplicate',0x0d
        db '  Ctrl+U = Move record up         Ctrl+N = Move record down',0x0d
        db '  Ctrl+S = Set/unset schedule     Ctrl+T = Set delay time',0x0d
        db '  Ctrl+K = Set/unset keystrokes   / or ? = Show information',0x0d
        db '  Ctrl+I = Rescan all records     Ctrl+H = Rescan all partitions',0x0d,
        db '  Ctrl+X = Toggle swap driver id  Ctrl+F = Show/hide flags',0x0d
        db '  Ctrl+L = Toggle remember the last booted record',0x0d
        db '      F9 = Change boot record password',0x0d
        db '     F10 = Change root password',0x0d
        db 'Ctrl+F10 = Enter/leave Administrator mode',0x0d
        db ' Alt+F10 = Enter/leave Security Lock mode',0x0d
        db '     Tab = Popup command menu',0x0d
        db '  Ctrl+Q = Quit to BIOS         Ctrl+F12 = Power off',0

; normal messages.
.changes_saved      db  'Changes saved.',0
.passwd_changed     db  'Password changed.',0
.ask_save_changes   db  'Save the changes (y/n)?',0

; error messages.
.wrong_passwd       db  'Wrong password!',0
.disk_error         db  'Disk error! 0x',0
.mark_act_failed    db  'Mark active failed!',0
.toggle_hid_failed  db  'Hide/unhide failed!',0
.no_system          db  'No Operating System!',0x0d
                    db  'Replace a disk and try again.',0
.invalid_record     db  'Invalid boot record!',0
.invalid_schedule   db  'Invalid schedule time!',0
.inst_confirm       db  'Sure to install Smart BootManager ',
                    db  'into driver ',0
.inst_ok            db  'Installation is successful!',0
.inst_abort         db  'Abort the installation.',0
.uninst_confirm     db  'Sure to uninstall Smart BootManager?',0x0d,0
.uninst_ok          db  'Uninstallation is successful!',0x0d
                    db  'Computer will be restarted.',0
.uninst_abort       db  'Abort the uninstallation.',0
.confirm            db  'Press Y to continue, other key to abort.',0
.no_sbml            db  'Smart Boot Manager Loader missing ',0x0d
                    db  'or version mismatch!',0
.invalid_ioports    db  'Invalid I/O Ports!',0

; command menu strings
; main menu
.main_menu_title     db  'Main Menu',0
.main_menu_help      db  'Help             ~F1~',0
.main_menu_about     db  'About       ~Ctrl-F1~',0
.main_menu_bootit    db  'Boot it',0
.main_menu_bootprev  db  'Boot Previous MBR',0
.main_menu_quit      db  'Quit         ~Ctrl-Q~',0
.main_menu_poweroff  db  'Power Off  ~Ctrl-F12~',0
.main_menu_recordset db  'Record Settings  ->',0
.main_menu_sysset    db  'System Settings  ->',0
.main_menu_save      db  'Save Changes     ~F2~',0
.main_menu_bar       db  '-------------------',0

; record settings menu
.record_menu_title    db  'Record Settings',0
.record_menu_info     db  'Information     ~/ or ?~',0
.record_menu_name     db  'Name                ~F3~',0
.record_menu_passwd   db  'Password            ~F9~',0
.record_menu_schedule db  'Schedule        ~Ctrl-S~',0
.record_menu_keys     db  'Keystrokes      ~Ctrl-K~',0
.record_menu_act      db  'Mark Active         ~F4~',0
.record_menu_hide     db  'Hide/unhide         ~F5~',0
.record_menu_autoact  db  'Auto Active         ~F6~',0
.record_menu_autohide db  'Auto Hide           ~F7~',0
.record_menu_swapdrv  db  'Swap Driver ID  ~Ctrl-X~',0
.record_menu_del      db  'Delete          ~Ctrl-D~',0
.record_menu_dup      db  'Duplicate       ~Ctrl-P~',0
.record_menu_moveup   db  'Move Up         ~Ctrl-U~',0
.record_menu_movedown db  'Move Down       ~Ctrl-N~',0
.record_menu_bar      db  '----------------------',0

; system setting menu
.sys_menu_title       db  'System Settings',0
.sys_menu_rootpasswd  db  'Root Password              ~F10~',0
.sys_menu_admin       db  'Toggle Admin Mode     ~Ctrl-F10~',0
.sys_menu_security    db  'Toggle Security Mode   ~Alt-F10~',0
.sys_menu_setdef      db  'Set Default Record          ~F8~',0
.sys_menu_unsetdef    db  'Unset Default Record  ~Shift-F8~',0
.sys_menu_delay       db  'Set Delay Time          ~Ctrl-T~',0
.sys_menu_bmstyle     db  'Change Boot Menu Style  ~Ctrl-F~',0
.sys_menu_remlast     db  'Toggle Remember Last    ~Ctrl-L~',0
.sys_menu_int13ext    db  'Toggle Extended Int 13H',0
.sys_menu_rescanall   db  'Rescan All Boot Records ~Ctrl-I~',0
.sys_menu_rescanpart  db  'Rescan All Partitions   ~Ctrl-H~',0
.sys_menu_set_ioports db  'Set CD-ROM I/O Ports',0
.sys_menu_set_y2kfix  db  'Set year (fix Y2K BIOS bug)',0
.sys_menu_inst        db  'Install Smart BootManager',0
.sys_menu_uninst      db  'Uninstall Smart BootManager',0
.sys_menu_bar         db  '------------------------------',0

.cdimg_menu_title     db  'Choose a CD Image',0
.cdimg_menu_noemu     db  'No Emulation',0
.cdimg_menu_120m      db  '1.2 M Diskette',0
.cdimg_menu_144m      db  '1.44M Diskette',0
.cdimg_menu_288m      db  '2.88M Diskette',0

.sunday              db 'Sun',0
.monday              db 'Mon',0
.tuesday             db 'Tue',0
.wednesday           db 'Wed',0
.thursday            db 'Thu',0
.friday              db 'Fri',0
.saturday            db 'Sat',0

; END OF THEME.
end_of_theme:

; vi:ts=8:et:nowrap
