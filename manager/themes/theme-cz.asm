; asmsyntax=nasm
;
; theme-cz.asm
;
; Czech theme data for Smart Boot Manager
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
; Original: Copyright (C) 2000, Suzhe. See file COPYING for details.
; Czech Translation: brz, brz@post.cz
; Prosim o Vase pripominky a navrhy, diky. |||  mailto:brz@post.cz
; -----------------------------------------------------------------
;

; KONSTANTY POUZITE V TOMTO cz-TEMATU

; PROSIM NEMENTE NASLEDUJICI RADKY, NEVITE-LI PRESNE K CEMU JSOU!
; (A TO ASI PLATI VZDYCKY :)

%define SBMT_MAGIC      0x544D4253         ; magicke cisko cz-tematu
                                           ; Smart Boot Manageru.
%define SBMT_VERSION    0x035A             ; verze theme (3.90).

start_font          equ     219
brand_char1         equ     start_font
brand_char2         equ     start_font+1
brand_char3         equ     start_font+2
brand_char4         equ     start_font+3

        bits 16

%ifndef MAIN
        org 0                       ; NEMAZTE ANI NEMENTE TENTO RADEK!!!
%endif

start_of_theme:

;!!! PROSIM, NEMENTE HODNOTY ANI PORADI NASLEDUJICICH DAT !!!

;=============================================================================
;hlavicky cz-tematu Smart Boot Manager ( 16 bytes )
;=============================================================================
theme_magic         dd  SBMT_MAGIC ; magicke cislo = 'SBMT', 4 byty.
                                   ; toto je zkratka 'Smart Boot Manager Theme'
                    dw  0          ;
theme_lang          db  'cs-CZ',0  ; jazyk tohoto schematu, 6 bytu.
theme_version       dw  SBMT_VERSION ; verze, high byte je cislo hlavni verze,
                                   ; low byte je cislo podverze. muze byt
                                   ; (a asi i bude) rovne verzi Smart Boot Manageru.
theme_size          dw  (end_of_theme - start_of_theme)
                                   ; velikost cz-tematu (v bytech).

;=============================================================================
; konstatni promenne a tabulka promennych
;=============================================================================

video_mode          db  0xff       ; 0 = 90x25, 0xff = 80x25
                                   ; nepouzivejte jine hodnoty!!!


keyboard_type       db 0x10        ; = 0x10 znamena pouziti rozsirene klavesnice
                                   ; = 0x00 znamena pouziti normalni klavesnice
                                   ; OPATRNE: jine hodnoty nemohou byt pouzity!!!

show_date_method    db  1          ; formaty zobrazeni data:
                                   ; 0 = nezobrazuj datum
                                   ; 1 = den mm-dd-yyyy
                                   ; 2 = den yyyy-mm-dd
                                   ; 3 = den dd-mm-yyyy

show_time_method    db  1          ; format zobrazeni casu:
                                   ; 0 = nezobrazuj cas
                                   ; 1 = hh:mm (24 hodin)
yes_key_lower       db  'y'        ;anoklavesa 'y'
yes_key_upper       db  'Y'        ;anoklavesa 'Y'
 
; pozice prvku na obrazovce
position:
.brand                  dw  0x00FF      ; pocatek sloupce znacek ikon
                                        ; jestlize je = 255 tak potom bude znacka
                                        ; zarovnana na pravy okraj obrazovky.
                                        ; pocatek radku znacek ikon

.date                   dw  0x0037

.time                   dw  0x0046

; velikost prvku na obrazovce
size:
.copyright              db  1           ; pocet radku pouzitych na copyright info
.hint                   db  1           ; pocet radku pouzitych na tip info
.box_width              db  5           ; minimalni sirka info/error/input panelu
                                        ; (pokud neni zobrazeno info)
.box_height             db  4           ; minimalni vyska info/error/input panelu
                                        ; (pokud neni zobrazeno info)
.boot_menu_win_height   db  13          ; vyska hlavniho okna
.list_box_win_height    db  10

;Cerna               = 0
;Modra               = 1
;Zelena              = 2
;Modrozelena         = 3
;Cervena             = 4
;Fialova             = 5
;Zluta (Hneda)       = 6
;Bila                = 7
;Cerna (Seda)        = 8
;Vyrazne modra       = 9
;Vyrazne zelena      = a
;Vyrazne modrozelena = b
;Vyrazne cervena     = c
;Vyrazne fialova     = d
;Vyrazne zluta       = e
;Vyrazne bila        = f

; barvy prvku na obrazovce
; high 4 bity je barva pozadi, low 4 bity je barva prvku

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
.brand_size         dw  0x0104              ; velikost znacek ikon,
                                            ; hhigh byte = radek, low byte = sloupec
