; asmsyntax=nasm
;
; knl.asm
;
; kernel functions for partition list
;
; Copyright (C) 2000, Suzhe. See file COPYING for details.
;

%define LIMIT_FLOPPY_NUMBER

%define NUM_OF_ID       (part_type.str_tbl - part_type.id_tbl)
%define NUM_OF_LOG_DENY (part_type.auto_act_tbl - part_type.log_deny_tbl)
%define NUM_OF_PRI_DENY (part_type.auto_act_tbl - part_type.pri_deny_tbl)
%define NUM_OF_AUTO_ACT (part_type.hidden_tbl - part_type.auto_act_tbl)
%define NUM_OF_HIDDEN   (part_type.end_of_tbl - part_type.hidden_tbl)
%define NUM_OF_ALLOW_HIDE (part_type.hidden_tbl - part_type.allow_hide_tbl)

;%define NUM_OF_EXT      (part_type.log_deny_tbl - part_type.ext_tbl)

%define MAX_FLOPPY_NUM  2

;==============================================================================
;fill_bootrecord ---- fill the boot record for a partition
;input:
;      ebx   =  father's abs LBA address
;      dh    =  partition id
;      dl    =  drive id
;      ds:si -> source partition record
;      es:di -> buffer to store the boot record
;output:
;      es:di -> filled with boot record
;==============================================================================
fill_bootrecord:
        pushad
        cld

        push di                                  ; clear the boot record
        xor al, al                               ;
        mov cx, SIZE_OF_BOOTRECORD               ;
        rep stosb                                ;
        pop di                                   ;
        
        mov [di + struc_bootrecord.drive_id], dx ; fill the drive_id and
                                                 ; part_id
        mov ecx, ebx
        mov [di + struc_bootrecord.father_abs_addr], ecx

        mov bh, [si + struc_partition.type]

        call get_drive_flags

        and ax, DRVFLAG_MASK                     ; set flags
        
        or dh, dh                                ; check if it's a driver record
        jnz .is_partition
        or ax, INFOFLAG_ISDRIVER
        xor bh, bh
        jmp short .set_other_flags

.is_partition:
        or ecx,ecx                               ;
        jz .not_logical                          ;
        or ax, INFOFLAG_LOGICAL                  ;
        
.not_logical:
        cmp dl, [si + struc_partition.state]     ; test if it's active
                                                 ; should changed to
                                                 ; cmp 0x80, [xxx] ? 
        jne .set_other_flags
        or ax, INFOFLAG_ACTIVE

.set_other_flags:

        push cx                                  ;
        push di                                  ;

        test ax, INFOFLAG_ISDRIVER
        jnz .not_hidden                          ;

        test ax, INFOFLAG_LOGICAL                ; ah = record flags
        jnz .not_auto_act                        ;

        push ax                                  ; check if it should
        lea di, [part_type.auto_act_tbl]         ; be marked as
        mov cx, NUM_OF_AUTO_ACT                  ; auto active.
        mov al, bh
        call strchr                              ;
        pop ax                                   ;
        jc .not_auto_act                         ;

        or ax, INFOFLAG_AUTOACTIVE
        
.not_auto_act:                                   ;
        push ax                                  ; check if it's a
        lea di, [part_type.hidden_tbl]           ; hidden partition.
        mov cx, NUM_OF_HIDDEN                    ;
        mov al, bh
        call strchr                              ;
        pop ax                                   ;
        jc .not_hidden                           ;

        or ax, INFOFLAG_HIDDEN                   ; set the hidden flag
        and bh, 0x0F                             ; clear the hidden signature
        
.not_hidden:
        pop di
        pop cx

        mov [di + struc_bootrecord.flags], ax    ; fill the flags and type
        mov [di + struc_bootrecord.type], bh

        test ax, INFOFLAG_ISDRIVER
        jnz .no_abs_addr                         ; if it's floppy, abs_addr = 0
        
        mov ebx, [si + struc_partition.relative_addr]    ;

        add ecx, ebx                                     ; ecx = abs_address
        
.no_abs_addr:
        mov [di + struc_bootrecord.abs_addr], ecx

        test ax, INFOFLAG_ISDRIVER
        jnz .isdriver

        test ax, INFOFLAG_LOGICAL
        jz .primary
        lea si, [knl_strings.logical]               ; it's logical partition
        jmp short .fill_name                              ;
.primary:
        lea si, [knl_strings.primary]               ; it's primary partition
        jmp short .fill_name

.isdriver:
        cmp dl, MIN_HD_ID
        jb .floppy

        test ax, DRVFLAG_REMOVABLE
        jz .harddisk

	test ax, DRVFLAG_ISCDROM
	jz .removable

	lea si, [knl_strings.cdrom]
	jmp short .fill_name

.removable:
        lea si, [knl_strings.removable]
        jmp short .fill_name

.harddisk:
        lea si, [knl_strings.harddisk]              ; it's hard drive
        jmp short .fill_name

.floppy:
        lea si, [knl_strings.floppy]                ; it's floppy drive

.fill_name:
        add di, struc_bootrecord.name
        mov cx, 15
        call strncpy

        test ax, INFOFLAG_ISDRIVER
        jnz .end

        mov al, dh                                  ; append partition id
        xor ah, ah                                  ; at the end of the
        mov cl, 3                                   ; name
        call itoa                                   ;

.end:
        popad
        ret

;==============================================================================
;fill_special_record ---- fill the boot record for a special command
;input:
;      al = command id
;      es:di -> buffer to store the boot record
;output:
;      es:di -> filled with boot record
;==============================================================================
fill_special_record:
	pusha
        cld

	push ax
        push di                                  ; clear the boot record
        xor al, al                               ;
        mov cx, SIZE_OF_BOOTRECORD               ;
        rep stosb                                ;
        pop di                                   ;
	pop ax

	or word [di + struc_bootrecord.flags], INFOFLAG_ISSPECIAL
	mov byte [di + struc_bootrecord.type], al
	add di, struc_bootrecord.name

	xor si, si

	cmp al, SPREC_POWEROFF
	jne .not_poweroff
	mov si, knl_strings.poweroff

