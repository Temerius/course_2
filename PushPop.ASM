; comparator2 push on 1 - ram, 2 - disk  
; comparator1 if <> -1 - index of ram or disk to delete; depends on comparator2 
proc diskrampush uses edi esi ecx ebx edx, process_topush: dword , comparator1: dword, comparator2: dword
    locals
        arr1 dd ?
        size1 dd ?
        offset1 dd ?
        arr2 dd ?
        offset2 dd ?
    endl
    push ecx ; save currentcellcount for function
    .if dword[comparator2] = 1
        mov eax,[RAM]
        mov [arr1],eax
        mov eax,[RAM_size]
        mov [size1],eax
        mov [offset1],RAM_offset
        mov eax,[DISK]
        mov [arr2],eax
        mov [offset2],DISK_offset
    .else
        mov eax,[RAM]
        mov [arr2],eax
        mov [offset2],RAM_offset
        mov eax,[DISK]
        mov [arr1],eax
        mov eax,[DISK_size]
        mov [size1],eax
        mov [offset1],DISK_offset
    .endif
    .if [process_topush] <> -1
        mov esi, dword[processes]
        stdcall GetEdi, dword[process_topush],process_offset
        movzx eax, word[esi+edi+proc_name_offset]
    .else
        movzx eax, word[esi+edi+tmp_offset]
    .endif
    mov esi, dword[arr1]
    mov edi, 0
    .loopstart:
        .if word[esi+edi+tmp_offset] = -1
            mov word[esi+edi+tmp_offset],ax
            jmp .endloop
        .else
            add edi,[offset1]
            cmp edi, dword [size1]
            jb .loopstart
        .endif

    .endloop:
    .if edi >= dword [size1]
        mov eax,-1
    .else 
        .if [comparator1] <> -1
            stdcall deletefromdiskram,[comparator1],[offset2],[arr2]
        .endif
        mov eax,0
        .endif
    pop ecx
    ret
endp

proc RAMpush_process uses ecx edi esi, process_topush: dword
    locals
        currentcount dw 0
    endl
    mov cx, word[esi+edi+cells_count_offset]
    .loopstart:

        stdcall diskrampush, dword[process_topush],-1,1
        .if eax = -1
            stdcall diskrampush, dword[process_topush],-1,2
        .endif
        inc word[currentcount]
        cmp word[currentcount],cx
        jb .loopstart
    ret
endp


proc CPUpush, proc_index: dword

    mov esi, dword[CPU]
    mov edi, 0
    .start_loop:
        .if word[esi+edi+cpu_proc_name_offset] <> -1
            add edi,CPU_offset
            .if edi < dword[CPU_size]
                jmp .start_loop
            .endif
        .endif
    .if edi < dword[CPU_size]
        stdcall movproctocpu, dword [proc_index]
        .if word[esi+edi+was_on_CPU_offset] = 0
            stdcall RAMpush_process, dword[proc_index]
            mov word[esi+edi+was_on_CPU_offset],1
        .endif  
        mov word[esi+edi+proc_name_offset],-1
    .else
        mov eax,-1
    .endif
    ret
endp

proc CPUpop uses esi edi ecx ebx edx, process_topop: dword

    stdcall newprocess, 2, dword[process_topop]
    mov esi, dword[CPU]
    stdcall GetEdi, dword[process_topop],CPU_offset
    mov word[esi+edi+cpu_proc_name_offset], -1
    
    
ret
endp
