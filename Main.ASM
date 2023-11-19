
; Settings
  Width = 1400
  Height = 800
  R = 0
  G = 0
  B = 0

; Code
format PE GUI 4.0
entry start
include 'win32a.inc'

section '.data' data readable writeable
    _class TCHAR 'FASMWIN32', 0
    _title TCHAR 'GDI32 Test', 0
    _error TCHAR 'Startup failed.', 0

    wc WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class

    msg MSG
    hDC dd 0
    hwnd dd 0
    hBrush dd ?
    hPen dd ?
    hFont dd ?
    rect RECT
    
    bmi BITMAPINFOHEADER

    ; Define the variables for heap memory allocation
    heapMemory dd 0
    heapSize dd Width * Height * 4 ; 4 bytes per pixel (32-bit)


    CPU_count dw 4  ; variable for cpu count 
    RAMPages_count dw 32 ; variable for rampages count
    DISKPages_count dw 16 ; variable for diskpages count
    Process_count dw 8 ; variable for start process count 
    Process_size dd ? ; variable for the size off the process array
    Real_process_size dd ?
    Random_probability dw 20
    Random_IOdelimiter dw 100
    Random_RAMdelimiter dw 4

    processes dd ? ; address of the process array

    ; variables for process array offset  
    number_in_CPU_offset = 2    ; cpu name
    cells_count_offset = 4  ; ram sells count
    hung_stage_offset = 6   ; current hung stage
    downtime_offset = 8     ; miliseconds from downtime start
    uptime_offset = 10      ; miliseconds from uptime start
    finaltime_offset = 12   ; miliseconds from finaltime start
    need_IO_offset = 14     ; number from 1 to 100 if < Random_probability IO 
    downtime_tick_offset = 16   ; miliseconds from start system (from func gettickcount)
    uptime_tick_offset = 20     ; miliseconds from start system (from func gettickcount)   
    executed_offset = 24    ; flag is process executed
    was_on_CPU_offset = 26  ; flag was process on cpu (to add new cells on ram or not)
    process_offset = 28     ; final offset (size of cpu structure)
    ;



    tmp_offset = 2 ;;;;;;;;;;;;;


    CPU dd ?
    CPU_size dd ?
    process_on_CPU_offset = 2
    CPU_offset = 4

    RAM dd ?
    RAM_size dd ?
    process_on_RAM_offset = 2
    RAM_offset = 4

    DISK dd ?
    DISK_size dd ?
    process_on_DISK_offset = 2
    DISK_offset = 4

    current_name dw 0 ; curent name of process index
    Reset_count db 0 ; current count for reset
    GAMEOVER=10 ; count for reset
    timer dd 0 ; current tick count
    myheap dd 0 ; heap from getprocessheap

    TIME_FOR_NEW_PROCESS=20000
    TIME_FOR_NEXT_STAGE=6000
    TIME_FOR_BEREADY=25000
    TIME_FOR_REFRESH=4000

    ;FROOOOOOOOOOOOOOOOOOOOONT

    Colorarray dd 0x00009999,0x0000CC00,0x00FFFF00,0x00FFB700,0x00FF0000,0x00A60000,0x004f0500

    margin_top = 10
    margin_left = 30
    margin_right = 30
    margin_bottom = 10

    header_height = 30
    cpu_cpu_gap = 5
    gap = 5
    square_size = 50

    formatString db 'PID %d', 0
    number dd 2




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

    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE + WS_DLGFRAME + WS_SYSMENU, 0, 0, Width, Height, NULL, NULL, [wc.hInstance], NULL
    mov [hwnd], eax
    invoke GetDC, [hwnd]
    mov [hDC], eax
    ;mov [bmi.biSize], sizeof.BITMAPINFOHEADER
    ;mov [bmi.biWidth], Width
    ;mov [bmi.biHeight], Height
    ;mov [bmi.biPlanes], 1
    ;mov [bmi.biBitCount], 32
    ;mov [bmi.biCompression], BI_RGB

    mov dword [myheap],0
    invoke GetProcessHeap
    mov dword[myheap], eax

    ;invoke HeapAlloc, [myheap], HEAP_ZERO_MEMORY, [heapSize]
    ;test eax, eax
    ;jz error
    ;mov [heapMemory], eax

    ;mov edi, [heapMemory]
    ;mov ecx, Width * Height
    ;mov eax, (B shl 16) + (G shl 8) + R
    ;rep stosd


    invoke CreateSolidBrush, 0x00000000 
    mov [hBrush], eax
    invoke  SelectObject, [hDC],eax 
    invoke Rectangle, [hDC], 0,0,Width,Height
    
    
    
    invoke  DeleteObject, [hBrush]

    ;invoke CreateFont, 16, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, VARIABLE_PITCH or FF_ROMAN, 'Arial'
    
    ;invoke CreateFontIndirect, lf
    ;mov [hFont], eax
    ;invoke SelectObject, [hDC], eax

    ; Форматируем строку
    mov eax, number
    mov ebx, formatString
    invoke wsprintf, ebx, formatString, eax

    ; Рисуем текст
    invoke TextOut, [hDC], 10, 10, ebx, eax
    
    ;mov [rect.left], 100
    ;mov [rect.right], 500
    ;mov [rect.top], 200
    ;mov [rect.bottom], 500
    ;lea eax, [rect] 
    ;invoke FillRect, [hDC], eax, [hBrush]
    ;invoke CreateSolidBrush, 0x0000FF00 
    ;mov [hBrush], eax
    ;invoke  SelectObject, [hDC],eax 
    ;invoke  Ellipse, [hDC], 250, 50, 400, 200
    ;invoke Rectangle, [hDC], 250,250,500,500, 0x0066D7D1
   
    

    stdcall initialisation,[myheap]

    stdcall drawCPU
    invoke  ReleaseDC, [hwnd], [hDC]

    invoke  ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke  UpdateWindow, [hwnd]


    ; timer start

    invoke GetTickCount

    mov dword[timer],eax
    ;

    ; main loop
    mov ecx,0
    stdcall CPUpush,ecx
    ;time_loop:

        stdcall timeupdate
        stdcall generateIO
        ;jmp time_loop

    msg_loop:
        invoke GetMessage, msg, NULL, 0, 0
        cmp eax, 1
        jb end_loop
        jne msg_loop
        
        invoke TranslateMessage, msg
        invoke DispatchMessage, msg
        ;invoke SetDIBitsToDevice, [hDC], 0, 0, Width, Height, 0, 0, 0, Height, [heapMemory], bmi, 0
        jmp msg_loop

    error:
        invoke MessageBox, NULL, _error, NULL, MB_ICONERROR + MB_OK

    end_loop:
        invoke HeapFree, [myheap], 0, [heapMemory]

        invoke ExitProcess, [msg.wParam]


    ret