.not_poweroff:
	cmp al, SPREC_RESTART
	jne .not_restart
	mov si, knl_strings.restart

.not_restart:
	cmp al, SPREC_QUIT
	jne .not_quit
	mov si, knl_strings.quit

.not_quit:
	cmp al, SPREC_BOOTPREV
	jne .not_bootprev
	mov si, knl_strings.bootprev

.not_bootprev:
	mov cx, 15
	call strncpy
	popa
	ret

;==============================================================================
;get_parttype_str ---- get partition type string
;input:
;      al = partition type
;output:
;      ds:si -> partition type string
;==============================================================================
get_parttype_str:
        push di
        push cx
        lea di, [part_type.id_tbl]
        mov cx, NUM_OF_ID
        call strchr
        shl cx, 3                   ; cx = cx * 8
        lea si, [part_type.str_tbl]
        add si, cx
        pop cx
        pop di
        ret

;==============================================================================
;check_bootrecord ---- check if the boot record is ok
;input:
;      ds:si -> boot record
;output:
;      cf = 0 the boot record is ok
;      cf = 1 the boot record cannot boot
;==============================================================================
check_bootrecord:
        pushad                           ; save registers
	or si, si
	jmpz .bad_record

        cld

;============= check special record ===========
        mov ax, [si + struc_bootrecord.flags]        ; get record flags
	test ax, INFOFLAG_ISSPECIAL
	jmpz .normal_record

	mov bl, [si + struc_bootrecord.type]
	cmp bl, NUM_OF_SPREC
	jmpnb .bad_record

	cmp bl, SPREC_POWEROFF
	jmpne .check_prev

	call check_apm_bios
	jmp .end

.check_prev:
	cmp bl, SPREC_BOOTPREV
	jmpne .good_record

	call check_prev_mbr
	jmp .end

.normal_record:
;============= check driver ===================
        mov dx, [si + struc_bootrecord.drive_id]     ; get drive id and part id
        lea di, [hdio_tmp.driveinfo]
        call get_drive_info                          ; check if the drive ok
        jmpc .bad_record

        push ax
        mov ah, [di + struc_driveinfo.flags]         ;
        and ax, ( DRVFLAG_MASK << 8) | DRVFLAG_MASK  ; check if the flags was
        cmp al, ah                                   ; changed
        pop ax                                       ;
        jmpne .bad_record

        test ax, INFOFLAG_ISDRIVER                   ; if it's a driver then ok
        jmpnz .good_record

;============ check partition =================
; now we know it's a partiton!
        mov bl, [si + struc_bootrecord.type]
        or bl, bl                                    
        jmpz .bad_record                               ; it's free, bad!

.not_free:
        test ax, INFOFLAG_LOGICAL                    ; it's logical partition
        jnz .logical_part                            ;

        mov cx, NUM_OF_PRI_DENY                      ;
        lea di, [part_type.pri_deny_tbl]             ;
        jmp short .check_type                        ; check if the partition

.logical_part:                                       ; type is in the deny
        mov cx, NUM_OF_LOG_DENY                      ; table
        lea di, [part_type.log_deny_tbl]             ;

.check_type:                                         ;
        push ax
        mov al, bl                                   ; al = partition type
        call strchr                                  ;
        pop ax
        jmpnc .bad_record                              ; this type is denied!

;================ check in father ===================        
; read father's partition table into buffer and check it
        push ax                                      ; save flags

        mov ebx, [si + struc_bootrecord.father_abs_addr]

        mov ax, (INT13H_READ << 8 ) | 0x01           ; read the first sector
        lea di, [knl_tmp.disk_buf1]                           ; into buffer
        call disk_access                             ;
        pop ax                                       ; load flags
        jmpc .bad_record

        cmp word [di + 510], 0AA55h    ; check if the father is
        jne .bad_record                              ; good

        mov ecx, [si + struc_bootrecord.abs_addr]    ; get partition's abs addr
        sub ecx, ebx                                 ; calculate relative address
	mov ebx, ecx

        add di, 1BEh                         ; point to father's partition
                                                     ; table
        mov cx, 4
        
.search_in_father:                                   ; find the record in
	cmp byte [di + struc_partition.type], 0      ;
	je .invalid_entry
        cmp [di + struc_partition.relative_addr], ebx; father's partition
        je .found_it     
.invalid_entry:                                      ; table
        add di, SIZE_OF_PARTITION                    ;
        loop .search_in_father                       ;
        jmp .bad_record                        ; not found! it's bad.
        
.found_it:

