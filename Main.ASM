
; TODO
;   Change image load
;   Change font
; Settings
  Width = 1400
  Height = 800
  R = 0
  G = 0
  B = 0

; Code
format PE GUI 4.0
entry start


macro switch value 
        { 
            mov eax, value 
        } 
  
macro case value, label  
        { 
            cmp eax, value 
            je label 
        }
include 'win32a.inc'



section '.text' code readable executable
  
  include './MACRO/IF.INC'

proc start

    invoke GetModuleHandle, 0
    mov [wc.hInstance], eax
    invoke LoadIcon, 0, IDI_APPLICATION
    mov [wc.hIcon], eax
    invoke LoadCursor, 0, IDC_ARROW
    mov [wc.hCursor], eax
    invoke RegisterClass, wc
    test eax, eax
    jz error

    invoke GetSystemMetrics, SM_CXSCREEN
    mov dword[screen_width],eax

    invoke GetSystemMetrics, SM_CYSCREEN
    mov dword[screen_height],eax

    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE  + WS_POPUP, 0, 0, dword[screen_width], dword[screen_height], NULL, NULL, [wc.hInstance], NULL
    mov [hwnd], eax
    invoke GetDC, [hwnd]
    mov [hDC], eax

    mov dword [myheap],0
    invoke GetProcessHeap
    mov dword[myheap], eax

    ; image
    invoke CreateCompatibleDC, [hDC]
    mov [hImageDC], eax

    stdcall DrawBackColor

    ;stdcall initialisation,[myheap]

    




    msg_loop:
        invoke GetMessage, msg, NULL, 0, 0
        cmp eax, 1
        jb end_loop
        jne msg_loop
        
        invoke TranslateMessage, msg
        invoke DispatchMessage, msg
        ;invoke SetDIBitsToDevice, [hDC], 0, 0, Width, Height, 0, 0, 0, Height, [heapMemory], bmi, 0
        jmp msg_loop

    invoke  ReleaseDC, [hwnd], [hDC]
    invoke  ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke  UpdateWindow, [hwnd]
    invoke DeleteDC, [hImageDC]
    error:
        invoke MessageBox, NULL, _error, NULL, MB_ICONERROR + MB_OK

    end_loop:
        invoke HeapFree, [myheap], 0, [heapMemory]

        invoke ExitProcess, [msg.wParam]


    ret
endp

proc DrawBackColor uses esi edi ebx ecx edx
    invoke CreatePen, PS_SOLID, 2,0x00000000
    mov [hPen], eax
    invoke CreateSolidBrush, 0x00000000 
    mov [hBrush], eax
    invoke SelectObject, [hDC], [hPen]
    invoke SelectObject, [hDC], [hBrush]
    invoke Rectangle, [hDC], 0,0,dword[screen_width],dword[screen_height] 
    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]

ret
endp
proc MainProc uses esi edi ebx edx ecx eax
        pusha
        stdcall drawCPU
        popa
        pusha
        stdcall isexecuted
        popa
        pusha
        stdcall DrawHeader
        popa
        pusha
        stdcall DrawMidPart
        popa
        pusha
        stdcall DrawProcesses
        popa
        pusha
        stdcall DrawPages,1
        popa
        pusha
        stdcall DrawDisk
        popa
        pusha
        stdcall DrawPages,2
        popa
        pusha
        stdcall DrawFootter
        popa
        pusha
        stdcall timeupdate
        popa
        pusha
        stdcall generateIO
        popa
ret
endp


