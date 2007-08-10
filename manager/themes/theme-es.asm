; asmsyntax=nasm
;
; theme-es.asm
;
; Spanish theme data for Smart Boot Manager
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
; Copyright (C) 2000, Manuel Clos <llanero@jazzfree.com>
;

; some constant used in this theme.

; PLEASE DO NOT CHANGE THESE, UNLESS YOU KNOW WHAT YOU ARE DOING!
%define SBMT_MAGIC      0x544D4253         ; magic number of
                                           ; Smart Boot Manager theme.
%define SBMT_VERSION    0x035A             ; version of theme.

start_font          equ     219
brand_char1         equ     start_font
brand_char2         equ     start_font+1
brand_char3         equ     start_font+2
brand_char4         equ     start_font+3

        bits 16

%ifndef MAIN
        org 0                       ; DO NOT REMOVE/MODIFY THIS LINE!!!
%endif

start_of_theme:

;!!! PLEASE DON NOT CHANGE THE SIZE AND ORDER OF FOLLOWING DATA !!!

;=============================================================================
;the header of Smart Boot Manager theme ( 16 bytes )
;=============================================================================
theme_magic         dd  SBMT_MAGIC ; magic number = 'SBMT', 4 bytes.
                                   ; it's abbr. of 'Smart Boot Manager Theme'
                    dw  0          ;
theme_lang          db  'es-ES',0  ; language of this theme, 6 bytes.
theme_version       dw  SBMT_VERSION ; version, high byte is major version,
                                   ; low byte is minor version. should be
                                   ; equal to the version of Smart Boot Manager.
theme_size          dw  (end_of_theme - start_of_theme)
                                   ; size of the theme (bytes).

;=============================================================================
; fix size data and index tables of variable size data
;=============================================================================

video_mode          db  0xff       ; 0 = 90x25, 0xff = 80x25
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

yes_key_lower       db  's'
yes_key_upper       db  'S'

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

  db  'á', 000h,00Ch,018h,030h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
  db  'é', 000h,00Ch,018h,030h,000h,07Ch,0C6h,0C6h,0FCh,0C0h,0C6h,07Ch,000h,000h,000h,000h
  db  'ó', 000h,00Ch,018h,030h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
  db  'ú', 000h,00Ch,018h,030h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
  db  'ñ', 000h,000h,076h,0DCh,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h
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
.boot_menu_title                db  'Menú de Inicio',0
.boot_menu_header               db  '  Banderas  '
.boot_menu_header_noflags       db  '  Número'
.boot_menu_header_nonumber      db  '  Tipo   '
.boot_menu_header_notype        db  '  Nombre',0

; window titles.
.about              db  'Acerca de',0
.error              db  'Error',0
.help               db  'Ayuda',0
.info               db  'Información',0
.input              db  'Entrada',0

; used in input boxes.
.delay_time         db  'Tiempo de espera: ',0
.name               db  'Nombre: ',0
.new_root_passwd    db  'Nueva '
.root_passwd        db  'Contraseña de Administrador: ',0
.new_record_passwd  db  'Nueva '
.record_passwd      db  'Contraseña del registro: ',0
.retype_passwd      db  'Repetir contraseña: ',0
.input_schedule     db  'Programar (hh:mm-hh:mm;dias): ',0
.input_keystrokes   db  'Entrada de teclas (max 13 teclas)',0x0d
                    db  'Presione <Bloq Despl> para acabar,',0x0d
                    db  'Código de tecla  = 0x',0
.key_count          db  0x0d,'Número de teclas = ',0
.io_port            db  'Puertos Base E/S (hex1,hex2): ',0
.year               db  'Año: ',0

; used in record info box.
.drive_id           db       '    ID de la Unidad: ',0
.part_id            db  '  ID de la Part: ',0
.record_type        db  0x0d,'   Tipo de Registro: ',0
.record_name        db  0x0d,'Nombre del Registro: ',0

.auto_active        db  0x0d,0x0d,'   Auto Activa: ',0
.active             db  '    Activa: ',0
.auto_hide          db  0x0d,'   Auto Oculta: ',0
.hidden             db  '  Ocultada: ',0
.swap_drv           db  0x0d,'Cambiar unidad: ',0
.logical            db  '    Lógica: ',0
.key_strokes        db  0x0d,0x0d,'Teclas Pulsadas: ',0
.password           db  '  Contraseña: ',0
.schedule           db  0x0d,'     Programar: ',0