;adjust some flags of the boot record.
;there is no other place to suit these codes,
;so I place them here :-(

        push ax                                      ;
        push di                                      ; hidden partition
        mov bl, [di + struc_partition.type]          ; check if it's a
        mov al, bl                                   ;
        lea di, [part_type.hidden_tbl]               ;
        mov cx, NUM_OF_HIDDEN                        ;
        call strchr                                  ;
        pop di                                       ;
        pop ax                                       ;
        jc .not_hidden                               ;
        and bl, 0x0F
        or ax, INFOFLAG_HIDDEN                       ; set hidden flag.
        jmp short .validate_type

.not_hidden:
        and ax, ~ INFOFLAG_HIDDEN                    ; clear hidden flag.

.validate_type:

%ifdef STRICT_PART_CHECK
        cmp bl, [si + struc_bootrecord.type]         ; check the partition type
        jne .bad_record                              ; wrong type!
%else
	mov [si + struc_bootrecord.type], bl         ; set partition type
%endif

.type_ok:
        push dx
        test ax, INFOFLAG_SWAPDRVID                  ; check if swap driver id
        jz .no_swapid
        and dl, 0x80

.no_swapid:
        cmp dl, [di + struc_partition.state]         ; check if the partition
        pop dx
        jne .not_active                              ; is active.
        or ax, INFOFLAG_ACTIVE                       ; should change to
        jmp short .adjust_flags                      ; cmp 0x80, byte [state] ?

.not_active:
        and ax, ~ INFOFLAG_ACTIVE

.adjust_flags:
        mov [si + struc_bootrecord.flags], ax

;==================  check partition itself ==============
.check_inside:                                       ; check partition itself

%ifdef STRICT_PART_CHECK
        mov ebx, [si + struc_bootrecord.abs_addr]

        lea di, [knl_tmp.disk_buf1]
        mov ax, (INT13H_READ << 8 ) | 0x01           ; read the first sector
        call disk_access                             ; into buffer
        jc .bad_record                               ; read error!
        
        cmp word [di + 510], 0AA55h    ; check if the paritition
        jne .bad_record                              ; is good
%endif

.good_record:
        clc
        jmp short .end

.bad_record:
        stc
.end:
        popad
        ret

;==============================================================================
;search_drv_records ---- search all driver records 
;input:
;      dl = beginning driver id.
;      cl = max number of boot records could be searched
;      es:di -> buffer to store boot records. 
;output:
;      ch = number of the valid boot records have searched
;==============================================================================
search_drv_records:
       xor ch, ch
       mov [knl_tmp.good_record_num], ch
       mov [knl_tmp.max_record_num], cl
       mov [knl_tmp.floppy_num], ch
       or cl, cl 
       jnz .can_search_more
       ret

.can_search_more:
       pusha
       xor ebx, ebx
       xor dh, dh

.loop_search:
       call get_drive_flags
       jc .search_next

       test al, DRVFLAG_DRIVEOK
       jc .search_next

%ifdef LIMIT_FLOPPY_NUMBER
       cmp dl, MIN_HD_ID
       jae .isharddisk
       test al, DRVFLAG_REMOVABLE
       jz .isharddisk

       inc byte [knl_tmp.floppy_num]
       cmp byte [knl_tmp.floppy_num], MAX_FLOPPY_NUM
       ja .search_next

.isharddisk:
%endif

       call fill_bootrecord
       inc byte [knl_tmp.good_record_num]
       mov ah, [knl_tmp.good_record_num]                ; check if there are any
       cmp ah, [knl_tmp.max_record_num]                 ; more space.
       jae .end

       add di, SIZE_OF_BOOTRECORD

.search_next:
       inc dl
       or dl, dl
       jnz .loop_search

.end:
       popa
       mov ch, [knl_tmp.good_record_num]
       ret


;==============================================================================
;search_part_records ---- search all boot records in a drive
;input:
;      dl = drive id
;      cl = max number of boot records could be searched
;      es:di -> buffer to store boot records
;output:
;      ch = number of the valid boot records have searched
;==============================================================================
search_part_records:
        xor ch, ch
        mov [knl_tmp.good_record_num], ch
        mov [knl_tmp.max_record_num], cl
        or cl, cl
        jnz .can_search_more                         ; check if there are any
        ret                                          ; space to search more.
        
.can_search_more:
        pusha

        xor ebx, ebx                                 ; clear some stuff
        xor dh, dh                                   ;

        call get_drive_flags                         ; get the drive flags.
        jmpc .end
        
        test al, DRVFLAG_REMOVABLE                  ; check if it's a floppy
        jmpnz .end
	test al, DRVFLAG_ISCDROM
	jmpnz .end

;search partitions
.search_partitions:
        push di
        lea di, [knl_tmp.disk_buf2]
        mov si, di
        mov ax, (INT13H_READ << 8 ) | 0x01           ; read the first sector
        call disk_access                             ; into buffer
        pop di
        jmpc .end
        
        cmp word [si + 510], 0AA55h    ; check if the partition
        jmpne .end                                   ; table is good
        
        add si, 1BEh                         ; point to partition table
        
        xor al, al

.loop_search_part:
        inc al

        or ebx, ebx                                  ; check if it's primary
        jnz .logical_part
        
        mov dh, al                                   ;
        mov [knl_tmp.part_id], dh                        ;
        jmp short .cont_fill_it                      ; get the partition id
                                                     ;
.logical_part:                                       ;
        mov dh, [knl_tmp.part_id]                        ;
        
.cont_fill_it:
        call fill_bootrecord                         ; fill the boot record
        xchg si, di
        call check_bootrecord                        ; check if it's valid
        xchg si, di
        jc .cont_search_part

; find a valid boot record!

        inc byte [knl_tmp.good_record_num]
        mov ah, [knl_tmp.good_record_num]                ; check if there are any
        cmp ah, [knl_tmp.max_record_num]                 ; more space.
        jae .end

        add di, SIZE_OF_BOOTRECORD                   ; move the pointer to

.cont_search_part:
        add si, SIZE_OF_PARTITION
        cmp al, 4
        jb .loop_search_part
        
        sub si, SIZE_OF_PARTITION * 4
        
;now go ahead to search logical partitons
        xor ah, ah

.loop_search_ext:
        inc ah
        mov al, [si + struc_partition.type]
        
        cmp al, 0x05                                 ; check if it's
        je .found_ext                                ; extended
        cmp al, 0x0F                                 ; partition
        je .found_ext                                ;
        cmp al, 0x85                                 ;
        je .found_ext                                ;

        add si, SIZE_OF_PARTITION
        cmp ah, 4
        jb .loop_search_ext
        jmp short .end

;there are some extended partitions, find inside it!
.found_ext:
        inc byte [knl_tmp.part_id]                       ; increase the partition id.
	mov ecx, [si + struc_partition.relative_addr]

        or ebx, ebx                                  ; all of the later logical
        jz .first_ext                                ; extended partitions' relative
        mov ebx, [knl_tmp.logi_father]                   ; address are based on the
        jmp short .calc_next_father                  ; first primary extended
                                                     ; partition
.first_ext:
        mov [knl_tmp.logi_father], ecx

.calc_next_father:
        add ebx, ecx                                 ; calculate the next
                                                     ; father's abs
                                                     ; address
        
        jmp .search_partitions                       ; continue search

.end:
        popa
        mov ch, [knl_tmp.good_record_num]
        ret
        
;==============================================================================
;search_specials ---- search all special boot records
;input:
;      cl = max number of boot records could be searched
;      es:di -> buffer to store boot records
;output:
;      ch = number of the valid boot records have searched
;==============================================================================
search_specials:
	push ax
	push dx
	push si

	mov ah, cl
	cmp ah, NUM_OF_SPREC
	jb .do_search
	mov ah, NUM_OF_SPREC

.do_search:
	xor ch, ch
	xor al, al
	or ah, ah
	jz .end

.loop_search:
	call fill_special_record
	mov si, di
	call check_bootrecord
	jc .search_next
	add di, SIZE_OF_BOOTRECORD
	inc ch
.search_next:
	inc al
	cmp al, ah
	jb .loop_search
.end:
	pop si
	pop dx
	pop ax
	ret

;==============================================================================
;search_records ---- search all boot records
;input:
;      al = 0 all records, al = 1 only partitions
;      cl = max number of boot records could be searched
;      es:di -> buffer to store boot records
;output:
;      ch = number of the valid boot records have searched
;==============================================================================
search_records:
	push di
	push dx
	push bx
	push ax

        xor dx, dx

	or al, al
	jnz .search_parts

	call search_specials
	sub cl, ch
	mov dh, ch

        mov bl, SIZE_OF_BOOTRECORD

        call search_drv_records
        sub cl, ch
        mov al, ch
	add dh, ch
        mul bl
        add di, ax

.search_parts:
	call search_all_partitions
	add ch, dh
	pop ax
	pop bx
	pop dx
	pop di
	ret

;==============================================================================
;search_all_partitions ---- search all partitions in all drives
;input:
;      cl = max number of boot records could be searched
;      dl = lowest drive id to be searched
;      es:di -> buffer to store boot records
;output:
;      ch = number of the valid boot records have searched
;==============================================================================
search_all_partitions:
        push ax
	push dx
	xor dh, dh
        mov bl, SIZE_OF_BOOTRECORD

.loop_search:
        call search_part_records
        sub cl, ch
        add dh, ch                                   ; count the searched boot
                                                     ; records
        mov al, ch                                   ;
        mul bl                                       ; adjust the pointer (di)
        add di, ax                                   ;
        inc dl
        or dl, dl
        jnz .loop_search
        mov ch, dh
	pop dx
        pop ax
        ret


;==============================================================================
;get_record_typestr ---- get a record's type string
;input:
;      ds:si -> the record
;      es:di -> the buffer to store the type string
;output:
;      none
;==============================================================================
get_record_typestr:
        pusha
        mov ax, [si + struc_bootrecord.flags]
        mov bl, [si + struc_bootrecord.type]
        mov dx, [si + struc_bootrecord.drive_id]

	test ax, INFOFLAG_ISSPECIAL
	jnz .special

        test ax, INFOFLAG_ISDRIVER
        jz .partition

        test ax, DRVFLAG_REMOVABLE
        jz .harddisk

        test dl, 0x80
        jz .floppy

	test ax, DRVFLAG_ISCDROM
	jz .removable

	lea si, [knl_strings.cdrom]
	jmp short .filldrv

.special:
	lea si, [knl_strings.special]
	jmp short .filldrv

.removable:
        lea si, [knl_strings.removable]
        jmp short .filldrv

.harddisk:
        lea si, [knl_strings.harddisk]
        jmp short .filldrv

.floppy:
        lea si, [knl_strings.floppy]

.filldrv:
        call strcpy
        jmp short .end

.partition:
        test ax, INFOFLAG_LOGICAL
        jz short .primary

        lea si, [knl_strings.logical]
        jmp short .fillpart

.primary:
        lea si, [knl_strings.primary]

.fillpart:
        call strcpy

        mov word [di], ' ('
        inc di
        inc di

        mov al, bl
        call get_parttype_str
        call strcpy
        mov byte [di], ')'
        inc di
        xor al, al
        stosb

.end:
        popa
        ret

;==============================================================================
;get_record_string ---- get a record's string
;input:
;      ds:si -> the record
;      es:di -> buffer to store the string
;      al =1    don't draw flags
;      al =2    don't draw flags and number
;      al =3    don't draw flags and type
;
;output:
;      none
;
;notes:
; the string layout is:
; pSkXaAhHlD  128 01  (Type )  Partition Name.
; where :
; p  is password flag, means have password.
; S  is schedule flag, means have boot schedule set.
; k  is keystrokes flag, means have keystrokes set.
; X  is swap driver id flag, means the driver id will be swap to the bootable
;    id when boot this record.
; aA is active flags, a means auto active, A means active
; hH is hidden flags, h means auto hide, H means hidden
; lD is other flags, L means it's Logical Partition, D means it's Disk Driver 
; 128 is the drive id
; 01 is the partition id
; (Type ) is the type of this partition, 7 bytes
; Partition Name is the name of this partition, 15 bytes
;==============================================================================
get_record_string:
        pusha
        cld

        mov ecx, [si + struc_bootrecord.password]
        mov bx, [si + struc_bootrecord.flags]

	mov ah, al

	mov al, ' '
	stosb

        or ah, ah
        jnz .no_flags
	push ax

;show flags

        mov al, '-'

        push ax
        or ecx, ecx                                 ; check if has password.
        jz .no_password
        mov al, 'p'                                 ; has password, draw a 'p'.
.no_password:
        stosb
        pop ax

        push si
        mov dx, INFOFLAG_SCHEDULED
        mov cx, NUM_OF_INFOFLAGS
        lea si, [infoflag_chars]

.loop_show_flags:
        push ax
        test bx, dx
        jz .no_thisflag
        mov al, [si]
.no_thisflag:
        stosb
        pop ax
        inc si
        shr dx, 1
        loop .loop_show_flags
        pop si

        mov al, ' '
        stosb
        stosb

	pop ax

.no_flags:
	cmp ah, 1
	ja .no_number

	push ax

        mov dx, [si + struc_bootrecord.drive_id]
	test bx, INFOFLAG_ISSPECIAL
	jz .get_drvid

	push si
	mov si, knl_strings.invalid_id
	call strcpy
	pop si

	jmp short .draw_type

.get_drvid:
	call get_drvid_str

        mov al, dh                                  ; fill partition id
	xor ah, ah
        mov cl, 3                                   ;
        call itoa                                   ;

        add di, 3

.draw_type:
        mov al, ' '
        stosb
        stosb

	pop ax

.no_number:
	cmp ah, 2
	ja .no_type

        push si                                     ; save the boot record pointer

	xor al, al
	test bx, INFOFLAG_ISSPECIAL
	jnz .is_special
        mov al, [si + struc_bootrecord.type]
.is_special:

        call get_parttype_str
        mov  cx, 8
        call strncpy
        pop si
        
        mov al, ' '
        stosb
        stosb

.no_type:
        add si, struc_bootrecord.name
        mov cx, 15
	push cx
        call strncpy                                ; fill record name
	mov ax, cx
	pop cx
	sub cx, ax
	mov al, ' '
	rep stosb
	xor al, al
	stosb
        popa
        ret

;==============================================================================
;mark_record_active ---- mark the boot record active.
;input:
;      ds:si -> the record
;output:
;      cf = 0 success
;      cf = 1 failed, ax = 0 cannot mark active, otherwise disk error occured.
;==============================================================================
mark_record_active:
        pusha
        call check_allow_act
        jc .cannot_active
        
        mov ax, (INT13H_READ << 8 ) | 0x01                  ; read father's
        mov ebx, [si + struc_bootrecord.father_abs_addr]    ; partition table.
        mov dl, [si + struc_bootrecord.drive_id]            ;
                                                            ;
        lea di, [knl_tmp.disk_buf1]                                  ;
        call disk_access                                    ;
        jc .disk_error                                      ;

        push dx
        push ebx
        push di
        
        add di, 1BEh

        mov ecx, [si + struc_bootrecord.abs_addr]    ; abs addr -> ecx

        sub ecx, ebx                                 ; relative addr -> ebx
	mov ebx, ecx
        mov cx, 4

        test word [si + struc_bootrecord.flags], INFOFLAG_SWAPDRVID  ; check if need swap id
        jz .no_swapid

        and dl, 0xF0                                 ; use 0x80 as active flag if swap id is on.
.no_swapid:

        xor ah, ah
.search_in_father:                                   ;
        xor al, al                                   ;
        cmp [di + struc_partition.relative_addr], ebx; find the record in
        jne .not_it                                  ; father's partition
        mov al, dl                                   ; table
        inc ah                                       ;
.not_it:                                             ;
        mov byte [di  + struc_partition.state], al   ;
        add di, SIZE_OF_PARTITION                    ;
        loop .search_in_father                       ;

        pop di                                       ;
        pop ebx                                       ;
        pop dx

        or ah, ah
        jz .cannot_active                            ; can not found the partition record
        
        mov ax , (INT13H_WRITE << 8 ) | 0x01         ; write the partition
        call disk_access                             ; table back.
        jc .disk_error

        or word [si + struc_bootrecord.flags], INFOFLAG_ACTIVE ; set active flag
        popa
        clc
        ret
        
.cannot_active:
        popa
        xor ax, ax
        stc
        ret
.disk_error:
        popa
        ret



;==============================================================================
;toggle_record_hidden ---- toggle a boot record's hidden attribute
;input:
;      ds:si -> the record
;output:
;      cf = 0 success
;      cf = 1 failed, ax = 0 cannot hide, otherwise disk error occured.
;==============================================================================
toggle_record_hidden:
        pusha
        
        call check_allow_hide
        jc .cannot_hide
        
        mov ax, (INT13H_READ << 8 ) | 0x01                  ; read father's
        mov ebx, [si + struc_bootrecord.father_abs_addr]    ; partition table.
        mov dl, [si + struc_bootrecord.drive_id]            ;
                                                            ;
        lea di, [knl_tmp.disk_buf1]                                  ;
        call disk_access                                    ;
        jc .disk_error                                      ;

        push ebx
        push di
        
        add di, 1BEh

        mov ecx, [si + struc_bootrecord.abs_addr]    ; abs addr -> ebx

        sub ecx, ebx                                 ; relative addr -> ebx
	mov ebx, ecx

        mov cx, 4

        mov ax, [si + struc_bootrecord.flags]        ; get flags and type
        mov dh, [si + struc_bootrecord.type]
        and dh, 0x0F
        test ax, INFOFLAG_HIDDEN
        jnz .unhide_it
        or dh, 0x10                                  ; hide the partition

.unhide_it:
        xor al, al
        
.search_in_father:                                   ;
        cmp [di + struc_partition.relative_addr], ebx; find the record in
        jne .not_it                                  ; father's partition
        inc al
        mov byte [di  + struc_partition.type], dh    ; set partition type.
.not_it:                                             ;
        add di, SIZE_OF_PARTITION                    ;
        loop .search_in_father                       ;

        pop di                                       ;
        pop ebx                                      ;

        or al, al
        jz .cannot_hide                              ; can not found the partition record
        
        mov ax , (INT13H_WRITE << 8 ) | 0x01         ; write the partition
        call disk_access                             ; table back.
        jc .disk_error

        xor word [si + struc_bootrecord.flags], INFOFLAG_HIDDEN ; toggle hidden flag.
        popa
        clc
        ret
        
.cannot_hide:
        popa
        xor ax, ax
        stc
        ret
.disk_error:
        popa
        ret

;==============================================================================
;set_record_schedule ---- set the record's schedule time
;input:
;      ds:si -> the record
;      ax = begin time (in minutes)
;      bx = end time (in minutes)
;      dx = week info (bit 0 to bit 6 indicate Mon to Sun, zero means all days)
;output:
;      none
;==============================================================================
set_record_schedule:
       pusha
       or ax, ax
       jnz .timeok
       or bx, bx
       jnz .timeok
       or dx, dx
       jnz .timeok

       and word [si + struc_bootrecord.flags], ~ INFOFLAG_SCHEDULED
       popa
       ret

.timeok:
       and ebx, 0x00000fff
       and eax, 0x00000fff
       shl ebx, 12
       or  eax, ebx
       and edx, 0x000000ff
       shl edx, 24
       or  eax, edx

       mov [si + struc_bootrecord.schedule_time], eax
       or word [si + struc_bootrecord.flags], INFOFLAG_SCHEDULED

       popa
       ret

;==============================================================================
;get_record_schedule ---- set the record's schedule time
;input:
;      ds:si -> the record
;output:
;      ax = begin time (in minutes)
;      bx = end time (in minutes)
;      dx = week info (bit 0 to bit 6 indicate Mon to Sun, zero means all days)
;==============================================================================
get_record_schedule:
       xor ax, ax
       xor bx, bx
       xor dx, dx

       test word [si + struc_bootrecord.flags], INFOFLAG_SCHEDULED
       jz .end

       mov eax, [si + struc_bootrecord.schedule_time]
       mov ebx, eax
       mov edx, eax

       and ax, 0x0fff
       shr ebx, 12
       and bx, 0x0fff
       shr edx, 24
       and dx, 0x00ff

.end:
       ret

;=============================================================================
;schedule_to_str ---- convert schedule time to string
;input:
;       ax = start time
;       bx = stop time
;       dx = days info
;       es:di -> buffer
;output:
;       none
;=============================================================================
schedule_to_str:
        pusha
        cld
        call sch_time_to_str
        mov si, di
        call strlen
        add di, cx
        mov al, '-'
        stosb
        mov ax, bx
        call sch_time_to_str
        mov si, di
        call strlen
        add di, cx
        mov al, ';'
        stosb
        call sch_days_to_str
        popa
        ret

;=============================================================================
;sch_days_to_str ---- convert days info string 0123456
;input:
;       dx = day bits
;       es:di -> buffer
;output:
;       none
;=============================================================================
sch_days_to_str:
        pusha
        mov cx, 7
        mov al, '0'
        mov bx, 1

.loop_chk:
        test dx, bx
        jz .nothisday
        stosb
.nothisday:
        shl bx, 1
        inc al
        loop .loop_chk

        xor al, al
        stosb

        popa
        ret

;=============================================================================
;sch_time_to_str ---- convert time in minute info string hh:mm
;input:
;       ax = time
;       es:di -> buffer
;output:
;       none
;=============================================================================
sch_time_to_str:
        pusha

        mov dl, 60
        div dl
        push ax

        xor ah, ah
        cmp al, 10
        jb .hlten
        mov cx, 2
        jmp short .showh
.hlten:
        mov cx,1
.showh:
        call itoa

        mov al,':'
        add di, cx
        stosb

        pop ax
        movzx ax, ah
        cmp al, 10
        jb .mlten
        mov cx, 2
        jmp short .showm
.mlten:
        mov cx,1
.showm:
        call itoa

        popa
        ret

;==============================================================================
;boot_normal_record ---- boot a normal record
;input:
;      ds:si -> the record
;output:
;      will not return when successfully boot.
;      if return then al != 0 disk error; al = 0 no operation system.
;==============================================================================
boot_normal_record:
        push es

        mov bx, [si + struc_bootrecord.flags]
        test bx, INFOFLAG_AUTOACTIVE
        jz .no_need_act
        call mark_record_active             ; active the partition

.no_need_act:
        test bx, INFOFLAG_HIDDEN
        jz .not_hidden
        call toggle_record_hidden           ; unhide the partition

.not_hidden:

        push bx                             ; save the flags
        lea di, [knl_tmp.disk_buf1]         ; load boot sector into knl_tmp.disk_buf1.
        mov ax, (INT13H_READ << 8 ) | 0x01
        mov dl, [si + struc_bootrecord.drive_id]
        mov ebx, [si + struc_bootrecord.abs_addr]

        call disk_access                    ; read the first sector of the
                                            ; partition / floppy into
                                            ; memory.
        pop bx
        jmpc .disk_error

        cmp word [di + 510], 0AA55h
        jmpne .no_system

        test bx, INFOFLAG_ISDRIVER          ; if it's driver, skip loading the
                                            ; partition table.
        jnz .do_boot

        push bx                             ; save the flags 
        lea di, [knl_tmp.disk_buf2]    ; load part table into knl_tmp.disk_buf2

        mov ebx, [si + struc_bootrecord.father_abs_addr]

        call disk_access                    ; load part table into memory.
        pop bx
        jc .disk_error

        cmp word [di + 510], 0AA55h
        jne .no_system                      ; bad partition table, treated as
                                            ; no operating system.

.do_boot:
%ifndef EMULATE_PROG

        test bx, INFOFLAG_SWAPDRVID         ; check if need swap id
        jz .no_swapid

;================ swap the driver id ========================================
        mov dh, dl
        and dh, 0x80                        ; set driver id to the bootable id

	mov bx, dx
	xchg dh, dl
	mov cx, dx

	call set_drive_map

        mov [si + struc_bootrecord.drive_id], dl  ; write new driver id back
	jmp short .swap_ok

.no_swapid:
	call uninstall_myint13h

.swap_ok:
        call prepare_boot                   ; prepare to boot.
        jc .no_system                       ; preparation failed.
        
%endif
        call preload_keystrokes     ; preload the keystrokes into key buffer.
        call reset_video_mode

%ifndef EMULATE_PROG

        push si
        cld

        xor ax, ax
        push ax
        pop es
        mov cx, 512

        test word [si + struc_bootrecord.flags], INFOFLAG_ISDRIVER
                                            ; if it's driver, no partition
        jnz .boot_driver                    ; table to load.
        
        lea si, [knl_tmp.disk_buf2]
        mov di, PART_OFF

        push cx
        rep movsb                           ; move mbr (partition table) to
                                            ; 0000:0600
        pop cx
        
.boot_driver:
        lea si, [knl_tmp.disk_buf1]
        mov di, 7C00h
        rep movsb                           ; move boot sector to 0000:7C00

        pop si

        mov dl, [si + struc_bootrecord.drive_id] ; drive id -> dl
        xor dh, dh

; boot code from lilo :-)

        mov si, bx                          ; ds:si , es:di point to the
        add si, PART_OFF + 1BEh     ; partition record.
        push si                             ;
        pop di                              ;

        push ax                             ; ds = 0 ( es already set to 0 ).
        pop ds                              ;
        
