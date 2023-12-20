proc DrawPause uses ebx ecx edx esi edi

    stdcall DrawImage,dword[pause_descriptor],450,125,dword[screen_width], dword[screen_height] 
    
    invoke CreateSolidBrush, 0x00000000
    mov [hBrush], eax
    invoke CreatePen, PS_SOLID, 3,0x00FFFFFF
    mov [hPen], eax
    invoke SelectObject, [hDCBuf], [hPen]
    invoke SelectObject, [hDCBuf], [hBrush]

    invoke Rectangle, [hDCBuf], Square_x,Square1_y,Square_x+Square_width,Square1_y+Square_height

    invoke Rectangle, [hDCBuf], Square_x,Square2_y,Square_x+Square_width,Square2_y+Square_height

    invoke Rectangle, [hDCBuf], Square_x,Square3_y,Square_x+Square_width,Square3_y+Square_height
    
    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Square_x,Square1_y,Square_x+Square_width,Square1_y+Square_height,RESTART_GAME,DT_SINGLELINE+DT_CENTER+DT_VCENTER
 
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Square_x,Square2_y,Square_x+Square_width,Square2_y+Square_height,MAIN_MENU,DT_SINGLELINE+DT_CENTER+DT_VCENTER

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Square_x,Square3_y,Square_x+Square_width,Square3_y+Square_height,CONTINUE,DT_SINGLELINE+DT_CENTER+DT_VCENTER

ret
endp

proc PauseClick uses ebx edx ecx esi edi
    mov edi, dword[mouseX]
    mov esi, dword[mouseY]

    stdcall IsInSquare, Square_x ,Square1_y,Square_x+Square_width,Square1_y+Square_height
    .if eax = 1
        mov dword[DRAWFLAG],2
        mov dword[PAUSEFLAG],0
        stdcall SetDefault
        invoke GetTickCount
        mov dword[timer],eax
        
        stdcall initialisation,[myheap]
        stdcall DrawBackColor
        jmp .return
    .endif

    stdcall IsInSquare, Square_x ,Square2_y,Square_x+Square_width,Square2_y+Square_height
    .if eax = 1
        mov dword[DRAWFLAG],1
        mov dword[PAUSEFLAG],0
        stdcall SetDefault
        stdcall DrawBackColor
        jmp .return
    .endif

    stdcall IsInSquare, Square_x ,Square3_y,Square_x+Square_width,Square3_y+Square_height
    .if eax = 1
        mov dword[DRAWFLAG],2
        mov dword[PAUSEFLAG],0
        stdcall UpdateAllTime
        ;stdcall FulRect, 0x00000000, 0x00000000,Square_x,Square1_y, Square_x+Square_width+5,Square1_y+Square_height*3+5
        stdcall FulRect, 0x00000000, 0x00000000,0,0, 1700,700
        jmp .return
    .endif
    
    .return:
    
    
ret
endp