.brand              dw  icon_data.brand     ; offsetova data znacek ikon, nastavena na nulu
                                            ; pokud neni znacka ikony.

.background_size    dw  0x0104              ; velikost ikony na pozadi,
                                            ; high byte = radek, low byte = sloupec.
.background         dw  icon_data.background; offsetova data ikon na pozadi,
                                            ; pokud neni ikona na pozadi.

; font data
font:
.number             dw  (font_data.end-font_data)/17
                                            ; pocet znaku k premisteni pri nahrade fontu,
                                            ; <= (256 - start).
.data               dw  font_data           ; offset dat fontu, je nastaveno
                                            ; na nulu pokud fond nebude nahrazovan.


; znaky pouzite pro ramy oken
frame_char:
.top                db     0x20            ; vodorovne nahore
.bottom             db     0xCD            ; vodorovne dole
.left               db     0xBA            ; svisle vlevo
.right              db     0xBA            ; svisle vpravo
.tl_corner          db     0xC9            ; levy horni roh
.tr_corner          db     0xBB            ; pravy horni roh
.bl_corner          db     0xC8            ; levy dolni roh
.br_corner          db     0xBC            ; pravy dolni roh

; how to draw window frame
draw_frame_method   db  1          ; = 0 vykresli vsechny ramy dle atributu ramecku
                                   ; = 1 vykresli vodorovne horni ramy dle atributu ramecku
                                   ; = 2 vykresli vodorovne horni ramy a horni rohy dle atributu titulu


; data namapovani klavesnice
keymap:                                  ; klavesove vstupy
.number             dw  (keymap_data.end-keymap_data)/4
                                           ; pocet klavesovych vstupu
.data               dw  keymap_data      ; pointer mapovani klaves

; index tabulka retezcu
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

; prikazove menu str_idx
; hlavni menu
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

; Nemu nastaveni zaznamu
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

; Menu systemovych nastaveni
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
; promenne
;=============================================================================

; data ikon

; dva byty odpovidaji znaku,
; high byte je barva, low byte je kod znaku.
icon_data:
.brand:
db  brand_char1, 0x7C, brand_char2, 0x7C, brand_char3, 0x7C, brand_char4, 0x7C

.background:
db  0xB0, 0x71, 0xB0, 0x71, 0xB0, 0x71, 0xB0, 0x71

; data fontu
; kazdy znak predstavuje 17 bytu
; prvni byt je ascii kod daneho znaku
; nasledujicich 16 znaku vyjadruje data fontu
;
; POZNAMKA:
;   Nezamenujte ascii znaky 0 a 0x0d, 0x1e a 0x1f,
;   tyto znaky maji specialni vyznam.
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

; mapovani klavesnice
; kazdy vstup ma dve slova, prvni je originalni kod klavesy,
; druhy je novy klavesovy kod.
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

; retezce
; vsechny retezce jsou zakonceny nulou,
; pouzijte znak 0x0d k zalomeni dlouheho radku
string:
; pouzito v hlavnim okne a boot menu
.boot_menu_title                db  'Boot Menu',0
.boot_menu_header               db  '     Flagy  '
.boot_menu_header_noflags       db  '  Cislo '
.boot_menu_header_nonumber      db  '  Typ    '
.boot_menu_header_notype        db  '  Jmeno',0

; titulky oken.
.about              db  'O Aplikaci',0
.error              db  'Chyba',0
.help               db  'Napoveda',0
.info               db  'Infomace',0
.input              db  'Vstup',0

; pouzito v zadavacich panelech.
.delay_time         db  'Cas prodlevy: ',0
.name               db  'Jmeno: ',0
.new_root_passwd    db  'Nove heslo '
.root_passwd        db  'Rootovo heslo: ',0
.new_record_passwd  db  'Novy zaznam '
.record_passwd      db  'Heslo zaznamu: ',0
.retype_passwd      db  'Znovuvyklofej heslo: ',0
.input_schedule     db  'Planovac (hh:mm-hh:mm;dny): ',0
.input_keystrokes   db  'Zadej predavane uhozy (max 13 klaves)',0x0d
                    db  'Stiskni <Scroll Lock> k ukonceni,',0x0d
                    db  'Kod klavesy = 0x',0
.key_count          db  0x0d,'Pocet klaves = ',0
.io_port            db  'I/O Zakladni porty (hex1,hex2): ',0
.year               db  'Rok: ',0

; pouzito v zadavacich panelech.
.drive_id           db       '       ID disku: ',0
.part_id            db  '  Cast ID: ',0
.record_type        db  0x0d,'    Typ zaznamu: ',0
.record_name        db  0x0d,'  Jmeno zaznamu: ',0