%if 0
        xor bp, bp                          ; might help some boot problems
        mov ax, 0AA55h                ; boot signature (just in case ...)
        jmp 0:7C00h                         ; start boot sector
%else
;boot code from the OS2 Boot Manager
        mov bx, 7C00h
    
        mov ss,ax                           ; on all processors since the 186
        mov sp,bx                           ; these instructions are locked
    
        mov bp, si
        push    ax
        push    bx
        mov ax, 0AA55h
        retf                                ; start boot sector
%endif
        
%else
	call uninstall_myint13h
        mov ax, 0x4c00                      ; return to dos.
        int 0x21                            ;
%endif

.no_system:
        xor al, al
.disk_error:
        pop es
        ret

%ifndef DISABLE_CDBOOT
;==============================================================================
; boot_cdrom ---- boot cdrom driver
; input: ds:di -> boot catalog
;        dl = cdrom drvid
;==============================================================================
boot_cdrom:
	mov al, [di+1]
	and al, 0x0f

	mov si, knl_tmp.cdemu_spec
	mov byte [si], SIZE_OF_CDEMU_SPEC
	mov [si + struc_cdemu_spec.media_type], al

	xor ah, ah
	or al, al
	jnz .floppy_emu
	mov ah, dl
.floppy_emu: 

	mov byte [si + struc_cdemu_spec.emu_drvid], ah
	mov ebx, [di+0x08]
	mov [si + struc_cdemu_spec.image_lba], ebx
	mov bx, [di+0x02]
	mov [si + struc_cdemu_spec.load_seg], bx
	mov bx, [di+0x06]
	mov [si + struc_cdemu_spec.sect_count], bx
	mov byte [si + struc_cdemu_spec.cylinders], 0x50
	mov byte [si + struc_cdemu_spec.heads], 2

	mov bl, al
	xor bh, bh
	mov ah, [.sect_nums + bx]

	mov byte [si + struc_cdemu_spec.sectors], ah
	xor ax, ax
	mov [si + struc_cdemu_spec.user_bufseg], ax

