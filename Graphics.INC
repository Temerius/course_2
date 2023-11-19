proc drawCPU

    local x1 dd margin_left
    local y1 dd margin_top+header_height+gap
    local x2 dd margin_left+square_size
    local y2 dd margin_top+header_height+gap+square_size
    mov esi, dword[CPU]
    mov edi,0
    invoke CreatePen, PS_SOLID, 2, 0x00FFFFFF
    mov [hPen], eax

    
    .loopstart:
        .if word[esi+edi+process_on_CPU_offset] > -1
            movzx eax, word[esi+edi+process_on_CPU_offset]
            push esi
            push edi
            
            mov esi, dword[processes]
            stdcall GetEdi, eax,process_offset
            movzx eax, word[esi+edi+hung_stage_offset]
            imul eax,4
            mov edi, Colorarray         ;ediiiiiiiiiiiii!!!!!!!!
            add edi,eax
            invoke CreateSolidBrush, edi
            mov [hBrush], eax
            invoke SelectObject, [hDC], [hBrush]
            
            pop edi
            pop esi
        .else
            invoke SelectObject, [hDC], [hPen]

           
        .endif

        ;invoke Rectangle, [hDC], [x],[y],[x]+square_size,[y]+square_size
        invoke Rectangle, [hDC], [x1],[y1],[x2],[y2]
        add [x1],square_size+cpu_cpu_gap
        add [x2],square_size+cpu_cpu_gap
        add edi,CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart

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