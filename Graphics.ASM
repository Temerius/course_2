proc DrawHeader
    invoke CreateSolidBrush, 0x00969817
    mov [hBrush], eax
    invoke CreatePen, PS_SOLID, 2, 0x00969817
    mov [hPen], eax
    invoke SelectObject, [hDC], [hBrush]
    invoke SelectObject, [hDC], [hPen]
    invoke Rectangle, [hDC],margin_left, margin_top,margin_left+square_size*2+cpu_cpu_gap,margin_top+header_height
    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]
    stdcall strclean, buffer
    mov eax, dword[NeedIOCount]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, IOEVENTS,buffer,result_buffer,1
    stdcall concatinate, result_buffer,IOEVENTSEND,result_buffer,0
    stdcall MyDrawText, 0x00969817,0x00000000,20,margin_left, margin_top,margin_left+square_size*2+cpu_cpu_gap,margin_top+header_height,result_buffer,DT_SINGLELINE+DT_CENTER+DT_VCENTER


    stdcall concatinate, UPTIME,space,result_buffer,1
    stdcall concatinate, result_buffer,COLOMN,result_buffer,0
    stdcall concatinate, result_buffer,space,result_buffer,0
    stdcall strclean, buffer
     
    .if dword[hours] < 10
        stdcall concatinate, result_buffer,ZERO,result_buffer,0
    .endif
    mov eax,dword[hours]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall concatinate, result_buffer,COLOMN,result_buffer,0
    stdcall strclean, buffer
    
    .if dword[minutes] < 10
        stdcall concatinate, result_buffer,ZERO,result_buffer,0
    .endif
    mov eax, dword[minutes]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall concatinate, result_buffer,COLOMN,result_buffer,0
    stdcall strclean, buffer
    .if dword[seconds] < 10
        stdcall concatinate, result_buffer,ZERO,result_buffer,0
    .endif
    mov eax, dword[seconds]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,20,margin_left, margin_top,left_header_width,margin_top+header_height,result_buffer,DT_RIGHT+DT_SINGLELINE+DT_VCENTER
    stdcall strclean, result_buffer

    stdcall concatinate, SCORE,space,result_buffer,1
    stdcall concatinate, result_buffer,COLOMN,result_buffer,0
    stdcall concatinate, result_buffer,space,result_buffer,0
    stdcall strclean, buffer
    mov eax, dword[score]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,20,left_header_width, margin_top,header_width,margin_top+header_height,result_buffer,DT_SINGLELINE+DT_CENTER+DT_VCENTER
    stdcall strclean, result_buffer
    
ret
endp

proc drawCPU

 

    local x1 dd margin_left
    local y1 dd margin_top+header_height+header_cpu_gap
    local x2 dd margin_left+square_size
    local y2 dd margin_top+header_height+header_cpu_gap+square_size
    
    ;local current_color dd ?
    ;local current_name dd ?
    mov esi, dword[CPU]
    mov edi,0

   
    .loopstart:
        .if word[esi+edi+process_on_CPU_offset] <> -1
            movzx eax, word[esi+edi+process_on_CPU_offset]
            stdcall DrawOneProcess,eax ,[x1],[y1],[x2],[y2]
            

        .else
            invoke CreatePen, PS_SOLID, 2, 0x00FFFFFF
            mov [hPen], eax
            invoke CreateSolidBrush, 0x00000000
            mov [hBrush], eax
            invoke SelectObject, [hDC], [hPen]
            invoke SelectObject, [hDC], [hBrush]
            invoke Rectangle, [hDC], [x1],[y1],[x2],[y2]
            stdcall strclean, buffer
            movzx eax, word[esi+edi]
            stdcall IntToStr, eax,buffer,0
            stdcall concatinate, CPUNAME,space,result_buffer,1
            stdcall concatinate, result_buffer,buffer,result_buffer,0
            stdcall MyDrawText, 0x00000000,0x00FFFFFF,20,[x1], [y1],[x2],[y2],result_buffer,DT_SINGLELINE+DT_CENTER+DT_VCENTER    
            invoke  DeleteObject, [hBrush]
            invoke  DeleteObject, [hPen]
        .endif

        add [x1],square_size+cpu_cpu_gap
        add [x2],square_size+cpu_cpu_gap
        
        add edi,CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart

ret
endp