.auto_active        db  0x0d,0x0d,'   Auto Aktivni: ',0
.active             db  '  Aktivni: ',0
.auto_hide          db  0x0d,'     Auto Skryt: ',0
.hidden             db  '   Skryty: ',0
.swap_drv           db  0x0d,' Prohodit disky: ',0
.logical            db  '  Logicky: ',0
.key_strokes        db  0x0d,0x0d,'Klavesove uhozy: ',0
.password           db  '    Heslo: ',0
.schedule           db  0x0d,'       Planovac: ',0

.yes                db  'Ano',0
.no                 db  'Ne ',0

; copyright informace, zobrazeny na obrazovce nahore.
.copyright          db  ' Smart Boot Manager 3.90.1 | Copyright (C) 2001 Suzhe',0

; tipy, zobrazeny na obrozovce dole.
.hint               db  '~F1~-Napoveda ~F2~-Uloz ~F3~-Prejmenuj ~F4~-Aktivni ~F5~-Skryj ~Tab~-Menu',0

; infomace o aplikaci
.about_content      db  '           Smart Boot Manager 3.90.1-cz',0x0d
                    db  '  Copyright (C) 2001 Suzhe <su_zhe@sina.com>',0x0d,0x0d
                    db  ' Tento program je free software, muzete ho sirit dal',0x0d
                    db  '  a/nebo ho modifikovat, podle podminek uvedenych',0x0d
                    db  '    v GNU General Public License version 2.',0x0d,0x0d
                    db  'Uziti tohoto programu je ABSOLUTNE NA VLASTNI RIZIKO!',0

; help infomation.
.help_content:
        db '      F1 = Napoveda              Ctrl+F1 = O aplikaci',0x0d
        db '      F2 = Uloz                       F3 = Prejmenuj',0x0d
        db '      F4 = Nastav Aktivni             F5 = Skryj/Zobraz',0x0d
        db '      F6 = Nastav/Zrus AutoAktivni    F7 = Nastav/Zrus AutoSkryj',0x0d
        db '      F8 = Nastav Defaultni     Shift+F8 = Zrus Defaultni',0x0d
        db '  Ctrl+D = Vymaz                  Ctrl+P = Zduplikuj',0x0d
        db '  Ctrl+U = Posun zaznam nahoru    Ctrl+N = Posun zaznam dolu',0x0d
        db '  Ctrl+S = Nastav/Zrus Planovac   Ctrl+T = Nastav cas prodlevy',0x0d
        db '  Ctrl+K = Nastav/zrus uhozy klaves    ? = Zobraz informace',0x0d
        db '  Ctrl+X = Prohod ID disku        Ctrl+F = Ukaz/Skryj flagy',0x0d
        db '  Ctrl+I = Prohledej vsechny zaznamy',0x0d
        db '  Ctrl+H = Prohledej vsechny partitisny',0x0d,
        db '  Ctrl+L = Vypni/Zapni zapamatovani posledniho bootovaciho zaznamu',0x0d
        db '      F9 = Zmen heslo bootovaciho zaznamu',0x0d
        db '     F10 = Zmen rootovo heslo',0x0d
        db 'Ctrl+F10 = Spust/Zrus Administratorsky mod',0x0d
        db ' Alt+F10 = Spust/Zrus Bezpecny mod',0x0d
        db '     Tab = Popup prikazove menu',0x0d
        db '  Ctrl+Q = Quit do BIOS         Ctrl+F12 = Vypni pocitac',0

; normalni hlasky.
.changes_saved      db  'Zmeny ulozeny.',0
.passwd_changed     db  'Heslo zmeneno.',0
.ask_save_changes   db  'Ulozit zmeny (y/n)?',0

; chybove hlasky.
.wrong_passwd       db  'Spatne heslo!',0
.disk_error         db  'Chyba disku! 0x',0
.mark_act_failed    db  'Selhalo oznaceni Aktivni!',0
.toggle_hid_failed  db  'Skryj/Zobraz selhalo!',0
.no_system          db  'Nenalezen Operacni System!',0x0d
                    db  'Vymente disk a zkuste to znovu.',0
.invalid_record     db  'Chybny bootovaci zaznam!',0
.invalid_schedule   db  'Planovac: Chybny cas!',0
.inst_confirm       db  'Chcete instalovat Smart BootManager ',
                    db  'na disk ',0
.inst_ok            db  'instalece byla uspesna!',0
.inst_abort         db  'Zruseni instalace.',0
.uninst_confirm     db  'Chcete deinstalovat Smart BootManager?',0x0d,0
.uninst_ok          db  'Deinstalace byla uspesne provedena!',0x0d
                    db  'Pocitac se bude restartovat.',0