.yes                db  'Sí ',0
.no                 db  'No ',0

; copyright infomation, displayed at the top of the screen.
.copyright          db  ' Smart Boot Manager 3.90.1 | Copyright (C) 2001 Suzhe',0

; hint message, displayed at the bottom of the screen.
.hint               db  ' ~F1~-Ayuda ~F2~-Guardar ~F3~-Nombre ~F4~-Activa ~F5~-Oculta ~Tab~-Menú',0

; about infomation.
.about_content      db  '           Smart Boot Manager 3.90.1-es',0x0d
                    db  '  Copyright (C) 2001 Suzhe <su_zhe@sina.com>',0x0d,0x0d
                    db  ' Esto es software libre, puede redistribuirlo',0x0d
                    db  '   y/o modificarlo bajo los términos de la',0x0d
                    db  '   Licencia Pública General GNU versión 2.',0x0d,0x0d
                    db  '  Este programa no tiene NINGUNA GARANTIA!',0

; help infomation.
.help_content:
        db '      F1 = Ayuda                    Ctrl+F1 = Acerca de',0x0d
        db '      F2 = Guardar                       F3 = Nombre',0x0d
        db '      F4 = Marcar como activa            F5 = Ocultar/mostrar',0x0d
        db '      F6 = Cambiar auto activa           F7 = Cambiar auto ocultar',0x0d
        db '      F8 = Poner como predefinida  Shift+F8 = Quitar predefinida',0x0d
        db '  Ctrl+D = Borrar                    Ctrl+P = Duplicar',0x0d
        db '  Ctrl+U = Mover registro arriba     Ctrl+N = Mover registro abajo',0x0d
        db '  Ctrl+S = On/off Programada         Ctrl+T = Tiempo de espera',0x0d
        db '  Ctrl+K = On/off teclas guardadas   / or ? = Mostrar información',0x0d
        db '  Ctrl+I = Actualizar los registros  Ctrl+H = Actualizar las particiones',0x0d,
        db '  Ctrl+X = Cambiar id de la unidad   Ctrl+F = Mostrar/ocultar banderas',0x0d
        db '  Ctrl+L = Cambiar recordar el último registro iniciado',0x0d
        db '      F9 = Cambiar contraseña del registro de inicio',0x0d
        db '     F10 = Cambiar contraseña de administrador',0x0d
        db 'Ctrl+F10 = Entrar/dejar modo Administrador',0x0d
        db ' Alt+F10 = Enter/dejar modo Bloqueo de Seguridad',0x0d
        db '     Tab = Mostrar menú de comandos',0x0d
        db '  Ctrl+Q = Salir al BIOS              Ctrl+F12 = Apagar',0

; normal messages.
.changes_saved      db  'Cambios guardados.',0
.passwd_changed     db  'Contraseña cambiada.',0
.ask_save_changes   db  'Guardar los cambios (s/n)?',0

; error messages.
.wrong_passwd       db  'Contraseña errónea!',0
.disk_error         db  'Error de disco! 0x',0
.mark_act_failed    db  'Marcar activa falló!',0
.toggle_hid_failed  db  'Ocultar/mostrar falló!',0
.no_system          db  'Ningún Sistema Operativo!',0x0d
                    db  'Cambie el disco e intentelo de nuevo.',0
.invalid_record     db  'Registro de Inicio no válido!',0
.invalid_schedule   db  'Tiempo programado no válido!',0
.inst_confirm       db  'Confirmar instalar Smart BootManager ',
                    db  'en la unidad ',0
.inst_ok            db  'Instalación correcta!',0
.inst_abort         db  'Instalación cancelada.',0
.uninst_confirm     db  'Confirmar desinstalar Smart BootManager?',0x0d,0
.uninst_ok          db  'Desinstalación correcta!',0x0d
                    db  'El ordenador será reiniciado.',0
.uninst_abort       db  'Desinstalación cancelada.',0
.confirm            db  'Presione S para continuar, otra tecla para cancelar.',0
.no_sbml            db  'Falta el cargador de Smart Boot Manager',0x0d
                    db  'o es una versión errónea!',0
