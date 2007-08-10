;
; evtcode.h
;
; definiation of event codes
;
; Copyright (C) 2000, Suzhe. See file COPYING and CREDITS for details.
;

%define kbEsc                0x011B
%define kbAltEsc             0x0100

%define kbF1                 0x3B00
%define kbAltF1              0x6800
%define kbCtrlF1             0x5E00
%define kbShiftF1            0x5400

%define kbF2                 0x3C00
%define kbAltF2              0x6900
%define kbCtrlF2             0x5F00
%define kbShiftF2            0x5500

%define kbF3                 0x3D00
%define kbAltF3              0x6A00
%define kbCtrlF3             0x6000
%define kbShiftF3            0x5600

%define kbF4                 0x3E00
%define kbAltF4              0x6B00
%define kbCtrlF4             0x6100
%define kbShiftF4            0x5700

%define kbF5                 0x3F00
%define kbAltF5              0x6C00
%define kbCtrlF5             0x6200
%define kbShiftF5            0x5800

%define kbF6                 0x4000
%define kbAltF6              0x6D00
%define kbCtrlF6             0x6300
%define kbShiftF6            0x5900

%define kbF7                 0x4100
%define kbAltF7              0x6E00
%define kbCtrlF7             0x6400
%define kbShiftF7            0x5A00

%define kbF8                 0x4200
%define kbAltF8              0x6F00
%define kbCtrlF8             0x6500
%define kbShiftF8            0x5B00

%define kbF9                 0x4300
%define kbAltF9              0x7000
%define kbCtrlF9             0x6600
%define kbShiftF9            0x5C00

%define kbF10                0x4400
%define kbAltF10             0x7100
%define kbCtrlF10            0x6700
%define kbShiftF10           0x5D00

%define kbF11                0x8500
%define kbAltF11             0x8B00
%define kbCtrlF11            0x8900
%define kbShiftF11           0x8700

%define kbF12                0x8600
%define kbAltF12             0x8C00
%define kbCtrlF12            0x8A00
%define kbShiftF12           0x8800

%define kbTab                0x0F09
%define kbAltTab             0xA500
%define kbCtrlTab            0x9400
%define kbShiftTab           0x0F00

%define kbBack               0x0E08
%define kbAltBack            0x0E00
%define kbCtrlBack           0x0E7F

%define kbEnter              0x1C0D
%define kbAltEnter           0x1C00
%define kbCtrlEnter          0x1C0A
%define kbEnhEnter           0xE00D
%define kbEnhAltEnter        0xA600
%define kbEnhCtrlEnter       0xE00A

%define kbSpace              0x3920

%define kbIns                0x5200
%define kbEnhIns             0x52E0
%define kbCtrlIns            0x9200
%define kbEnhCtrlIns         0x92E0
%define kbEnhAltIns          0xA200

%define kbHome               0x4700
%define kbEnhHome            0x47E0
%define kbCtrlHome           0x7700
%define kbEnhCtrlHome        0x77E0
%define kbEnhAltHome         0x9700

%define kbPgUp               0x4900
%define kbEnhPgUp            0x49E0
%define kbCtrlPgUp           0x8400
%define kbEnhCtrlPgUp        0x84E0
%define kbEnhAltPgUp         0x9900

%define kbEnd                0x4F00
%define kbEnhEnd             0x4FE0
%define kbCtrlEnd            0x7500
%define kbEnhCtrlEnd         0x75E0
%define kbEnhAltEnd          0x9F00

%define kbDel                0x5300
%define kbEnhDel             0x53E0
%define kbCtrlDel            0x9300
%define kbEnhCtrlDel         0x93E0
%define kbEnhAltDel          0xA300

%define kbPgDn               0x5100
%define kbEnhPgDn            0x51E0
%define kbCtrlPgDn           0x7600
%define kbEnhCtrlPgDn        0x76E0
%define kbEnhAltPgDn         0xA100

%define kbUp                 0x4800
%define kbCtrlUp             0x8D00
%define kbEnhUp              0x48E0
%define kbEnhAltUp           0x9800
%define kbEnhCtrlUp          0x8DE0

%define kbDown               0x5000
%define kbCtrlDown           0x9100
%define kbEnhDown            0x50E0
%define kbEnhAltDown         0xA000
%define kbEnhCtrlDown        0x91E0

