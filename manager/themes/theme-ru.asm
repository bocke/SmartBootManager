; asmsyntax=nasm
;
; theme-ru.asm
;
; Russian theme data for Smart Boot Manager
; Copyright (C) 2000, Suzhe. See file COPYING for details.
; Copyright (C) 2000, Victor O`Muerte <vomuerte@mail.ru>
; Charset=IBM-866/DOS

; some constant used in this theme.

; PLEASE DO NOT CHANGE THESE, UNLESS YOU KNOW WHAT YOU ARE DOING!
%define SBMT_MAGIC      0x544D4253         ; magic number of
                                           ; Smart Boot Manager theme.
%define SBMT_VERSION    0x035A             ; version of theme (3.90).

start_font          equ     219
brand_char1         equ     start_font
brand_char2         equ     start_font+1
brand_char3         equ     start_font+2
brand_char4         equ     start_font+3


start_of_theme:

;!!! PLEASE DON NOT CHANGE THE SIZE AND ORDER OF FOLLOWING DATA !!!

;=============================================================================
;the header of Smart Boot Manager theme ( 16 bytes )
;=============================================================================
theme_magic         dd  SBMT_MAGIC ; magic number = 'SBMT', 4 bytes.
                                   ; it's abbr. of 'Smart Boot Manager Theme'
                    dw  0          ;
theme_lang          db  'ru-RU',0  ; language of this theme, 6 bytes.
theme_version       dw  SBMT_VERSION ; version, high byte is major version,
                                   ; low byte is minor version. should be
                                   ; equal to the version of Smart Boot Manager.
theme_size          dw  (end_of_theme - start_of_theme)
                                   ; size of the theme (bytes).

;=============================================================================
; fix size data and index tables of variable size data
;=============================================================================

video_mode          db 0xff        ; 0 = 90x25, 0xff = 80x25
                                   ; do not use other value!!!

keyboard_type       db 0x10        ; = 0x10 means use enhanced keyboard
                                   ; = 0x00 means use normal keyboard
                                   ; CAUTION: cannot use other value!!!

show_date_method    db  3          ; the method of show date:
                                   ; 0 = don't show date
                                   ; 1 = day mm-dd-yyyy
                                   ; 2 = day yyyy-mm-dd
                                   ; 3 = day dd-mm-yyyy

show_time_method    db  1          ; the method of show time:
                                   ; 0 = don't show time
                                   ; 1 = hh:mm (24 hours)

yes_key_lower       db  'y'
yes_key_upper       db  'Y'


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

  db  'А', 000h,000h,01Eh,036h,066h,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'Б', 000h,000h,0FEh,062h,060h,060h,07Ch,066h,066h,066h,066h,0FCh,000h,000h,000h,000h
  db  'В', 000h,000h,0FCh,066h,066h,066h,07Ch,066h,066h,066h,066h,0FCh,000h,000h,000h,000h
  db  'Г', 000h,000h,0FEh,066h,062h,060h,060h,060h,060h,060h,060h,0F0h,000h,000h,000h,000h
  db  'Д', 000h,000h,01Eh,036h,066h,066h,066h,066h,066h,066h,066h,0FFh,0C3h,081h,000h,000h
  db  'Е', 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h
  db  'Ж', 000h,000h,0DBh,0DBh,05Ah,05Ah,07Eh,07Eh,05Ah,0DBh,0DBh,0DBh,000h,000h,000h,000h
  db  'З', 000h,000h,07Ch,0C6h,006h,006h,03Ch,006h,006h,006h,0C6h,07Ch,000h,000h,000h,000h
  db  'И', 000h,000h,0C6h,0C6h,0C6h,0CEh,0DEh,0F6h,0E6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'Й', 06Ch,038h,0C6h,0C6h,0C6h,0CEh,0DEh,0F6h,0E6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'К', 000h,000h,0E6h,066h,06Ch,06Ch,078h,078h,06Ch,06Ch,066h,0E6h,000h,000h,000h,000h
  db  'Л', 000h,000h,01Fh,036h,066h,066h,066h,066h,066h,066h,066h,0CFh,000h,000h,000h,000h
  db  'М', 000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'Н', 000h,000h,0C6h,0C6h,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'О', 000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
  db  'П', 000h,000h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'Р', 000h,000h,0FCh,066h,066h,066h,066h,07Ch,060h,060h,060h,0F0h,000h,000h,000h,000h
  db  'С', 000h,000h,07Ch,0C6h,0C6h,0C0h,0C0h,0C0h,0C0h,0C2h,0C6h,07Ch,000h,000h,000h,000h
  db  'Т', 000h,000h,0FFh,0DBh,099h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
  db  'У', 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,006h,0C6h,07Ch,000h,000h,000h,000h
  db  'Ф', 000h,000h,07Eh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,07Eh,018h,03Ch,000h,000h,000h,000h
  db  'Х', 000h,000h,0C6h,0C6h,06Ch,07Ch,038h,038h,07Ch,06Ch,0C6h,0C6h,000h,000h,000h,000h
  db  'Ц', 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0FFh,003h,003h,000h,000h
  db  'Ч', 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,006h,006h,006h,000h,000h,000h,000h
  db  'Ш', 000h,000h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0FEh,000h,000h,000h,000h
  db  'Щ', 000h,000h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0FFh,003h,003h,000h,000h
  db  'Ъ', 000h,000h,0F8h,0F0h,0B0h,030h,03Eh,033h,033h,033h,033h,07Eh,000h,000h,000h,000h
  db  'Ы', 000h,000h,0C3h,0C3h,0C3h,0C3h,0F3h,0DBh,0DBh,0DBh,0DBh,0F3h,000h,000h,000h,000h
  db  'Ь', 000h,000h,0F0h,060h,060h,060h,07Ch,066h,066h,066h,066h,0FCh,000h,000h,000h,000h
  db  'Э', 000h,000h,07Ch,0C6h,006h,026h,03Eh,026h,006h,006h,0C6h,07Ch,000h,000h,000h,000h
  db  'Ю', 000h,000h,0CEh,0DBh,0DBh,0DBh,0FBh,0DBh,0DBh,0DBh,0DBh,0CEh,000h,000h,000h,000h
  db  'Я', 000h,000h,03Fh,066h,066h,066h,03Eh,03Eh,066h,066h,066h,0E7h,000h,000h,000h,000h
  db  'а', 000h,000h,000h,000h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
  db  'б', 000h,002h,006h,07Ch,0C0h,0C0h,0FCh,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
  db  'в', 000h,000h,000h,000h,000h,0FCh,066h,066h,07Ch,066h,066h,0FCh,000h,000h,000h,000h
  db  'г', 000h,000h,000h,000h,000h,0FEh,062h,062h,060h,060h,060h,0F0h,000h,000h,000h,000h
  db  'д', 000h,000h,000h,000h,000h,01Eh,036h,066h,066h,066h,066h,0FFh,0C3h,0C3h,000h,000h
  db  'е', 000h,000h,000h,000h,000h,07Ch,0C6h,0C6h,0FEh,0C0h,0C6h,07Ch,000h,000h,000h,000h
  db  'ж', 000h,000h,000h,000h,000h,0D6h,0D6h,054h,07Ch,054h,0D6h,0D6h,000h,000h,000h,000h
  db  'з', 000h,000h,000h,000h,000h,07Ch,0C6h,006h,03Ch,006h,0C6h,07Ch,000h,000h,000h,000h
  db  'и', 000h,000h,000h,000h,000h,0C6h,0C6h,0CEh,0D6h,0E6h,0C6h,0C6h,000h,000h,000h,000h
  db  'й', 000h,000h,000h,06Ch,038h,0C6h,0C6h,0CEh,0D6h,0E6h,0C6h,0C6h,000h,000h,000h,000h
  db  'к', 000h,000h,000h,000h,000h,0E6h,06Ch,078h,078h,06Ch,066h,0E6h,000h,000h,000h,000h
  db  'л', 000h,000h,000h,000h,000h,01Eh,036h,066h,066h,066h,066h,0E6h,000h,000h,000h,000h
  db  'м', 000h,000h,000h,000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0D6h,0C6h,000h,000h,000h,000h
  db  'н', 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'о', 000h,000h,000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
  db  'п', 000h,000h,000h,000h,000h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
  db  'р', 000h,000h,000h,000h,000h,0DCh,066h,066h,066h,066h,066h,07Ch,060h,060h,0F0h,000h
  db  'с', 000h,000h,000h,000h,000h,07Ch,0C6h,0C0h,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
  db  'т', 000h,000h,000h,000h,000h,07Eh,05Ah,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
  db  'у', 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,006h,0C6h,07Ch,000h
  db  'ф', 000h,000h,000h,03Ch,018h,07Eh,0DBh,0DBh,0DBh,0DBh,0DBh,07Eh,018h,018h,03Ch,000h
  db  'х', 000h,000h,000h,000h,000h,0C6h,06Ch,038h,038h,038h,06Ch,0C6h,000h,000h,000h,000h
  db  'ц', 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0FFh,003h,003h,000h,000h
  db  'ч', 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,006h,000h,000h,000h,000h
  db  'ш', 000h,000h,000h,000h,000h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0FEh,000h,000h,000h,000h
  db  'щ', 000h,000h,000h,000h,000h,0D6h,0D6h,0D6h,0D6h,0D6h,0D6h,0FEh,003h,003h,000h,000h
  db  'ъ', 000h,000h,000h,000h,000h,0F8h,0B0h,0B0h,03Eh,033h,033h,07Eh,000h,000h,000h,000h
  db  'ы', 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0F6h,0DEh,0DEh,0F6h,000h,000h,000h,000h
  db  'ь', 000h,000h,000h,000h,000h,0F0h,060h,060h,07Ch,066h,066h,0FCh,000h,000h,000h,000h
  db  'э', 000h,000h,000h,000h,000h,07Ch,0C6h,006h,03Eh,006h,0C6h,07Ch,000h,000h,000h,000h
  db  'ю', 000h,000h,000h,000h,000h,0CEh,0DBh,0DBh,0FBh,0DBh,0DBh,0CEh,000h,000h,000h,000h
  db  'я', 000h,000h,000h,000h,000h,07Fh,0C6h,0C6h,07Eh,036h,066h,0E7h,000h,000h,000h,000h
  db  'Ё', 06Ch,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h
  db  'ё', 000h,000h,000h,06Ch,000h,07Ch,0C6h,0C6h,0FCh,0C0h,0C6h,07Ch,000h,000h,000h,000h

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
.boot_menu_title                db  'Загрузочное меню', 0
.boot_menu_header               db  '  Флаги     '
.boot_menu_header_noflags       db  '  Номер '
.boot_menu_header_nonumber      db  '  Тип    '
.boot_menu_header_notype        db  '  Имя',0

; window titles.
.about              db  'О программе',0   
.error              db  'Ошибка',0           
.help               db  'Помощь',0           
.info               db  'Информация',0       
.input              db  'Ввод', 0  

; used in input boxes.
.delay_time         db  'Задержка загрузки: ',0
.name               db  'Имя: ',0
.new_root_passwd    db  'Новый '
.root_passwd        db  'пароль Администратора: ',0
.new_record_passwd  db  'Новый '
.record_passwd      db  'пароль для загрузки: ',0
.retype_passwd      db  'Повторите ввод: ',0
.input_schedule     db  'Расписание загрузки (чч:мм-чч:мм;дни): ',0
.input_keystrokes   db  'Введите комбинацию клавиш (максимум 13)',0x0d
                    db  'Нажмите <Scroll Lock> для завершения',0x0d
                    db  'Код клавиши = 0x',0
.key_count          db  0x0d,'Нажато клавиш = ',0
.io_port            db  'I/O порты (порт1,порт2): ',0
.year               db  'Год: ',0

; used in record info box.
.drive_id           db       'ID диска: ',0
.part_id            db  0x0d,'ID раздела: ',0
.record_type        db  0x0d,'Тип записи: ',0
.record_name        db  0x0d,'Имя записи: ',0
.auto_active        db  0x0d,0x0d,'Автоматически активизируемая: ',0
.active             db  0x0d,'Активная: ',0
.auto_hide          db  0x0d,'Автоматически скрываемая: ',0
.hidden             db  0x0d,'Скрытая: ',0
.swap_drv           db  0x0d,'Переставлять диски: ',0
.logical            db  0x0d,'Логическая: ',0
.key_strokes        db  0x0d,0x0d,'Комбинация клавиш: ',0
.password           db  0x0d,'Пароль: ',0
.schedule           db  0x0d,'Расписание: ',0

.yes                db  'Да ',0
.no                 db  'Нет',0

; copyright infomation, displayed at the top of the screen.
.copyright          db  ' Smart Boot Manager 3.90.1 | Copyright (C) 2001 Suzhe',0

; hint message, displayed at the bottom of the screen.
 .hint               db  ' ~F1~-Помощь ~F2~-Сохр. ~F3~-Имя ~F4~-Активизир. ~F5~-Скрыть ~Tab~-Меню',0

; about infomation.
.about_content      db  '                        Smart Boot Manager 3.90.1-ru'                             ,0x0d
                    db  '              Copyright (C) 2001 Suzhe <su_zhe@sina.com>'                   ,0x0d
                    db  '   Перевод на русский язык (C) 2001 Victor O`Muerte <vomuerte@mail.ru>'     ,0x0d
                    db  '                   посвящается Марьяне Ганичевой с ',0x03,0x2e                            ,0x0d,0x0d
                    db  '                   Эта программа находится под защитой'                     ,0x0d
                    db  '            Генеральной Общедоступной лицензии (GNU) версии 2.'             ,0x0d
                    db  '     Вы можете распространять и/или изменять её по своему усмотрению.'      ,0x0d,0x0d
                    db  '     Эта программа распространяется БЕЗ КАКИХ БЫ ТО НИ БЫЛО ГАРАНТИЙ.'      ,0

