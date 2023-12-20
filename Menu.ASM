proc DrawMainMenu uses edi esi ecx edx ebx

    local tmppen dd ?

    invoke CreateSolidBrush, 0x00000000
    mov [hBrush], eax
    invoke CreatePen, PS_SOLID, 3,0x00FFFFFF
    mov [hPen], eax
    invoke SelectObject, [hDCBuf], [hPen]
    invoke SelectObject, [hDCBuf], [hBrush]
    
    invoke CreatePen, PS_SOLID, 3,0x00808080
    mov [tmppen], eax


    stdcall MyDrawText, 0x00000000,0x00FF0000,60,Name_x, Name_y,Name_x+Name_width,Name_y+Name_height,Game_name,DT_SINGLELINE+DT_CENTER+DT_VCENTER

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Difficulty_x, Difficulty_y,Difficulty_x+Difficulty_width,Difficulty_y+Difficulty_height,SelectDifficulty,DT_SINGLELINE+DT_CENTER+DT_VCENTER


    invoke Rectangle, [hDCBuf], Play_x,Play_y,Play_x+Play_width,Play_y+Play_height

    .if word[Setting_name_index] = 0
        invoke SelectObject, [hDCBuf], [tmppen]
    .endif
        
    invoke Rectangle, [hDCBuf], Squares_x ,Squares_y,Squares_x+Squares_width,Squares_y+Squares_height

    invoke MoveToEx, [hDCBuf], Squares_x+Squares_width / 2 + 5, Squares_y+Squares_height / 2 - 15, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDCBuf],  Squares_x+Squares_width / 2 - 5, Squares_y+Squares_height / 2  
    invoke MoveToEx, [hDCBuf], Squares_x+Squares_width / 2 - 5, Squares_y+Squares_height / 2, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDCBuf],  Squares_x+Squares_width / 2 + 5, Squares_y+Squares_height / 2 + 15
    
    .if word[Setting_name_index] = 4
        invoke SelectObject, [hDCBuf], [tmppen]
    .else
        invoke SelectObject, [hDCBuf], [hPen]
    .endif
    
    invoke Rectangle, [hDCBuf], Squares_x+TextDifficulty_width+Squares_width ,Squares_y,Squares_x+TextDifficulty_width+Squares_width*2,Squares_y+Squares_height

    invoke MoveToEx, [hDCBuf], Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 - 5, Squares_y+Squares_height / 2 - 15, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDCBuf],  Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 + 5, Squares_y+Squares_height / 2  
    invoke MoveToEx, [hDCBuf], Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 + 5, Squares_y+Squares_height / 2, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDCBuf],  Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 - 5, Squares_y+Squares_height / 2 + 15

    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]
    invoke  DeleteObject, [tmppen]

    stdcall DrawSettingName

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Squares_x+Squares_width, Squares_y,Squares_x+Squares_width+TextDifficulty_width,Squares_y+Squares_height,buffer,DT_SINGLELINE+DT_CENTER+DT_VCENTER
 
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Play_x,Play_y,Play_x+Play_width,Play_y+Play_height,Play,DT_SINGLELINE+DT_CENTER+DT_VCENTER
    
ret
endp

proc DrawSettingName uses ecx ebx edx esi edi
    mov esi, Settings_name
    mov edx,0
    stdcall strclean, buffer
    .startloop:
        stdcall strlen,esi
        mov ecx,eax
        inc ecx
        .if dx <> word[Setting_name_index]
            inc edx
            add esi,ecx
            jmp .startloop
        .else
            mov edi, buffer
            rep movsb
            jmp .endloop
        .endif
    .endloop:

ret
endp

proc DrawAnima uses esi edi ecx ebx edx
    invoke GetTickCount
    mov ecx,eax
    mov ebx, dword[Time_for_new_anima]
    .if ebx <> 0
        push ecx
        sub ecx,ebx
        .if ecx >= 400
            mov edi, Anima
            mov esi, dword[Current_anima_offset]
            stdcall DrawImage,dword[edi+esi],0,0,dword[screen_width], dword[screen_height] 
            add esi,4
            .if esi >= 40
                mov esi,0
                
            .endif
            ;invoke Sleep, 400
            mov dword[Current_anima_offset],esi
            mov dword[Time_for_new_anima],0
        .endif
        pop ecx
    .else
        mov dword[Time_for_new_anima],ecx
    .endif

ret
endp
proc MenuClick uses ebx edx ecx esi edi
    mov edi, dword[mouseX]
    mov esi, dword[mouseY]

    stdcall IsInSquare, Squares_x ,Squares_y,Squares_x+Squares_width,Squares_y+Squares_height
    .if eax = 1
        .if word[Setting_name_index] <> 0
            dec word[Setting_name_index]
            
        .endif
        jmp .return
    .endif

    stdcall IsInSquare,  Squares_x+TextDifficulty_width+Squares_width ,Squares_y,Squares_x+TextDifficulty_width+Squares_width*2,Squares_y+Squares_height
    .if eax = 1
        .if word[Setting_name_index]  <> 4
            inc word[Setting_name_index]
        .endif
        jmp .return
    .endif

    stdcall IsInSquare,  Play_x,Play_y,Play_x+Play_width,Play_y+Play_height
    .if eax = 1
        mov dword[DRAWFLAG],2
        invoke GetTickCount
        mov dword[timer],eax
        stdcall SetSettings
        stdcall initialisation,[myheap]
        stdcall DrawBackColor
        
        jmp .return
    .endif
    
    .return:

    stdcall FulRect, 0x00000000, 0x00000000, Squares_x+Squares_width, Squares_y,Squares_x+Squares_width+TextDifficulty_width,Squares_y+Squares_height
    
    
ret
endp



proc SetSettings uses ebx ecx edx esi edi
    mov esi, SETTINGS
    movzx edi, word[Setting_name_index]
    add esi, edi
    add esi, edi
    movzx eax, word[esi]
    mov word[CPU_count],ax
    add esi, 10
    movzx eax, word[esi]
    mov word[Process_count],ax
    add esi, 10
    movzx eax, word[esi]
    mov word[RAM_lines_count],ax
ret
endp