proc DrawOneProcess uses edi esi ebx edx ecx, procname: dword, x1 : dword, y1: dword, x2: dword, y2: dword
    local current_color dd ?
    local textx1 dd ?
    local textx2 dd ?
    local texty1 dd ?
    local texty2 dd ?
    mov esi, dword[processes]
    stdcall GetEdi, [procname],process_offset
    movzx eax, word[esi+edi+hung_stage_offset]
    imul eax,4
    push edi
    mov edi, Colorarray         
    add edi,eax
    mov eax,[edi]
    mov [current_color], eax
    invoke CreateSolidBrush, eax
    pop edi
    mov [hBrush], eax
    invoke CreatePen, PS_SOLID, 2, [current_color]
    mov [hPen], eax
    ;invoke SelectObject, [hDC], [hBrush]
    invoke SelectObject, [hDC], [hPen]
    invoke SelectObject, [hDC], [hBrush]
    invoke Rectangle, [hDC], [x1],[y1],[x2],[y2]
    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]
    ; draw text
    mov eax, [x1]
    add eax,text_margin_left
    mov [textx1],eax
    mov eax, [x2]
    sub eax,text_margin_right
    mov [textx2],eax
    mov eax, [y1]
    add eax,text_margin_top
    mov [texty1],eax
    mov eax, [y2]
    sub eax,text_margin_bottom
    mov [texty2],eax
    
    stdcall strclean, buffer
    movzx eax, word[esi+edi]
    ;mov [current_name],eax
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, PID,space,result_buffer,1
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall MyDrawText, [current_color],0x00000000,15,[textx1],[texty1],[textx2],[texty2],result_buffer,DT_LEFT
    ;
    invoke  DeleteObject, [hPen]
    ;invoke CreateSolidBrush, 0x00000000
    ;mov [hBrush], eax
    ;invoke SelectObject, [hDC], [hBrush]


ret
endp


proc DrawMidPart
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,margin_left+5,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap ,left_header_width,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height,IDLE,DT_LEFT
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,left_header_width,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap ,header_width,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height,MEMPAGES,DT_LEFT
ret
endp


proc DrawProcesses
    local proc_in_raw dd 0
    local x1 dd margin_left
    local y1 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap
    local x2 dd margin_left+square_size
    local y2 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size
    
    mov esi, dword[processes]
    mov edi,0
    .loopstart:
        .if word[esi+edi+number_in_CPU_offset] = -1
            movzx eax, word[esi+edi]
            stdcall DrawOneProcess,eax ,[x1],[y1],[x2],[y2]
            inc dword[proc_in_raw]
            .if dword[proc_in_raw] = proc_in_raw_count
                mov dword[x1], margin_left
                mov dword[x2], margin_left+square_size
                add dword[y1], square_size+cpu_cpu_gap
                add dword[y2], square_size+cpu_cpu_gap
                mov dword[proc_in_raw],0
            .else
                add dword[x1],square_size+cpu_cpu_gap
                add dword[x2],square_size+cpu_cpu_gap
            .endif
        .endif
        
        
        

        add edi,process_offset
        cmp edi, dword[Process_size]
        jb .loopstart

ret
endp

proc DrawRam
    local proc_in_raw dd 0
    local x1 dd left_header_width
    local y1 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap
    local x2 dd left_header_width+page_width
    local y2 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+page_height
    local page_in_raw dd 0
    mov esi, dword[RAM]
    mov edi,0
    .loopstart:
        .if word[esi+edi+process_on_RAM_offset] <> -1
            movzx eax, word[esi+edi+process_on_RAM_offset]
            stdcall DrawOnePage, eax, [x1],[y1],[x2],[y2]
            ;stdcall DrawOneProcess,eax ,[x1],[y1],[x2],[y2]
            inc dword[page_in_raw]
            .if dword[page_in_raw] = pages_in_raw_count
                mov dword[x1], left_header_width
                mov dword[x2], left_header_width+page_width
                add dword[y1], page_height+page_page_gap
                add dword[y2], page_height+page_page_gap
                mov dword[page_in_raw],0
            .else
                add dword[x1],page_width+page_page_gap
                add dword[x2],page_width+page_page_gap
            .endif
        .endif

        add edi,RAM_offset
        cmp edi, dword[RAM_size]
        jb .loopstart
ret
endp