endp



proc WindowProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
  cmp [wmsg], WM_DESTROY
  je .wmdestroy
  .defwndproc:
  invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
  jmp .finish
  .wmdestroy:
  invoke PostQuitMessage, 0
  xor eax, eax
  .finish:
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


proc deleteprocess
    mov esi,dword[processes]
    mov word [esi+edi],-1
    ;;;;;;;;;;;;;;;;; call delete from ram and disk
    ret
endp
proc newprocess
    mov edi,0 ; offset in process array 
    mov esi,dword[processes]
    ; find process with name -1 to replace it with a new process
    .start_loop:

        .if word [esi+edi] = -1

            stdcall addprocess
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


proc timeupdate
    mov esi,dword[processes]
    invoke GetTickCount
    push eax
    sub eax, dword [timer]
    cmp eax,TIME_FOR_NEW_PROCESS
    jb loop_prepare
    
        ; call create new process
        stdcall newprocess
    
    loop_prepare:
    pop eax
    mov edi,0 ; offset in process array
    time_loopstart:
        .if word [esi+edi] <> -1
            .if word [esi+edi+executed_offset] <> 0
                mov dword [esi+edi+downtime_tick_offset],0
                .if dword [esi+edi+uptime_tick_offset] > 0
                    push eax
                    sub eax,dword [esi+edi+uptime_tick_offset]
                    add word [esi+edi+uptime_offset],ax
                    add word [esi+edi+finaltime_offset],ax
                    pop eax
                    .if word [esi+edi+uptime_offset] >= TIME_FOR_REFRESH
                        mov word [esi+edi+hung_stage_offset],1
                        mov word [esi+edi+uptime_offset],0
                    .endif
                    .if word [esi+edi+finaltime_offset] >= TIME_FOR_BEREADY
                        stdcall deleteprocess
                    .endif
                .endif
                mov dword [esi+edi+uptime_tick_offset],eax
            .else 
                mov dword [esi+edi+uptime_tick_offset],0 
                .if dword [esi+edi+downtime_tick_offset] > 0
                    push eax
                    sub eax, dword [esi+edi+downtime_tick_offset]
                    add word [esi+edi+downtime_offset],ax
                    pop eax
                    .if word [esi+edi+downtime_offset] >= TIME_FOR_NEXT_STAGE
                        add word [esi+edi+hung_stage_offset],1
                        .if word [esi+edi+hung_stage_offset] = 7
                            
                            stdcall deleteprocess
                            inc [Reset_count]
                            .if [Reset_count] = GAMEOVER
                                ; game over
                                invoke ExitProcess, 0
                            .endif
                        .endif                             
                        and bx,0 ;;;;;;;;;;;
                        mov bx, word [esi+edi+hung_stage_offset];;;;;;for dbg
                        mov word [esi+edi+downtime_offset],0
                    .endif
                .endif
                mov dword [esi+edi+downtime_tick_offset],eax
            .endif
        .endif

        add edi,process_offset
        cmp edi, dword [Process_size]
        jne time_loopstart

ret
endp

proc GetEdi, name: dword, offset: dword
    mov eax, dword [name]
    mov ebx, [offset]
    imul eax,ebx
    mov edi,eax
    ret
