proc addCPU
    mov esi,dword[CPU]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_CPU_offset], -1
    
    ret
endp

proc addRAM
    mov esi,dword[RAM]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_RAM_offset], -1
    
    ret
endp

proc addDISK
    mov esi,dword[DISK]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_DISK_offset], -1
    
    ret
endp

proc addprocess
    mov esi, dword[processes]
    mov dx, word[current_name]
    mov word [esi+edi],dx
    inc dx
    mov word [current_name],dx

    mov edx,0
    rdrand eax
    div [Random_RAMdelimiter]
    inc edx
    mov word [esi+edi+number_in_CPU_offset], -1
    mov word [esi+edi+cells_count_offset],dx
    mov word [esi+edi+hung_stage_offset],1
    mov word [esi+edi+downtime_offset],0
    mov word [esi+edi+uptime_offset],0
    mov word [esi+edi+finaltime_offset],0
    mov word [esi+edi+need_IO_offset],0
    mov dword [esi+edi+downtime_tick_offset],0
    mov dword [esi+edi+uptime_tick_offset],0
    mov word [esi+edi+executed_offset],0
    mov word [esi+edi+was_on_CPU_offset],0
    ret
endp

proc initialisation, a: DWORD
    ; process array size
    mov ax, word [Process_count]
    mov bx, process_offset
    imul ax,bx
    ;

    movzx eax,ax
    mov dword [Process_size],eax


    shl eax,1 ;expand array size x2

    mov dword [Real_process_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [processes],eax
    mov esi,eax       ;;;;;;;;;;;;;

    mov edi,0 ; offset in process array

    ; filling the array of processes
    ini_loopstart:
        stdcall addprocess
        add edi,process_offset
        cmp edi, dword [Process_size]
        jne ini_loopstart

    ;
    


    ; ini for CPU
    mov ax, word [CPU_count]
    mov bx, CPU_offset
    imul ax,bx
    movzx eax,ax
    mov dword [CPU_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [CPU],eax
    mov esi,eax       ;;;;;;;;;;;;;
    mov edi,0 ; offset in CPU array
    mov cx,0
    ; filling the array of CPUs
    inicpu_loopstart:
        stdcall addCPU
        inc cx
        add edi,CPU_offset
        cmp edi, dword [CPU_size]
        jne inicpu_loopstart


    ; ini for RAM
    mov ax, word [RAMPages_count]
    mov bx, RAM_offset
    imul ax,bx
    movzx eax,ax
    mov dword [RAM_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [RAM],eax
    mov esi,eax       ;;;;;;;;;;;;;

    mov edi,0 ; offset in RAM array
    mov cx,0
    ; filling the array of RAM
    iniram_loopstart:
        stdcall addRAM
        inc cx
        add edi,RAM_offset
        cmp edi, dword [RAM_size]
        jne iniram_loopstart

    ; ini for DISK
    mov ax, word [DISKPages_count]
    mov bx, DISK_offset
    imul ax,bx
    movzx eax,ax
    mov dword [DISK_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [DISK],eax
    mov esi,eax       ;;;;;;;;;;;;;

    mov edi,0 ; offset in DISK array
    mov cx,0
    ; filling the array of DISK
    inidisk_loopstart:
        stdcall addDISK
        inc cx
        add edi,DISK_offset
        cmp edi, dword [DISK_size]
        jne inidisk_loopstart
ret
endp