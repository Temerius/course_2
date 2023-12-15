
; TODO
;   Change image load
;   Change font
; Settings
; dead process 700
; morganie
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
    mov [hDCMain], eax

  invoke CreateCompatibleDC, [hDCMain]  
  mov [hDCBuf], eax  
  invoke CreateCompatibleBitmap, [hDCMain], [screen_width], [screen_height] 
  invoke SelectObject, [hDCBuf], eax


    ; image
    invoke CreateCompatibleDC, [hDCBuf]
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
        ;invoke SetDIBitsToDevice, [hDCBuf], 0, 0, Width, Height, 0, 0, 0, Height, [heapMemory], bmi, 0
        jmp msg_loop

    invoke  ReleaseDC, [hwnd], [hDCBuf]
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
    invoke SelectObject, [hDCBuf], [hPen]
    invoke SelectObject, [hDCBuf], [hBrush]
    invoke Rectangle, [hDCBuf], 0,0,dword[screen_width],dword[screen_height] 
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
        .if dword[PAUSEFLAG]=0
            pusha
            stdcall timeupdate
            popa
            pusha
            stdcall generateIO
            popa
        .endif
ret
endp



proc SetDefault uses ebx ecx edx esi edi
    invoke HeapFree, [myheap], 0, [heapMemory]
    mov word[current_name],0
    mov dword[Reset_count],0
    mov dword[seconds],0
    mov dword[minutes],0
    mov dword[hours],0
    mov dword[score],0
    mov dword[PAGEQIUTS_X1], margin_left
    mov dword[PAGEQIUTS_Y1], margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap+header_height+foottername_footterproc_gap
    mov dword[PAGEQIUTS_X2], margin_left+square_size
    mov dword[PAGEQIUTS_Y2], margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap+header_height+foottername_footterproc_gap+square_size
    mov dword[DISKY1], margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap
ret
endp
proc WindowProc uses ebx, hWnd, uMsg, wParam, lParam
   xor ebx, ebx

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
            stdcall DrawPause
        jmp .end1
            

        .end1:
    jmp     .ReturnZero

    .onKeyDown0:
            switch [wParam]
            case VK_ESCAPE, .onDestroy
            case VK_SPACE, .onSpace
    jmp     .ReturnZero

    .onSpace:
        .if dword[DRAWFLAG] = 2
            .if dword[PAUSEFLAG] = 0
                mov dword[PAUSEFLAG],1
            .else
                stdcall UpdateAllTime
                mov dword[PAUSEFLAG],0
            .endif
        .endif
        jmp .end2
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
        jmp .end2

        .MenuClick:
            stdcall MenuClick
        jmp .end2
        
        .MainClick:
            .if dword[PAUSEFLAG] = 0
                stdcall FindClick
            .endif
        jmp .end2
        
        .PauseClick:
            stdcall PauseClick
        jmp .end2

        .end2:
    jmp     .ReturnZero

    ; ВАЖНО!!!!! эта штука завершает выполнение проги нормально
    ; не трожь, даже если не нравится 
    .onDestroy:
        .if dword[DRAWFLAG] = 2
            mov dword[PAUSEFLAG],1
            mov dword[DRAWFLAG],3
        .else
            .if dword[DRAWFLAG]= 3
                mov dword[PAUSEFLAG], 0
                mov dword[DRAWFLAG],2
                stdcall UpdateAllTime
                stdcall FulRect, 0x00000000, 0x00000000,0,0, dword[screen_width], 650
            .else
                .if dword[DRAWFLAG]=1
                    invoke  ExitProcess, 0
                .endif
            .endif
        .endif
    .ReturnZero:
    xor     eax, eax
    
    invoke BitBlt, [hDCMain], 0, 0, [screen_width], [screen_height], [hDCBuf], 0, 0, SRCCOPY
    
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
  include 'Menu.ASM'
  include 'PauseVariables.ASM'
  include 'Pause.ASM'