proc DrawMainMenu uses edi esi ecx edx ebx

    local tmppen dd ?

    invoke CreateSolidBrush, 0x00000000
    mov [hBrush], eax
    invoke CreatePen, PS_SOLID, 3,0x00FFFFFF
    mov [hPen], eax
    invoke SelectObject, [hDC], [hPen]
    invoke SelectObject, [hDC], [hBrush]
    
    invoke CreatePen, PS_SOLID, 3,0x00808080
    mov [tmppen], eax


    stdcall MyDrawText, 0x00000000,0x00FF0000,60,Name_x, Name_y,Name_x+Name_width,Name_y+Name_height,Game_name,DT_SINGLELINE+DT_CENTER+DT_VCENTER

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Difficulty_x, Difficulty_y,Difficulty_x+Difficulty_width,Difficulty_y+Difficulty_height,SelectDifficulty,DT_SINGLELINE+DT_CENTER+DT_VCENTER


    invoke Rectangle, [hDC], Play_x,Play_y,Play_x+Play_width,Play_y+Play_height

    .if word[Setting_name_index] = 0
        invoke SelectObject, [hDC], [tmppen]
    .endif
        
    invoke Rectangle, [hDC], Squares_x ,Squares_y,Squares_x+Squares_width,Squares_y+Squares_height

    invoke MoveToEx, [hDC], Squares_x+Squares_width / 2 + 5, Squares_y+Squares_height / 2 - 15, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDC],  Squares_x+Squares_width / 2 - 5, Squares_y+Squares_height / 2  
    invoke MoveToEx, [hDC], Squares_x+Squares_width / 2 - 5, Squares_y+Squares_height / 2, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDC],  Squares_x+Squares_width / 2 + 5, Squares_y+Squares_height / 2 + 15
    
    .if word[Setting_name_index] = 4
        invoke SelectObject, [hDC], [tmppen]
    .else
        invoke SelectObject, [hDC], [hPen]
    .endif
    
    invoke Rectangle, [hDC], Squares_x+TextDifficulty_width+Squares_width ,Squares_y,Squares_x+TextDifficulty_width+Squares_width*2,Squares_y+Squares_height

    invoke MoveToEx, [hDC], Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 - 5, Squares_y+Squares_height / 2 - 15, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDC],  Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 + 5, Squares_y+Squares_height / 2  
    invoke MoveToEx, [hDC], Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 + 5, Squares_y+Squares_height / 2, NULL  ; Устанавливаем начальную точку
    invoke LineTo, [hDC],  Squares_x+TextDifficulty_width+ 3 * Squares_width / 2 - 5, Squares_y+Squares_height / 2 + 15

    invoke  DeleteObject, [hBrush]
    invoke  DeleteObject, [hPen]
    invoke  DeleteObject, [tmppen]

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

    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Squares_x+Squares_width, Squares_y,Squares_x+Squares_width+TextDifficulty_width,Squares_y+Squares_height,buffer,DT_SINGLELINE+DT_CENTER+DT_VCENTER
 
    stdcall MyDrawText, 0x00000000,0x00FFFFFF,40,Play_x,Play_y,Play_x+Play_width,Play_y+Play_height,Play,DT_SINGLELINE+DT_CENTER+DT_VCENTER
    
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
        jmp .return
    .endif
    
    .return:
    stdcall DrawBackColor
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
proc WindowProc uses ebx, hWnd, uMsg, wParam, lParam
   xor     ebx, ebx

                switch  [uMsg]
                case    WM_PAINT,       .onPaint0
                case    WM_DESTROY,     .onDestroy
                case    WM_KEYDOWN,     .onKeyDown0
                case    WM_LBUTTONDOWN, .onLClick0

                ; перечисляешь все события, которые обрабатываешь руками, здесь, в case. 
                ; destroy и paint оставляй как у меня

                ; вот эта ерундень обрабатывает остальное, что ты руками не обработал
                ; ВАЖНО!!! её оставить 
                invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]

                jmp     .Return
     
                ; после каждого РУКАМИ обработанного возвращаешь ноль (см конец)
                .onPaint0:
                        ; вызываешь ф-цию (больше для удобства), которая у тебя рисует 
                        ; что рисует (в моём случае это каждый кадр)
                    switch  [DRAWFLAG]
                    case    1,     .MenuPaint
                    case    2,     .MainPaint
                    case    3,     .PausePaint

                    .MenuPaint:
                        stdcall DrawMainMenu
                    jmp .end1
                    
                    .MainPaint:
                        stdcall MainProc
                    jmp .end1
                    
                    .PausePaint:

                    jmp .end1
                        

                    .end1:
                jmp     .ReturnZero

                .onKeyDown0:
                        switch [wParam]
                        case VK_ESCAPE, .onDestroy
                jmp     .ReturnZero


                .onLClick0:
                    mov eax, [lParam]
                    movsx ebx, ax
                    mov dword[mouseX], ebx
                    sar eax, 16 
                    mov dword[mouseY], eax

                    switch  [DRAWFLAG]
                    case    1,     .MenuClick
                    case    2,     .MainClick
                    case    3,     .PauseClick

                    .MenuClick:
                        stdcall MenuClick
                    jmp .end2
                    
                    .MainClick:
                        stdcall FindClick
                    jmp .end2
                    
                    .PauseClick:

                    jmp .end2

                    .end2:
                jmp     .ReturnZero

        ; ВАЖНО!!!!! эта штука завершает выполнение проги нормально
        ; не трожь, даже если не нравится 
        .onDestroy:
        invoke  ExitProcess, 0

        .ReturnZero:
        xor     eax, eax

        .Return:        
        ret
endp




proc realloc
    mov eax, dword[Real_process_size]
    shl eax,1
    mov dword[Real_process_size],eax
    invoke HeapReAlloc, dword[myheap], 0, dword[processes], eax
    mov dword[processes],eax
ret
endp



proc deletecells uses esi edi ebx edx ecx,name: dword
    mov esi, dword[RAM]
    mov edi,0
    mov eax , [name]
    .loopstart1:
        .if word[esi+edi+process_on_RAM_offset] = ax
            mov word[esi+edi+process_on_RAM_offset], -1
        .endif
        add edi,RAM_offset
        cmp edi, dword[RAM_size]
        jb .loopstart1
    
    
    mov esi, dword[DISK]
    mov edi,0
    .loopstart2:
        .if word[esi+edi+process_on_DISK_offset] = ax
            mov word[esi+edi+process_on_DISK_offset], -1
        .endif
        add edi,DISK_offset
        cmp edi, dword[DISK_size]
        jb .loopstart2