%define kbLeft               0x4b00
%define kbCtrlLeft           0x7300
%define kbEnhLeft            0x4BE0
%define kbEnhAltLeft         0x9B00
%define kbEnhCtrlLeft        0x73E0

%define kbRight              0x4d00
%define kbCtrlRight          0x7400
%define kbEnhRight           0x4DE0
%define kbEnhAltRight        0x9D00
%define kbEnhCtrlRight       0x74E0

%define kbGraySlash          0xE02F
%define kbGrayStar           0x372A
%define kbGrayMinus          0x4A2D
%define kbGrayPlus           0x4E2B

%define kbCtrlQ              0x1011
%define kbCtrlW              0x1117
%define kbCtrlE              0x1205
%define kbCtrlR              0x1312
%define kbCtrlT              0x1414
%define kbCtrlY              0x1519
%define kbCtrlU              0x1615
%define kbCtrlI              0x1709
%define kbCtrlO              0x180F
%define kbCtrlP              0x1910
%define kbCtrlA              0x1E01
%define kbCtrlS              0x1f13
%define kbCtrlD              0x2004
%define kbCtrlF              0x2106
%define kbCtrlG              0x2207
%define kbCtrlH              0x2308
%define kbCtrlJ              0x240A
%define kbCtrlK              0x250b
%define kbCtrlL              0x260C
%define kbCtrlZ              0x2C1A
%define kbCtrlX              0x2D18
%define kbCtrlC              0x2E03
%define kbCtrlV              0x2F16
%define kbCtrlB              0x3002
%define kbCtrlN              0x310E
%define kbCtrlM              0x320D

%define kbLowerY             0x1579
%define kbUpperY             0x1559

%define kbSlash              0x352F
%define kbQuestion           0x353F

%define kbAltS               0x1F00
%define kbAltR               0x1300

%define kbOne                0x0231

%define kbRightShiftMask     0x01
%define kbLeftShiftMask      0x02
%define kbShiftMask          0x03
%define kbCtrlMask           0x04
%define kbAltMask            0x08
%define kbScrollMask         0x10
%define kbNumLockMask        0x20
%define kbCapsLockMask       0x40
%define kbInsertMask         0x80

%define kbStateKeysMask   (kbScrollMask | kbNumLockMask | kbCapsLockMask | kbInsertMask)

%define EVTCODE_COMMAND		0xF0
%define EVTCODE_KEYPRESS        0x01
%define EVTCODE_KEYRELEASE      0x02
%define EVTCODE_BROADCAST	0x04

; Broadcast events
%define EVENT_REDRAW_ROOT  ((EVTCODE_COMMAND | EVTCODE_BROADCAST) << 8 | 0x0001)
%define EVENT_BOOT_DEFAULT ((EVTCODE_COMMAND | EVTCODE_BROADCAST) << 8 | 0x0002)

; Normal events
%define EVENT_TOGGLE_MENU  ((EVTCODE_COMMAND ) << 8 | 0x0001)

; Key press event
%define EVENT_RIGHTSHIFT_PRESS    ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbRightShiftMask)
%define EVENT_LEFTSHIFT_PRESS     ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbLeftShiftMask)
%define EVENT_SHIFT_PRESS         ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbShiftMask)
%define EVENT_CTRL_PRESS          ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbCtrlMask)
%define EVENT_ALT_PRESS           ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbAltMask)
%define EVENT_SCROLL_ON           ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbScrollMask)
%define EVENT_NUMLOCK_ON          ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbNumLockMask)
%define EVENT_CAPSLOCK_ON         ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbCapsLockMask)
%define EVENT_INSERT_ON           ((EVTCODE_COMMAND | EVTCODE_KEYPRESS) << 8 | kbInsertMask)

%define EVENT_RIGHTSHIFT_RELEASE  ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbRightShiftMask)
%define EVENT_LEFTSHIFT_RELEASE   ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbLeftShiftMask)
%define EVENT_SHIFT_RELEASE       ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbShiftMask)
%define EVENT_CTRL_RELEASE        ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbCtrlMask)
%define EVENT_ALT_RELEASE         ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbAltMask)
%define EVENT_SCROLL_OFF          ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbScrollMask)
%define EVENT_NUMLOCK_OFF         ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbNumLockMask)
%define EVENT_CAPSLOCK_OFF        ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbCapsLockMask)
%define EVENT_INSERT_OFF          ((EVTCODE_COMMAND | EVTCODE_KEYRELEASE) << 8 | kbInsertMask)