proc DrawOnePage uses edi esi ecx ebx edx,procname: dword, x1 : dword, y1: dword, x2: dword, y2: dword
    local textx1 dd ?
    local textx2 dd ?
    local texty1 dd ?
    local texty2 dd ?
    local currentcolor dd ?
    mov esi, dword[processes]
    stdcall GetEdi, [procname],process_offset
    .if word[edi+esi+number_in_CPU_offset] = -1
        mov dword[currentcolor],0x00808080 
        invoke CreateSolidBrush, dword[currentcolor]
        mov [hBrush], eax
        invoke CreatePen, PS_SOLID, 2, dword[currentcolor]
        mov [hPen], eax
        invoke SelectObject, [hDC], [hPen]
        invoke SelectObject, [hDC], [hBrush]
        invoke Rectangle, [hDC],[x1],[y1],[x2],[y2]
        
    .else
        mov dword[currentcolor],0x00FFFFFF 
        invoke CreateSolidBrush, dword[currentcolor]
        mov [hBrush], eax
        invoke CreatePen, PS_SOLID, 2, dword[currentcolor]
        mov [hPen], eax
    .endif
    
    invoke SelectObject, [hDC], [hPen]
    invoke SelectObject, [hDC], [hBrush]
    invoke Rectangle, [hDC],[x1],[y1],[x2],[y2]
    invoke  DeleteObject, [hPen]
    invoke  DeleteObject, [hBrush]

    ; draw text
    mov eax, [x1]
    add eax,textpage_margin_left
    mov [textx1],eax
    mov eax, [x2]
    sub eax,textpage_margin_right
    mov [textx2],eax
    mov eax, [y1]
    add eax,textpage_margin_top
    mov [texty1],eax
    mov eax, [y2]
    sub eax,textpage_margin_bottom
    mov [texty2],eax
    
    stdcall strclean, buffer
    movzx eax, word[esi+edi]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, PID,space,result_buffer,1
    stdcall concatinate, result_buffer,buffer,result_buffer,0
    stdcall MyDrawText, dword[currentcolor],0x00000000,10,[textx1],[texty1],[textx2],[texty2],result_buffer,DT_LEFT+DT_SINGLELINE+DT_VCENTER
    
ret
endp

proc DrawFootter uses ebx ecx edx esi edi

    stdcall strclean, buffer
    mov eax, dword[Reset_count]
    stdcall IntToStr, eax,buffer,0
    stdcall concatinate, PAGEQIUTS,buffer,result_buffer,1 
    stdcall concatinate, result_buffer,SLASH,result_buffer,0
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,20,margin_left,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap,left_header_width,margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap+header_height,result_buffer,DT_LEFT+DT_SINGLELINE+DT_VCENTER
    stdcall strclean, result_buffer
ret
endp


proc MyDrawText, bgcolor: dword,textcolor: dword,fontsize: dword,x1: dword, y1: dword, x2: dword, y2: dword, text: dword, pos: dword

    local rect RECT
    invoke SetBkColor, [hDC], [bgcolor] 
    invoke SetTextColor, [hDC], [textcolor]
    invoke CreateFont, [fontsize], 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, VARIABLE_PITCH+FF_ROMAN, Arial
    mov [hFont], eax 
    invoke  SelectObject, [hDC],eax
    mov eax, [x1]
    mov [rect.left], eax
    mov eax, [x2]
    mov [rect.right], eax
    mov eax, [y1]
    mov [rect.top], eax
    mov eax, [y2]
    mov [rect.bottom], eax
    lea ebx, [rect] 
    invoke DrawText, [hDC], [text], -1, ebx, [pos]
    invoke  DeleteObject, [hFont]
    ret
endp

proc DrawImage, image: dword, x: dword, y: dword, xsize: dword, ysize: dword
    invoke LoadImage, [hDC], [image], IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    mov [hImage], eax 
    invoke CreateCompatibleDC, [hDC]
    mov [hImageDC], eax
    mov eax,[hImage]
    invoke SelectObject, [hImageDC], eax
    invoke BitBlt, [hDC], [x], [y], [xsize], [ysize], [hImageDC], 0, 0, SRCCOPY
    invoke DeleteDC, [hImageDC]
    ret
endp

proc IntToStr uses edx ebx edi esi ecx, num, buf, startBufPos
    mov ebx, 10
    mov eax, [num]
    mov esi, [buf]
    add esi, [startBufPos]

    xor ecx, ecx
    .ConvertLoop:
        xor edx, edx
        div ebx
        add edx, '0'
        mov byte[esi], dl
        
        inc ecx
        inc esi

        cmp eax, 0
        
    jnz .ConvertLoop


    mov byte[esi], 0 ; zero terminated string 

    dec esi ; got last digit pos in string 
    mov edi, esi ; save last pos
    dec ecx
    sub esi, ecx ; got first digit pos in string
    .invertOrderLoop:
      cmp esi, edi 
      jge .stop

      mov al, byte[esi]
      mov ah, byte[edi]
      mov byte[esi], ah
      mov byte[edi], al

      inc esi 
      dec edi
      jmp .invertOrderLoop
      
    .stop:

  ret
endp