ret
endp
proc deleteprocess uses esi edi ebx edx ecx
    mov esi, dword[processes]
    movzx eax, word [esi+edi+proc_name_offset]
    stdcall deletecells, eax
    .if word[esi+edi+need_IO_offset] = 1
        dec dword[NeedIOCount]
    .endif
    mov word [esi+edi+proc_name_offset],-1
    ;;;;;;;;;;;;;;;;; call delete from ram and disk
    ret
endp

proc deletecpu uses esi edi ebx edx ecx
    mov esi, dword[CPU]
    movzx eax,word [esi+edi+cpu_proc_name_offset]
    stdcall deletecells, eax
    .if word[esi+edi+cpu_need_IO_offset] = 1
        dec dword[NeedIOCount]
    .endif
    mov word [esi+edi+cpu_proc_name_offset],-1
ret
endp
    ; comparator 1- newprocess 2 - from cpu
proc newprocess uses ecx ebx edx esi edi, comparator: dword, cpu_name: dword
    mov edi,0 ; offset in process array 
    mov esi, dword[processes]
    ; find process with name -1 to replace it with a new process
    .start_loop:

        .if word [esi+edi+proc_name_offset] = -1
            .if dword[comparator] = 1
                stdcall addprocess
            .else
                stdcall movcputoproc, dword[cpu_name]
            .endif
            jmp .func_end
        .endif

        add edi,process_offset
        cmp edi, dword [Process_size]
        jne .start_loop
    
    ; compare real size with doubled size
    mov eax, dword[Process_size]
    .if eax >= dword[Real_process_size]

        ; increase size
        stdcall realloc
    .endif
    stdcall addprocess
    add dword [Process_size],process_offset
.func_end:
ret
endp




proc GetEdi uses ebx, name: dword, offset: dword
    
    mov eax, dword [name]
    mov ebx, [offset]
    imul eax,ebx
    mov edi,eax
    ret
endp


; index - index disk or ram to delete
proc deletefromdiskram uses esi edi ecx edx ebx, index: dword, offset: dword, arr: dword
    stdcall GetEdi,[index],[offset]
    mov esi, dword[arr]
    mov word [esi+edi+tmp_offset],-1
ret
endp




proc generateIO
    push ecx
    mov edi,0
    mov esi, dword[CPU]
    movzx ecx, word[Random_probability]
    
    .loopstart:
        mov edx, 0
        .if word[esi+edi+cpu_proc_name_offset] <> -1
            .if word[esi+edi+cpu_hung_stage_offset] <> 0
                .if word[esi+edi+cpu_executed_offset] = 1
                    .if word[esi+edi+cpu_need_IO_offset] = 0
                        rdrand eax
                        div [Random_IOdelimiter]
                        inc edx
                        .if edx <= ecx
                            mov word[esi+edi+cpu_need_IO_offset],1
                            inc [NeedIOCount]
                        .endif
                    .endif
                .endif
            .endif
        .endif
        add edi, CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart
    pop ecx
ret
endp


proc isexecuted uses edi esi ecx ebx edx
    mov edi,0
    mov esi, dword[CPU]
    .loopstart:
        ; get process name from cpu
        movzx eax, word[esi+edi+cpu_proc_name_offset]
        .if ax <> -1
            stdcall isprocexecuted
        .endif
        add edi, CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart
ret
endp
proc isprocexecuted uses edi esi ecx ebx edx

    .if word[esi+edi+cpu_need_IO_offset] = 0
        stdcall diskcheck
    .else
        mov eax,0
    .endif

    mov word[esi+edi+cpu_executed_offset],ax


ret
endp

proc diskcheck uses esi edi ecx ebx edx
    
    movzx ecx, word[esi+edi+cpu_proc_name_offset]
    mov edi,0
    mov esi, dword[DISK]
    .loopstart:
        .if word[esi+edi+process_on_DISK_offset] = cx
            mov eax,0
            jmp .loopend
        .endif
        add edi, DISK_offset
        cmp edi, dword[DISK_size]
        jb .loopstart
    
    mov eax,1
    .loopend:

ret

endp

section '.idata' import data readable writeable
  library kernel32, 'KERNEL32.DLL',\
          user32, 'USER32.DLL',\
          gdi32, 'GDI32.DLL'

  ;import kernel32,\
         ;ExitProcess, 'ExitProcess',\
         ;GetTickCount, 'GetTickCount',\
         ;GetProcessHeap, 'GetProcessHeap',\
         ;HeapAlloc, 'HeapAlloc',\
         ;HeapReAlloc, 'HeapReAlloc',\
         ;HeapFree, 'HeapFree'

  ;import user32,\
         ;MessageBox, 'MessageBoxA'
  
  include 'api\kernel32.inc'
  include 'api\gdi32.inc'
  include 'api\user32.inc'
  include 'Graphics.ASM'
  include 'Ini.ASM'
  include 'Strings.ASM'
  include 'Time.ASM'
  include 'PushPop.ASM'
  include 'Click.ASM'
  include 'MainVariables.ASM'
  include 'MenuVariables.ASM'