;Boot it!
	mov ax, 0x4a00
	int 0x13
	mov [hdio_tmp.disk_errno],ah
	jc .end

;If the cd-rom is accessed via BIOS, then uninstall my int13h.
	call uninstall_myint13h

	mov ax, 0x4c00
	int 0x13
	xor ax, ax
.end:
	ret

.sect_nums  db  0, 0x0f, 0x12, 0x24


;==============================================================================
;find_cdboot_catalog ---- find boot catalog entry from buffer
;input: ds:si -> buffer  es:di -> entries buffer
;return: cx = number of entries
;==============================================================================
find_cdboot_catalog:
	push si
	push di
	push ax
	cld

	xor cx, cx

	cmp word [si], 0x0001
	jne .end
	cmp word [si+0x1e], 0xaa55
	jne .end

.loop_find:
	mov al, [si + struc_boot_catalog.indicator]
	or al, al
	jz .end

	cmp al, 0x88
	jne .loop_next

	mov al, [si + struc_boot_catalog.media_type]
	and al, 0x0f
	cmp al , 4
	jae .loop_next

	push cx
	push si
	mov cx, SIZE_OF_BOOT_CATALOG
	rep movsb
	pop si
	pop cx
	inc cx

.loop_next:
	add si, SIZE_OF_BOOT_CATALOG
	jmp short .loop_find