.uninst_abort       db  'Zruseni Deinstalace.',0
.confirm            db  'Stisknete Y pro pokracovani, jinou klavesu pro zruseni.',0
.no_sbml            db  'Smart Boot Manager Loader chybi ',0x0d
                    db  'nebo zmatek verzi!',0
.invalid_ioports    db  'Chyba na I/O Portu!',0


; polozky prikazoveho menu
; main menu
.main_menu_title     db  'Hlavni Menu',0
.main_menu_help      db  'Napoveda            ~F1~',0
.main_menu_about     db  'O aplikaci     ~Ctrl-F1~',0
.main_menu_bootit    db  'Nabbotuj',0
.main_menu_bootprev  db  'Nabootuj orig MBR',0
.main_menu_quit      db  'Quit            ~Ctrl-Q~',0
.main_menu_poweroff  db  'Vypni pocitac ~Ctrl-F12~',0
.main_menu_recordset db  'Nastaveni Zaznamu   ->',0
.main_menu_sysset    db  'Systemova Nastaveni ->',0
.main_menu_save      db  'Uloz Zmeny          ~F2~',0
.main_menu_bar       db  '----------------------',0

; polozky menu zaznamu
.record_menu_title    db  'Nastaveni Zaznamu',0
.record_menu_info     db  'Informace        ~/ or ?~',0
.record_menu_name     db  'Jmeno                ~F3~',0
.record_menu_passwd   db  'Heslo                ~F9~',0
.record_menu_schedule db  'Planovac         ~Ctrl-S~',0
.record_menu_keys     db  'Klavesove Uhozy  ~Ctrl-K~',0
.record_menu_act      db  'Oznac Aktivni        ~F4~',0
.record_menu_hide     db  'Skryj/Zobraz         ~F5~',0
.record_menu_autoact  db  'Auto Aktivni         ~F6~',0
.record_menu_autohide db  'Auto Skryj           ~F7~',0
.record_menu_swapdrv  db  'Prohod ID disku  ~Ctrl-X~',0
.record_menu_del      db  'Vymaz            ~Ctrl-D~',0
.record_menu_dup      db  'Zduplikuj        ~Ctrl-P~',0
.record_menu_moveup   db  'Posun Nahoru     ~Ctrl-U~',0
.record_menu_movedown db  'Posun Dolu       ~Ctrl-N~',0
.record_menu_bar      db  '-----------------------',0

; polozky menu systemovych nastaveni
.sys_menu_title       db  'Systemova Nastaveni',0
.sys_menu_rootpasswd  db  'Rootovo heslo                          ~F10~',0
.sys_menu_admin       db  'Spust/Zrus Admin mod              ~Ctrl-F10~',0
.sys_menu_security    db  'Spust/Zrus Bezpec mod              ~Alt-F10~',0
.sys_menu_setdef      db  'Nastav Defaultni Zaznam                 ~F8~',0
.sys_menu_unsetdef    db  'Zrus Defaultni Zaznam             ~Shift-F8~',0
.sys_menu_delay       db  'Nastav Cas Prodlevy                 ~Ctrl-T~',0

.sys_menu_bmstyle     db  'Zmen Styl Boot Menu                 ~Ctrl-F~',0

.sys_menu_remlast     db  'Prohod Zapamatuj boot               ~Ctrl-L~',0
.sys_menu_int13ext    db  'Prohod Extended Int 13H',0
.sys_menu_rescanall   db  'ZnovuProhledej vsechny Boot zaznamy ~Ctrl-I~',0
.sys_menu_rescanpart  db  'ZnovuProhledej vsechny partitisny   ~Ctrl-H~',0
.sys_menu_set_ioports db  'Nastav I/O Porty CD-ROM',0
.sys_menu_set_y2kfix  db  'Nastav rok (eliminace chyby Y2K BIOSu)',0

.sys_menu_inst        db  'Instaluj Smart BootManager',0
.sys_menu_uninst      db  'Deninstaluj Smart BootManager',0
.sys_menu_bar         db  '------------------------------------------',0

.cdimg_menu_title     db  'Vyber Image CD', 0
.cdimg_menu_noemu     db  'Bez Emulace',0
.cdimg_menu_120m      db  '1.2 M Disketa',0
.cdimg_menu_144m      db  '1.44M Disketa',0
.cdimg_menu_288m      db  '2.88M Disketa',0

.sunday              db 'Ned',0
.monday              db 'Pon',0
.tuesday             db 'Utr',0
.wednesday           db 'Str',0
.thursday            db 'Ctv',0
.friday              db 'Pat',0
.saturday            db 'Sob',0


; END OF THEME.
end_of_theme:

; vi:ts=8:et:nowrap
