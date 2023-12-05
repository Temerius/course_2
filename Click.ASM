proc IsInSquare uses ebx ecx edx esi edi, x1: dword, y1: dword, x2: dword, y2: dword
    mov edi, dword[mouseX]
    mov esi, dword[mouseY]
    mov eax, 0
    .if edi >= [x1]
        .if edi <= [x2]
            .if esi >= [y1]
                .if esi <= [y2]
                    mov eax,1
                .endif
            .endif
        .endif
    .endif
ret
endp

proc FindClick uses ebx ecx edx esi edi
    mov edi, dword[mouseX]
    mov esi, dword[mouseY]

    movzx eax, word[CPU_count]
    xor edx,edx
    mov ecx, square_size
    imul eax,ecx
    mov ebx, eax

    movzx eax, word[CPU_count]
    dec eax
    xor edx,edx
    mov ecx, cpu_cpu_gap
    imul eax,ecx
    add ebx, eax
    add ebx, margin_left

    stdcall IsInSquare, margin_left, margin_top+header_height+header_cpu_gap, ebx,margin_top+header_height+header_cpu_gap+square_size
    .if eax = 1
        stdcall FindClickInCPU
        jmp .return
    .endif

    stdcall IsInSquare, margin_left, procsquareY1, left_header_width,procsquareY2
    .if eax = 1
        stdcall FindClickInProc
        jmp .return
    .endif

    movzx eax, word[RAM_lines_count]
    xor edx,edx
    mov ecx, page_height
    imul eax,ecx
    mov ebx, eax

    movzx eax, word[RAM_lines_count]
    dec eax
    xor edx,edx
    mov ecx, page_page_gap
    imul eax,ecx
    add ebx, eax
    add ebx, ramsquareY1

    stdcall IsInSquare, left_header_width, ramsquareY1, left_header_width+right_header_width,ebx
    .if eax = 1
        stdcall FindClickInRAM
        jmp .return
    .endif

    mov ebx, dword[DISKY1]
    add ebx, header_height+disk_page_gap
    
    stdcall IsInSquare, left_header_width, ebx, left_header_width+right_header_width,Height
    .if eax = 1
        stdcall FindClickInDISK, ebx
        jmp .return
    .endif

    stdcall IsInSquare, margin_left, margin_top, margin_left+square_size*2+cpu_cpu_gap,margin_top+header_height
    .if eax = 1
        stdcall DeleteIO
        jmp .return
    .endif


    .return:
ret

endp


proc FindClickInCPU uses ebx ecx edx esi edi
    mov esi, dword[CPU]
    mov edi,0
    local x1 dd margin_left
    local y1 dd margin_top+header_height+header_cpu_gap
    local x2 dd margin_left+square_size
    local y2 dd margin_top+header_height+header_cpu_gap+square_size

    .startloop:
        stdcall IsInSquare, [x1], [y1],[x2], [y2]
        .if eax = 1
            .if word[esi+edi+cpu_hung_stage_offset] <> 0
                movzx edx, word[esi+edi]
                stdcall CPUpop, edx
            .else
                movzx edx, word[esi+edi+cpu_proc_name_offset]
                stdcall deletecells , edx
                mov word[esi+edi+cpu_proc_name_offset], -1
            .endif
            jmp .return
        .else
            add [x1], square_size+cpu_cpu_gap
            add [x2], square_size+cpu_cpu_gap
            add edi,CPU_offset
            cmp edi, dword[CPU_size]
            jb .startloop
        .endif

    .return:
ret
endp