.end:
	pop ax
	pop di
	pop si
	ret

%endif

;==============================================================================
;preload_keystrokes ---- preload the keystrokes into key buffer.
;input:
;      ds:si -> boot record
;output:
;      none
;==============================================================================
preload_keystrokes:
        pusha
        cld
        test word [si + struc_bootrecord.flags], INFOFLAG_HAVEKEYS
        jz .end

        mov cx, MAX_KEYSTROKES
        add si, struc_bootrecord.keystrokes

.loop_load:
        lodsw
        or ax, ax
        jz .end

        push cx
        mov cx, ax
        mov ah, 0x05
        call bioskey
        pop cx
        or al, al
        jnz .end
        loop .loop_load
.end:
        popa
        ret

;==============================================================================
;prepare_boot ---- do some preparation before booting.
;input:
;      ds:si -> boot record
;      knl_tmp.disk_buf1  -> boot sector
;      knl_tmp.disk_buf2 -> father's first sector ( partition table ).
;output:
;      cf = 0 success
;          bx = the partition record's offset in partition table.
;      cf = 1 failed
;==============================================================================
prepare_boot:
        xor ax, ax
        test word [si + struc_bootrecord.flags], INFOFLAG_ISDRIVER
        jmpnz .end

        mov ebx, [si + struc_bootrecord.abs_addr]         ;

        mov ecx, [si + struc_bootrecord.father_abs_addr]  ;

        mov eax, ebx
        sub eax, ecx                                      ; relative addr -> eax

        lea di, [knl_tmp.disk_buf2 + 1BEh]
        xor cl, cl
        