endp

proc deletefromdiskram, index: dword, offset: dword, arr: dword
    stdcall GetEdi,[index],[offset]
    mov esi, dword[arr]
    mov dword [esi+edi+tmp_offset],-1
ret
endp


; comparator2 push on 1 - ram, 2 - disk
; comparator1 if <> -1 - index of ram or disk to delete; depends on comparator2 
proc diskrampush, process_topush: dword , comparator1: dword, comparator2: dword
    locals
        arr1 dd ?
        size1 dd ?
        offset1 dd ?
        arr2 dd ?
        offset2 dd ?
    endl
    push ecx ; save currentcellcount for function
    .if [comparator2] = 1
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

    mov esi, dword[arr1]
    mov edi, 0
    mov ecx, [process_topush]
    .loopstart:
        .if word[esi+edi+tmp_offset] = -1
            mov word[esi+edi+tmp_offset],cx
            jmp .endloop
        .else
            add edi,[offset1]
            cmp edi, dword [size1]
            jne .loopstart
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

proc RAMpush_process, process_topush: dword
    locals
        currentcount dw 0
    endl
    mov cx, word[esi+edi+cells_count_offset]
    .loopstart:

        stdcall diskrampush, [process_topush],-1,1
        .if eax = -1
            stdcall diskrampush, [process_topush],-1,2
        .endif
        inc [currentcount]
        cmp [currentcount],cx
        jb .loopstart
    ret
endp


proc CPUpush, process_topush: dword

    stdcall GetEdi, [process_topush],process_offset
    mov esi, dword[processes]
    .if word[esi+edi+number_in_CPU_offset] = -1
        push esi
        push edi
        mov esi, dword[CPU]
        mov edi, 0
        .start_loop:
            .if word[esi+edi+process_on_CPU_offset] <> -1
                add edi,CPU_offset
                .if edi < dword[CPU_size]
                    jmp .start_loop
                .endif
            .endif
        .if edi < dword[CPU_size]
            mov eax,[process_topush]
            mov word[esi+edi+process_on_CPU_offset],ax
            mov ax , word[esi+edi]
            pop edi
            pop esi
            mov word[esi+edi+number_in_CPU_offset],ax
            .if word[esi+edi+was_on_CPU_offset] = 0
                stdcall RAMpush_process,[process_topush]
                mov word[esi+edi+was_on_CPU_offset],1
            .endif  
        .else
            mov eax,-1
            pop edi
            pop esi 
        .endif
    .else 
        mov eax,-2
    .endif

    ret
endp

proc CPUpop, process_topop: dword
    stdcall GetEdi, [process_topop],CPU_offset
    mov esi,dword [CPU]
    mov cx,word[esi+edi+process_on_CPU_offset]
    mov word[esi+edi+process_on_CPU_offset],-1
    movzx ecx,cx
    stdcall GetEdi, ecx,process_offset
    mov esi, dword[processes]
    mov word[esi+edi+number_in_CPU_offset],-1
ret
endp


proc generateIO
    push ecx
    mov edi,0
    mov esi, dword[processes]
    movzx ecx, word[Random_probability]
    
    .loopstart:
        mov edx, 0
        .if word[esi+edi+number_in_CPU_offset] <> -1
            .if word[esi+edi+need_IO_offset] = 0
                rdrand eax
                div [Random_IOdelimiter]
                inc edx
                .if edx <= ecx
                    mov word[esi+edi+need_IO_offset],1
                .endif
            .endif
        .endif
        add edi, process_offset
        cmp edi, dword[Process_size]
        jb .loopstart
    pop ecx
ret
endp

proc isexecuted
    mov edi,0
    mov esi, dword[CPU]
    .loopstart:
        ; get process name from cpu
        movzx eax, word[esi+edi]
        .if ax <> -1
            stdcall isprocexecuted, eax
        .endif
        add edi, CPU_offset
        cmp edi, dword[CPU_size]
        jb .loopstart
ret
endp
proc isprocexecuted, process_tocheck: dword
    push edi
    push esi
    stdcall GetEdi,[process_tocheck],process_offset
    mov esi, dword[processes]
    .if word[esi+edi+need_IO_offset] = 0
        stdcall diskcheck, [process_tocheck]
    .else
        mov eax,0
    .endif

    mov word[esi+edi+executed_offset],ax
    pop esi
    pop edi

ret
endp

proc diskcheck, processname: dword
    push ecx
    push edi
    push esi
    
    mov ecx, dword[processname]
    mov edi,0
    mov esi, dword[DISK]
    .loopstart:
        .if word[esi+edi+process_on_DISK_offset] = ecx
            mov eax,0
            jmp .loopend
        .endif
        add edi, DISK_offset
        cmp edi, dword[DISK_size]
        jb .loopstart
    
    mov eax,1
    .loopend:
    pop esi
    pop edi
    pop ecx
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
  include 'Graphics.INC'
  include 'Ini.INC'