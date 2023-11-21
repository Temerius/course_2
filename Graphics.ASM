proc drawCPU

    local x1 dd margin_left
    local y1 dd margin_top+header_height+gap
    local x2 dd margin_left+square_size
    local y2 dd margin_top+header_height+gap+square_size
    local textx1 dd ?
    local textx2 dd ?
    local texty1 dd ?
    local texty2 dd ?
    local current_color dd ?
    ;local current_name dd ?
    mov esi, dword[CPU]
    mov edi,0
    invoke CreatePen, PS_SOLID, 2, 0x00FFFFFF
    mov [hPen], eax

   
    .loopstart:
        .if word[esi+edi+process_on_CPU_offset] <> -1
            movzx eax, word[esi+edi+process_on_CPU_offset]
            push esi
            push edi
            mov esi, dword[processes]
            stdcall GetEdi, eax,process_offset
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
            invoke SelectObject, [hDC], [hBrush]
            ;invoke CreatePen, PS_SOLID, 2, [current_color]
            ;mov [hPen], eax
            invoke Rectangle, [hDC], [x1],[y1],[x2],[y2]

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
            stdcall MyDrawText, [current_color],0x00000000,20,[textx1],[texty1],[textx2],[texty2],result_buffer,DT_LEFT
            ;
            invoke CreateSolidBrush, 0x00000000
            mov [hBrush], eax
            invoke SelectObject, [hDC], [hBrush]
            pop edi
            pop esi

        .else
            invoke SelectObject, [hDC], [hPen]
            invoke Rectangle, [hDC], [x1],[y1],[x2],[y2]    
        .endif

        add [x1],square_size+cpu_cpu_gap
        add [x2],square_size+cpu_cpu_gap
        
        add edi,CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart

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