; help infomation.
.help_content:
        db '      F1 = Помощь                  Ctrl+F1 = О программе',0x0d
        db '      F2 = Сохранить                    F3 = Переименовать',0x0d
        db '      F4 = Активизировать               F5 = Спрятать/показать',0x0d
        db '      F6 = Авто активизировать          F7 = Автоматически прятать',0x0d
        db '      F8 = Включить по умолчанию  Shift+F8 = Отключить по умолчанию',0x0d
        db '  Ctrl+D = Удалить                  Ctrl+P = Дублировать',0x0d
        db '  Ctrl+U = Запись верх              Ctrl+N = Запись вниз',0x0d
        db '  Ctrl+S = Расписание загрузки      Ctrl+T = Установить задержку',0x0d
        db '  Ctrl+K = Комбинация клавиш       / или ? = Информация',0x0d
        db '  Ctrl+I = Перечитать загрузочные   Ctrl+H = Перечитать все разделы',0x0d,
        db '  Ctrl+X = Переставлять диски       Ctrl+F = Изменить вид меню',0x0d
        db '  Ctrl+L = Запоминать последнюю',0x0d
        db '      F9 = Пароль загрузки',0x0d
        db '     F10 = Пароль Администратора',0x0d
        db 'Ctrl+F10 = Режим Администратора',0x0d
        db ' Alt+F10 = Защищенный режим',0x0d
        db '     Tab = Главное меню',0x0d
        db '  Ctrl+Q = Выход                   Ctrl+F12 = Выключить компьютер',0