.invalid_ioports    db  'Puertos de E/S no válidos!',0

; command menu strings
; main menu
.main_menu_title     db  'Menú Principal',0
.main_menu_help      db  'Ayuda               ~F1~',0
.main_menu_about     db  'Acerca de      ~Ctrl-F1~',0
.main_menu_bootit    db  'Iniciar',0
.main_menu_bootprev  db  'Iniciar MBR previo',0
.main_menu_quit      db  'Salir           ~Ctrl-Q~',0
.main_menu_poweroff  db  'Apagar        ~Ctrl-F12~',0
.main_menu_recordset db  'Configurar Registro ->',0
.main_menu_sysset    db  'Configurar Sistema  ->',0
.main_menu_save      db  'Guardar cambios     ~F2~',0
.main_menu_bar       db  '----------------------',0

; record settings menu
.record_menu_title    db  'Prodiedades de Registro',0
.record_menu_info     db  'Información     ~/ or ?~',0
.record_menu_name     db  'Nombre              ~F3~',0
.record_menu_passwd   db  'Contraseña          ~F9~',0
.record_menu_schedule db  'Programar       ~Ctrl-S~',0
.record_menu_keys     db  'Teclas          ~Ctrl-K~',0
.record_menu_act      db  'Marcar Activa       ~F4~',0
.record_menu_hide     db  'Ocultar/mostrar     ~F5~',0
.record_menu_autoact  db  'Auto Activa         ~F6~',0
.record_menu_autohide db  'Auto Ocultar        ~F7~',0
.record_menu_swapdrv  db  'Cambiar unidad  ~Ctrl-X~',0
.record_menu_del      db  'Borrar          ~Ctrl-D~',0
.record_menu_dup      db  'Duplicar        ~Ctrl-P~',0
.record_menu_moveup   db  'Mover Arriba    ~Ctrl-U~',0
.record_menu_movedown db  'Mover Abajo     ~Ctrl-N~',0
.record_menu_bar      db  '----------------------',0

; system setting menu
.sys_menu_title       db  'Propiedades del Sistema',0
.sys_menu_rootpasswd  db  'Contraseña de Admin.          ~F10~',0
.sys_menu_admin       db  'Cambiar modo Admin.      ~Ctrl-F10~',0
.sys_menu_security    db  'Cambiar modo Seguro       ~Alt-F10~',0
.sys_menu_setdef      db  'Iniciar por defecto            ~F8~',0
.sys_menu_unsetdef    db  'Quitar "por defecto"     ~Shift-F8~',0
.sys_menu_delay       db  'Tiempo de Espera           ~Ctrl-T~',0
.sys_menu_bmstyle     db  'Cambiar Estilo del Menú    ~Ctrl-F~',0
.sys_menu_remlast     db  'Cambiar recordar última    ~Ctrl-L~',0
.sys_menu_int13ext    db  'Cambiar Int 13H Extendida',0
.sys_menu_rescanall   db  'Actualizar los registros   ~Ctrl-I~',0
.sys_menu_rescanpart  db  'Actualizar las particiones ~Ctrl-H~',0
.sys_menu_set_ioports db  'Puertos E/S del CD-ROM',0
.sys_menu_set_y2kfix  db  'Año actual (cor. bug del 2000)',0
.sys_menu_inst        db  'Instalar Smart BootManager',0
.sys_menu_uninst      db  'Desinstalar Smart BootManager',0
.sys_menu_bar         db  '-------------------------------',0

.cdimg_menu_title     db  'Escoger una imagen de CD',0
.cdimg_menu_noemu     db  'Sin Emulación',0
.cdimg_menu_120m      db  'Disco de 1.2 M',0
.cdimg_menu_144m      db  'Disco de 1.44M',0
.cdimg_menu_288m      db  'Disco de 2.88M',0

.sunday              db 'Dom',0
.monday              db 'Lun',0
.tuesday             db 'Mar',0
.wednesday           db 'Mié',0
.thursday            db 'Jue',0
.friday              db 'Vie',0
.saturday            db 'Sáb',0

; END OF THEME.
end_of_theme:

; vi:ts=8:et:nowrap
