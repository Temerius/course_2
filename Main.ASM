
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
    hImage dd ?
    hImageDC dd ?
    rect RECT
    
    bmi BITMAPINFOHEADER

    ; Define the variables for heap memory allocation
    heapMemory dd 0
    heapSize dd Width * Height * 4 ; 4 bytes per pixel (32-bit)


    CPU_count dw 6  ; variable for cpu count 
    RAMPages_count dw ? ; variable for rampages count
    RAM_lines_count dw 2
    DISKPages_count dw ? ; variable for diskpages count
    DISK_lines_count dw raw_count
    Process_count dw 10 ; variable for start process count 
    Process_size dd ? ; variable for the size off the process array
    Real_process_size dd ?
    Random_probability dw 1
    Random_IOdelimiter dw 10000
    Random_RAMdelimiter dw 4
    NeedIOCount dd 0

    processes dd ? ; address of the process array

    ; variables for process array offset  
    proc_name_offset = 2
    cells_count_offset = 4  ; ram sells count
    hung_stage_offset = 6   ; current hung stage
    downtime_offset = 8     ; miliseconds from downtime start
    finaltime_offset = 10   ; miliseconds from finaltime start
    need_IO_offset = 12     ; number from 1 to 100 if < Random_probability IO 
    downtime_tick_offset = 14   ; miliseconds from start system (from func gettickcount)
    was_on_CPU_offset = 18  ; flag was process on cpu (to add new cells on ram or not)
    process_offset = 20     ; final offset (size of cpu structure)
    ;


    tmp_offset = 2 ;;;;;;;;;;;;;


    CPU dd ?
    CPU_size dd ?
    cpu_proc_name_offset = 2    ; proc_name
    cpu_cells_count_offset = 4  ; ram sells count
    cpu_hung_stage_offset = 6   ; current hung stage
    cpu_uptime_offset = 8      ; miliseconds from uptime start
    cpu_downtime_offset = 10
    cpu_finaltime_offset = 12   ; miliseconds from finaltime start
    cpu_need_IO_offset = 14     ; number from 1 to 100 if < Random_probability IO 
    cpu_uptime_tick_offset = 16     ; miliseconds from start system (from func gettickcount)   
    cpu_downtime_tick_offset = 20
    cpu_executed_offset = 24    ; flag is process executed
    CPU_offset = 26

    RAM dd ?
    RAM_size dd ?
    process_on_RAM_offset = 2
    RAM_offset = 4

    DISK dd ?
    DISK_size dd ?
    process_on_DISK_offset = 2
    DISK_offset = 4

    current_name dw 0 ; curent name of process index
    Reset_count dd 0 ; current count for reset
    GAMEOVER=10 ; count for reset
    timer dd 0 ; current tick count
    time dd 0 
    newprocesstime dd 0
    seconds dd 0
    minutes dd 0
    hours dd 0
    score dd 0
    myheap dd 0 ; heap from getprocessheap
    
    
    TIME_FOR_NEW_PROCESS=10000
    TIME_FOR_NEXT_STAGE=6000
    TIME_FOR_BEREADY=12000
    TIME_FOR_REFRESH=4000

    ;FROOOOOOOOOOOOOOOOOOOOONT

    Colorarray dd 0x00fff046,0x0000ff00,0x0000FFFF,0x00008aFF,0x000808FF,0x000000A6,0x00250a41
    Smilesarray dd 0,0,0,0,0,0,0,0
    Hourglassesarray dd 0,0,0,0,0,0,0
    margin_top = 20
    margin_left = 30
    margin_right = 30
    margin_bottom = 10

    text_margin_top = 10
    text_margin_left = 30
    text_margin_right = 4
    text_margin_bottom = 45

    textpage_margin_top = 5
    textpage_margin_left = 2
    textpage_margin_right = 0
    textpage_margin_bottom = 15

    header_height = 40
    header_width = 1700
    left_header_width = 700
    right_header_width = 1000

    square_size = 75

    cpu_cpu_gap = 5
    header_cpu_gap = 15
    cpu_middle_gap = 15
    middle_process_gap = 15
    
    proc_foottername_gap = 30
    foottername_footterproc_gap = 5
    dead_dead_gap = 5
    page_page_gap = 5
    ram_disk_gap = 30
    disk_page_gap = 15
    

    page_width = 40
    page_height = 30

    proc_in_raw_count = 7
    pages_in_raw_count = 12
    raw_count = 10
  
    buffer db 16 dup (?)
    Arial db 'Arial', 0

    result_buffer db 256 dup (?) 
    PID db 'PID',0
    IOEVENTS db 'I/O EVENTS (',0
    IOEVENTSEND db ')',0
    UPTIME db 'Uptime',0
    SCORE db 'Score',0
    CPUNAME db 'CPU',0
    IDLE db 'Idle Processes :',0
    MEMPAGES db 'Memory Pages in RAM :',0
    DISKPAGES db 'Memory Pages on Disk :',0
    PAGEQIUTS db 'User Ragequits (',0
    SLASH db ' / 10) :',0
    COLOMN db ':',0
    space db ' ',0
    ZERO db '0',0

    PAGEQIUTS_X1 dd margin_left
    PAGEQIUTS_Y1 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap+header_height+foottername_footterproc_gap
    PAGEQIUTS_X2 dd margin_left+square_size
    PAGEQIUTS_Y2 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*5+cpu_cpu_gap*4+proc_foottername_gap+header_height+foottername_footterproc_gap+square_size

    DISKY1 dd margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap
    
    ;Gemoji db 'D:\BSUIR\ASSembly\course_2\images\cold_face_emoji.bmp', 0
    emoji0 db './images/smiling_face_with_halo_emoji.bmp', 0
    emoji1 db './images/grinning_face_emoji.bmp', 0
    emoji2 db './images/slightly_smiling_face_emoji.bmp', 0
    emoji3 db './images/neutral_face_emoji.bmp', 0
    emoji4 db './images/frowning_face_emoji.bmp', 0
    emoji5 db './images/loudly_crying_face_emoji.bmp', 0
    emoji6 db './images/cold_face_emoji.bmp', 0
    emoji7 db './images/skull_emoji.bmp', 0

    emoji8 db './images/hourglasses/0.bmp', 0
    hg db './images/hourglasses/', 0
    bmp db '.bmp',0

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

    mov dword [myheap],0
    invoke GetProcessHeap
    mov dword[myheap], eax

    ; image
    invoke CreateCompatibleDC, [hDC]
    mov [hImageDC], eax

    ; draw backgroundcolor
    invoke CreateSolidBrush, 0x00000000 
    mov [hBrush], eax
    invoke  SelectObject, [hDC],eax 
    invoke Rectangle, [hDC], 0,0,Width,Height 
    invoke  DeleteObject, [hBrush]


    stdcall initialisation,[myheap]

    invoke GetTickCount
    mov dword[timer],eax

    stdcall CPUpush,0

    stdcall CPUpush,2

    stdcall CPUpush,1
    stdcall CPUpush,3

    ;stdcall CPUpush,9
    stdcall CPUpop,0
    stdcall CPUpush,4
    stdcall CPUpush,0
    stdcall CPUpush,5
    stdcall CPUpop,5
    stdcall CPUpush,6
    stdcall CPUpop,5
    stdcall CPUpush,7
    stdcall CPUpop,5
    stdcall CPUpush,8
    stdcall CPUpop,5
    stdcall CPUpush,9
    stdcall CPUpop,5
    stdcall CPUpush,4
    ;  main loop

    mov ecx,100000
    time_loop:
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

        msg_loop:
            invoke GetMessage, msg, NULL, 0, 0
            cmp eax, 1
            jb end_loop
            jne .continue
  
            invoke TranslateMessage, msg
            invoke DispatchMessage, msg

            jmp .continue
        .continue:
            jmp time_loop

        invoke  ReleaseDC, [hwnd], [hDC]
        invoke  ShowWindow, [hwnd], SW_SHOWNORMAL
        invoke  UpdateWindow, [hwnd]
        invoke DeleteDC, [hImageDC]
           

    

        ;invoke SetDIBitsToDevice, [hDC], 0, 0, Width, Height, 0, 0, 0, Height, [heapMemory], bmi, 0
        

    error:
        invoke MessageBox, NULL, _error, NULL, MB_ICONERROR + MB_OK

    end_loop:
        invoke HeapFree, [myheap], 0, [heapMemory]
        invoke DeleteDC, [hImageDC]
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
    movzx eax,word [esi+edi+proc_name_offset]
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
    mov dword [esi+edi+tmp_offset],-1
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