proc FindClickInProc uses ebx ecx edx esi edi
    mov esi, dword[processes]
    mov edi,0
    local x1 dd margin_left
    local y1 dd procsquareY1
    local x2 dd margin_left+square_size
    local y2 dd procsquareY1+square_size
    local proc_in_raw dd 0

    .startloop:
        stdcall IsInSquare, [x1], [y1],[x2], [y2]
        inc [proc_in_raw]
        .if eax = 1
            movzx edx, word[esi+edi]
            stdcall CPUpush, edx
            jmp .return
        .else
            .if dword[proc_in_raw] = proc_in_raw_count
                mov dword[x1],margin_left
                mov dword[x2], margin_left+square_size
                add dword[y1], square_size+cpu_cpu_gap
                add dword[y2], square_size+cpu_cpu_gap
                mov dword[proc_in_raw],0
            .else
                add dword[x1],square_size+cpu_cpu_gap
                add dword[x2],square_size+cpu_cpu_gap
            .endif
            add edi,process_offset
            cmp edi, dword[Process_size]
            jb .startloop
        .endif

    .return:
ret
endp


proc FindClickInRAM uses ebx ecx edx esi edi
    mov esi, dword[RAM]
    mov edi,0
    local x1 dd left_header_width
    local y1 dd ramsquareY1
    local x2 dd left_header_width+page_width
    local y2 dd ramsquareY1+page_height
    local page_in_raw dd 0

    .startloop:
        stdcall IsInSquare, [x1], [y1],[x2], [y2]
        inc [page_in_raw]
        .if eax = 1
            .if word[esi+edi+process_on_RAM_offset] <> -1
                movzx ebx, word[esi+edi]
                stdcall diskrampush, -1, ebx ,2
            .endif
            jmp .return
        .else
            .if dword[page_in_raw] = pages_in_raw_count
                mov dword[x1],left_header_width
                mov dword[x2], left_header_width+page_width
                add dword[y1], page_height+page_page_gap
                add dword[y2], page_height+page_page_gap
                mov dword[page_in_raw],0
            .else
                add dword[x1],page_width+page_page_gap
                add dword[x2],page_width+page_page_gap
            .endif
            add edi,RAM_offset
            cmp edi, dword[RAM_size]
            jb .startloop
        .endif

    .return:
ret
endp


proc FindClickInDISK uses ebx ecx edx esi edi, Ystart: dword
    mov esi, dword[DISK]
    mov edi,0
    local x1 dd left_header_width
    local y1 dd 0
    local x2 dd left_header_width+page_width
    local y2 dd 0
    local page_in_raw dd 0
    mov eax, dword[Ystart]
    mov [y1], eax
    add eax, page_height
    mov [y2], eax
    .startloop:
        stdcall IsInSquare, [x1], [y1],[x2], [y2]
        inc [page_in_raw]
        .if eax = 1
            .if word[esi+edi+process_on_DISK_offset] <> -1
                movzx ebx, word[esi+edi]
                stdcall diskrampush, -1, ebx ,1
            .endif
            jmp .return
        .else
            .if dword[page_in_raw] = pages_in_raw_count
                mov dword[x1],left_header_width
                mov dword[x2], left_header_width+page_width
                add dword[y1], page_height+page_page_gap
                add dword[y2], page_height+page_page_gap
                mov dword[page_in_raw],0
            .else
                add dword[x1],page_width+page_page_gap
                add dword[x2],page_width+page_page_gap
            .endif
            add edi,DISK_offset
            cmp edi, dword[DISK_size]
            jb .startloop
        .endif

    .return:
ret
endp

proc DeleteIO uses ecx edx ebx esi edi 
    mov dword[NeedIOCount], 0
    mov esi, dword[processes]
    mov edi,0
    
    .loopstart:
        .if word[esi+edi+need_IO_offset] = 1
            mov word[esi+edi+need_IO_offset],0
        .endif

        add edi, process_offset
        cmp edi, dword[Process_size]
        jb .loopstart

    mov esi, dword[CPU]
    mov edi,0
    
    .loopstart2:
        .if word[esi+edi+cpu_need_IO_offset] = 1
            mov word[esi+edi+cpu_need_IO_offset],0
        .endif

        add edi, CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart2
ret
endp