; normal messages.
.changes_saved      db  'Изменения сохранены.',0
.passwd_changed     db  'Пароль изменен.',0
.ask_save_changes   db  'Сохранить изменения (y/n)?',0

; error messages.
.wrong_passwd       db  'Неверный пароль!',0
.disk_error         db  'Ошибка диска! 0x',0
.mark_act_failed    db  'Не удалось сделать активной!',0
.toggle_hid_failed  db  'Не удалось спрятать/показать!',0
.no_system          db  'Операционной системы не обнаружено!',0x0d
                    db  'Переставьте диск и попробуйте ещё .',0
.invalid_record     db  'Неверная загрузочная запись!',0
.invalid_schedule   db  'Неверное расписание загрузки!',0
.inst_confirm       db  'Вы действительно хотите установить Smart BootManager ',
                    db  'на диск ',0
.inst_ok            db  'Установка Smart BootManager успешно завершена!',0
.inst_abort         db  'Установить Smart BootManager не удалось.',0
.uninst_confirm     db  'Неужели Вы действительно хотите удалить Smart BootManager?',0x0d,0
.uninst_ok          db  'Удаление Smart BootManager успешно завершено!;-(',0x0d
                    db  'Компьютер должен быть перезагружен.',0
.uninst_abort       db  'Удалить Smart BootManager не удалось.',0
.confirm            db  'Нажмите Y для продолжения или любую другую клавишу для отмены.',0
.no_sbml            db  'Smart Boot Manager Loader missing ',0x0d
                    db  'or version mismatch!',0