.search_in_father:
        cmp [di + struc_partition.relative_addr], eax
        je .found
        inc cl
        add di, SIZE_OF_PARTITION
        cmp cl, 4
        jb .search_in_father
        jmp short .failed

.found:
        mov al, SIZE_OF_PARTITION                   ; ax = offset in partition
        mul cl                                      ; table.

        mov dl, [si + struc_bootrecord.drive_id]
        mov [di + struc_partition.state], dl        ; store drive id into
                                                    ; partition record

        lea di, [knl_tmp.disk_buf1]                          ; di -> boot record
        mov dh, [si + struc_bootrecord.type]

        cmp dh, 0x04
        je .fat16
        cmp dh, 0x06
        je .fat16
        cmp dh, 0x0e
        je .fat16
        cmp dh, 0x0b
        je .fat32
        cmp dh, 0x0c
        je .fat32
        jmp short .end
.fat16:
        cmp byte [di + FAT16_EXTBRID_OFF], EXTBRID
        jne .end
        
        mov [di + FAT16_DRVID_OFF], dl              ; update the drive id.
        mov [di + FAT16_HIDSEC_OFF], ebx            ; update hidden sector
                                                    ; = abs_addr.
        jmp short .end
.fat32:
        cmp byte [di + FAT32_EXTBRID_OFF], EXTBRID
        jne .end
        
        mov [di + FAT32_DRVID_OFF], dl              ; update the drive id.
        mov [di + FAT32_HIDSEC_OFF], ebx            ; update hidden sector
                                                    ; = abs_addr.
        jmp short .end
        
