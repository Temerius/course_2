proc addCPU
    mov esi, dword[CPU]
    mov word [esi+edi],cx
    mov word [esi+edi+cpu_proc_name_offset], -1
    mov word [esi+edi+cpu_cells_count_offset], 0
    mov word [esi+edi+cpu_hung_stage_offset], 0
    mov word [esi+edi+cpu_uptime_offset], 0
    mov word [esi+edi+cpu_downtime_offset], 0
    mov word [esi+edi+cpu_finaltime_offset], 0
    mov word [esi+edi+cpu_need_IO_offset], 0
    mov dword [esi+edi+cpu_uptime_tick_offset], 0
    mov dword [esi+edi+cpu_downtime_tick_offset], 0
    mov word [esi+edi+cpu_executed_offset], 0
    ret
endp

proc movproctocpu uses ebx ecx edx, index: dword
    add esi,edi
    mov ebx,esi
    mov esi, dword[processes]
    stdcall GetEdi, [index],process_offset
    movzx eax, word[edi+esi+proc_name_offset]
    mov word [ebx+cpu_proc_name_offset], ax
    movzx eax, word[edi+esi+cells_count_offset]
    mov word [ebx+cpu_cells_count_offset], ax
    movzx eax, word[edi+esi+hung_stage_offset]
    mov word [ebx+cpu_hung_stage_offset], ax
    movzx eax, word[edi+esi+downtime_offset]
    mov word [ebx+cpu_downtime_offset], ax
    movzx eax, word[edi+esi+finaltime_offset]
    mov word [ebx+cpu_finaltime_offset], ax
    movzx eax, word[edi+esi+need_IO_offset]
    mov word [ebx+cpu_need_IO_offset], ax
    mov eax, dword[edi+esi+downtime_tick_offset]
    mov dword [ebx+cpu_downtime_tick_offset], eax
    mov word [ebx+cpu_uptime_offset],0
    mov dword [ebx+cpu_uptime_tick_offset],0
    mov word [ebx+cpu_executed_offset],0

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

proc addprocess uses esi edi edx ebx ecx
    ;mov esi, dword[processes]
    mov edx,0
    mov eax, edi
    mov ecx,process_offset
    div ecx
    mov word[esi+edi], ax
    mov dx, word[current_name]
    mov word [esi+edi+proc_name_offset],dx
    inc dx
    mov word [current_name],dx

    mov edx,0
    rdrand eax
    div [Random_RAMdelimiter]
    inc edx
    mov word [esi+edi+cells_count_offset],dx
    mov word [esi+edi+hung_stage_offset],2
    mov word [esi+edi+downtime_offset],0
    mov word [esi+edi+finaltime_offset],0
    mov word [esi+edi+need_IO_offset],0
    mov dword [esi+edi+downtime_tick_offset],0
    mov word [esi+edi+was_on_CPU_offset],0
    ret
endp


proc movcputoproc uses ebx ecx edx edi esi,name: dword
    push edi
    mov ebx, dword[CPU]
    stdcall GetEdi, dword[name],CPU_offset
    add ebx, edi
    pop edi
    movzx eax, word[ebx+cpu_proc_name_offset]
    mov word [esi+edi+proc_name_offset],ax
    movzx eax, word[ebx+cpu_cells_count_offset]
    mov word [esi+edi+cells_count_offset],ax
    movzx eax, word[ebx+cpu_hung_stage_offset]
    mov word [esi+edi+hung_stage_offset],ax
    movzx eax, word[ebx+cpu_downtime_offset]
    mov word [esi+edi+downtime_offset],ax
    movzx eax, word[ebx+cpu_finaltime_offset]
    mov word [esi+edi+finaltime_offset],ax
    movzx eax, word[ebx+cpu_need_IO_offset]
    mov word [esi+edi+need_IO_offset],ax
    mov eax, dword[ebx+cpu_downtime_tick_offset]
    mov dword [esi+edi+downtime_tick_offset],eax
    mov word [esi+edi+was_on_CPU_offset],1
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
    mov ecx,pages_in_raw_count
    movzx eax, word[RAM_lines_count]
    imul eax,ecx
    mov word[RAMPages_count],ax

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


    movzx eax, word[RAM_lines_count]
    sub word[DISK_lines_count], ax
    mov ecx, pages_in_raw_count
    movzx eax, word[DISK_lines_count]
    imul eax,ecx
    mov word[DISKPages_count],ax

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
        
    
    xor edx,edx
    movzx eax, [RAM_lines_count]
    mov ecx, page_height
    imul eax,ecx
    add dword[DISKY1],eax
    xor edx,edx
    movzx eax, [RAM_lines_count]
    dec eax
    mov ecx, page_page_gap
    imul eax,ecx
    add dword[DISKY1],eax
    add dword[DISKY1],ram_disk_gap

    mov edi, Smilesarray
    mov esi, 0
    invoke LoadImage, [hDC], emoji0, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji1, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji2, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji3, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji4, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji5, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
    add esi,4
    invoke LoadImage, [hDC], emoji6, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
     add esi,4
    invoke LoadImage, [hDC], emoji7, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov dword[edi+esi],eax
   
    mov edi, Hourglassesarray
    mov esi, 0
    mov ecx, 0
    .startloop:
        push ecx
        stdcall IntToStr, ecx,emoji8,21
        invoke LoadImage, [hDC], emoji8, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
        mov dword[edi+esi],eax
        add esi,4
        pop ecx
        inc ecx
        cmp esi, 28
        jb .startloop

ret
endp