.invalid_ioports    db  'Неверные I/O порты!',0


; command menu strings
; main menu
.main_menu_title     db  'Главное меню',0
.main_menu_help      db  'Помощь                        ~F1~',0
.main_menu_about     db  'О программе              ~Ctrl-F1~',0
.main_menu_bootit    db  'Загрузить',0
.main_menu_bootprev  db  'Загрузить предыдущую MBR',0
.main_menu_quit      db  'Выход                     ~Ctrl-Q~',0
.main_menu_poweroff  db  'Выключить компьютер     ~Ctrl-F12~',0
.main_menu_recordset db  'Установки загрузочной записи  -',16,0
.main_menu_sysset    db  'Системные установки           -',16,0
.main_menu_save      db  'Сохранить изменения           ~F2~',0
.main_menu_bar       db  '--------------------------------',0

; record settings menu
.record_menu_title    db  'Установки загрузочной записи',0
.record_menu_info     db  'Информация                 ~/ или ?~',0
.record_menu_name     db  'Имя                             ~F3~',0
.record_menu_passwd   db  'Пароль                          ~F9~',0
.record_menu_schedule db  'Расписание загрузки         ~Ctrl-S~',0
.record_menu_keys     db  'Комбинация клавиш           ~Ctrl-K~',0
.record_menu_act      db  'Сделать активной                ~F4~',0
.record_menu_hide     db  'Спрятать/показать               ~F5~',0
.record_menu_autoact  db  'Автоматически активизировать    ~F6~',0
.record_menu_autohide db  'Автоматически прятать           ~F7~',0
.record_menu_swapdrv  db  'Переставлять диски          ~Ctrl-X~',0
.record_menu_del      db  'Удалить                     ~Ctrl-D~',0
.record_menu_dup      db  'Дублировать                 ~Ctrl-P~',0
.record_menu_moveup   db  'Вверх                       ~Ctrl-U~',0
.record_menu_movedown db  'Вниз                        ~Ctrl-N~',0
.record_menu_bar      db  '----------------------------------',0