.failed:
;        stc
;        ret
.end:
        mov bx, ax          ; partition record's offset store to bx.
        clc
        ret

;==============================================================================
;check_allow_hide ---- check if the partition can be hidden.
;input:
;      ds:si -> the boot record
;output:
;      cf = 0 can be hidden
;      cf = 1 cannot be hidden
;==============================================================================
check_allow_hide:
        pusha
	or si, si
	jz .cannot_hide

        mov ax, [si + struc_bootrecord.flags]
        test ax, DRVFLAG_DRIVEOK
        jz .cannot_hide
        test ax, INFOFLAG_ISDRIVER | DRVFLAG_ISCDROM | INFOFLAG_ISSPECIAL
        jnz .cannot_hide

        mov al, [si + struc_bootrecord.type]
        mov cx, NUM_OF_ALLOW_HIDE
        lea di, [part_type.allow_hide_tbl]
        call strchr
        popa
        ret
        
.cannot_hide:
        popa
        stc
        ret

;==============================================================================
;check_allow_act ---- check if the partition can be actived.
;input:
;      ds:si -> the boot record
;output:
;      cf = 0 can be actived
;      cf = 1 cannot be actived
;==============================================================================
check_allow_act:
        pusha
	or si, si
	jz .cannot_act

        mov ax, [si + struc_bootrecord.flags]   ; get flags
        test ax, DRVFLAG_DRIVEOK
        jz .cannot_act
        test ax, INFOFLAG_ISDRIVER | INFOFLAG_LOGICAL | DRVFLAG_ISCDROM | INFOFLAG_ISSPECIAL
        jnz .cannot_act
        popa
        clc
        ret
        
.cannot_act:
        popa
        stc
        ret

;==============================================================================
;check_prev_mbr ---- check if the previous mbr is avaiable.
;input:
;      none
;output:
;      cf = 0 present
;      cf = 1 absent
;==============================================================================
check_prev_mbr:
	pusha
	mov dl, [Boot_Drive]
	call get_drive_flags
	jc .end
	test al, DRVFLAG_REMOVABLE
	jz .end
	stc
.end:
	popa
	ret

;==============================================================================
;data area
;==============================================================================

; strings used in knl.asm
infoflag_chars  db "SkXaAhHlD",0

knl_strings:
.floppy     db "Floppy",0
.primary    db "Primary",0
.logical    db "Logical",0
.removable  db "Removable",0
.harddisk   db "Harddisk",0
.cdrom      db "CD-ROM",0
.special    db "Special",0
.poweroff   db "Power Off",0
.restart    db "Reboot",0
.quit       db "Quit to BIOS",0
.bootprev   db "Previous MBR",0
.invalid_id db "--- --",0

; partition types and strings
part_type:

; table of partition type ids
.id_tbl:
        db 0x00, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 
	db 0x0E, 0x3C, 0x4D, 0x4E, 0x4F, 0x63, 0x65, 0x81, 
	db 0x82, 0x83, 0x8E, 0x93, 0xA5, 0xA6, 0xA9, 0xB7, 
	db 0xBE, 0xEB

; table of partition type strings
.str_tbl:
        db "NONE   ",0           ; No type
        db "FAT16  ",0           ; 0x06
        db "HP/NTFS",0           ; 0x07
	db "AIX(08)",0           ; 0x08
	db "AIX(09)",0           ; 0x09
	db "OS/2 BM",0           ; 0x0A
        db "FAT32  ",0           ; 0x0B
        db "FAT32x ",0           ; 0x0C
        db "FAT16x ",0           ; 0x0E
        db "PQ-Boot",0           ; 0x3C
        db "QNX4.x ",0           ; 0x4D
        db "QNX4x-2",0           ; 0x4E
        db "QNX4x-3",0           ; 0x4F
        db "HURD   ",0           ; 0x63
        db "Novell ",0           ; 0x65
        db "Minix  ",0           ; 0x81
        db "LnxSwap",0           ; 0x82
        db "Linux  ",0           ; 0x83
	db "Lnx LVM",0           ; 0x8E
	db "Amoeba ",0           ; 0x93
        db "BSD/386",0           ; 0xA5
        db "OpenBSD",0           ; 0xA6
        db "NetBSD ",0           ; 0xA9
        db "BSDi fs",0           ; 0xB7
        db "Solaris",0           ; 0xBE
        db "BeOS   ",0           ; 0xEB
        db "Unknown",0           ; other

; logical partition types which could not boot
; include the following pri_deny_tbl
.log_deny_tbl:
%ifdef STRICT_PART_CHECK
        db 0x01, 0x0A, 0x07, 0x17
%endif
; primary partition types which could not boot
.pri_deny_tbl:
        db 0x05, 0x0F, 0x85
%ifdef STRIC_PART_CHECK
        db 0x82, 0xA0, 0xB8, 0xE1, 0xE3, 0xF2
%endif
	db 0x00

;the partition types which should be marked as auto active.
.auto_act_tbl:
;the partition types which can be hidden.
;the hide method is add 0x10 to the partition type.
; ie. the type of hidden FAT16 = 0x16, etc.
        db 0xBE
.allow_hide_tbl:
        db 0x01, 0x04, 0x06, 0x07, 0x0B, 0x0C, 0x0E

; the types used to hide certain partitions.
.hidden_tbl:
        db 0x11, 0x14, 0x16, 0x17, 0x1B, 0x1C, 0x1E
        
.end_of_tbl