; system setting menu
.sys_menu_title       db  'Системные установки',0
.sys_menu_rootpasswd  db  'Изменить пароль Администратора         ~F10~',0
.sys_menu_admin       db  'Режим Администратора              ~Ctrl-F10~',0
.sys_menu_security    db  'Защищенный режим                   ~Alt-F10~',0
.sys_menu_setdef      db  'Включить загрузку по умолчанию          ~F8~',0
.sys_menu_unsetdef    db  'Отключить загрузку по умолчанию   ~Shift-F8~',0
.sys_menu_delay       db  'Установить задержку загрузки        ~Ctrl-T~',0
.sys_menu_bmstyle     db  'Изменить стиль загрузочного меню    ~Ctrl-F~',0
.sys_menu_remlast     db  'Запоминать последнюю загрузку       ~Ctrl-L~',0
.sys_menu_int13ext    db  'Toggle Extended Int 13H',0
.sys_menu_rescanall   db  'Перечитать все загрузочные записи   ~Ctrl-I~',0
.sys_menu_rescanpart  db  'Перечитать все разделы              ~Ctrl-H~',0
.sys_menu_set_ioports db  'Установить I/O порты CD-ROM',0
.sys_menu_set_y2kfix  db  'Установить год (исправление "Ошибки 2000")',0
.sys_menu_inst        db  'Установить Smart BootManager',0
.sys_menu_uninst      db  'Удалить Smart BootManager',0
.sys_menu_bar         db  '------------------------------------------',0

.cdimg_menu_title     db  'Выбор образа CD', 0
.cdimg_menu_noemu     db  'Без эмуляции',0
.cdimg_menu_120m      db  '1.2 M дискета',0
.cdimg_menu_144m      db  '1.44M дискета',0
.cdimg_menu_288m      db  '2.88M дискета',0

.sunday              db 'Вс',0
.monday              db 'Пн',0
.tuesday             db 'Вт',0
.wednesday           db 'Ср',0
.thursday            db 'Чт',0
.friday              db 'Пт',0
.saturday            db 'Сб',0


; END OF THEME.
end_of_theme:

; vi:ts=8:et:nowrap
