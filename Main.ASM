
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
    Random_IOdelimiter dw 1000
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
    Smilesarray dd 0,0,0,0,0,0,0
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

    ; IMAGE
    ;invoke LoadImage, [hDC], Gemoji, IMAGE_BITMAP, 0, 0,LR_DEFAULTCOLOR+LR_DEFAULTSIZE+LR_LOADFROMFILE
    ;mov [hImage], eax
    ;invoke CreateCompatibleDC, [hDC]
    ;mov [hImageDC], eax
    ;mov eax,[hImage]
    ;invoke SelectObject, [hImageDC], eax
    ;invoke BitBlt, [hDC], 500, 500, 30, 30, [hImageDC], 0, 0, SRCCOPY
    ;invoke DeleteDC, [hImageDC]

    ; IMAGE

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

    fnop
    mov ecx,100000
    time_loop:
        ;.if dword[time] = 0
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

        ;.endif
        pusha
        stdcall timeupdate
        popa
        pusha
        stdcall generateIO
        popa
        loop time_loop
        ;jmp time_loop
    invoke  ReleaseDC, [hwnd], [hDC]

    invoke  ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke  UpdateWindow, [hwnd]
    invoke DeleteDC, [hImageDC]


    ; timer start

    
    ;

    

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


proc timeupdate
    local newtimetick dd 0
    
    invoke GetTickCount
    mov dword [newtimetick],eax
    sub eax, dword [timer]
    add dword[time], eax
    .if [time] > 1000
        inc dword[seconds]
        inc dword[score]
        mov [time],0
        .if dword[seconds] = 60
            inc dword[minutes]
            mov dword[seconds],0
            .if dword[minutes] = 60
                inc dword[hours]
                mov dword[minutes],0
            .endif
        .endif
    .endif
    mov eax, dword[newtimetick]
    sub eax, dword[timer]
    add dword[newprocesstime],eax
    cmp [newprocesstime],TIME_FOR_NEW_PROCESS
    jb loop_prepare
        mov dword[newprocesstime],0
        ; call create new process
        stdcall newprocess,1,0
    
    loop_prepare:
    pop eax
    mov dword[timer],eax
    mov esi,dword[processes]
    mov edi,0 ; offset in process array
    .time_loopstart:
        .if word [esi+edi+proc_name_offset] <> -1
            .if dword [esi+edi+downtime_tick_offset] > 0
                mov eax, dword [newprocesstime]
                sub eax, dword [esi+edi+downtime_tick_offset]
                add word [esi+edi+downtime_offset],ax
                
                .if word [esi+edi+downtime_offset] >= TIME_FOR_NEXT_STAGE
                    add word [esi+edi+hung_stage_offset],1
                    .if word [esi+edi+hung_stage_offset] = 7
                        movzx eax, word [esi+edi+proc_name_offset]
                        stdcall DrawDead, eax
                        stdcall deleteprocess
                        
                        inc [Reset_count]
                        .if [Reset_count] = GAMEOVER
                            ; game over
                            invoke ExitProcess, 0
                        .endif
                    .endif                             
                    mov word [esi+edi+downtime_offset],0
                .endif
            .endif
            mov eax, dword [newprocesstime]
            mov dword [esi+edi+downtime_tick_offset],eax
        .endif

        add edi,process_offset
        cmp edi, dword [Process_size]
        jne .time_loopstart

    mov esi,dword[CPU]
    mov edi,0 ; offset in process array
    .time_loopstart2:
        .if word[esi+edi+cpu_proc_name_offset] <> -1
            .if word [esi+edi+cpu_executed_offset] <> 0
                    .if dword [esi+edi+cpu_uptime_tick_offset] > 0 ; need to check hungstage
                        mov eax, dword [timer]
                        sub eax, dword [esi+edi+cpu_uptime_tick_offset]
                        
    
                        .if word [esi+edi+cpu_hung_stage_offset] > 1
                            add word [esi+edi+cpu_uptime_offset],ax
                            .if word [esi+edi+cpu_uptime_offset] >= TIME_FOR_REFRESH
                                mov word [esi+edi+cpu_hung_stage_offset],1
                                mov word [esi+edi+cpu_uptime_offset],0
                            .endif
                        .else
                            .if word [esi+edi+cpu_hung_stage_offset] = 1
                                add word [esi+edi+cpu_finaltime_offset],ax
                                .if word [esi+edi+cpu_finaltime_offset] >= TIME_FOR_BEREADY
                                    ;stdcall deleteprocess ; another part
                                    mov word[esi+edi+cpu_hung_stage_offset],0
                                .endif
                            .endif
                        .endif
                        
                    .endif
                    mov eax, dword [timer]
                    mov dword [esi+edi+cpu_uptime_tick_offset],eax
            .else
                .if dword [esi+edi+cpu_downtime_tick_offset] > 0
                    mov eax, dword [newprocesstime]
                    sub eax, dword [esi+edi+cpu_downtime_tick_offset]
                    add word [esi+edi+cpu_downtime_offset],ax
                    
                    .if word [esi+edi+cpu_downtime_offset] >= TIME_FOR_NEXT_STAGE
                        add word [esi+edi+cpu_hung_stage_offset],1
                        .if word [esi+edi+cpu_hung_stage_offset] = 7
                            movzx eax, word [esi+edi+cpu_proc_name_offset]
                            stdcall DrawDead, eax
                            stdcall deletecpu
                            inc [Reset_count]
                            .if [Reset_count] = GAMEOVER
                                ; game over
                                invoke ExitProcess, 0
                            .endif
                        .endif                             
                        mov word [esi+edi+cpu_downtime_offset],0
                    .endif
                .endif
                mov eax, dword [newprocesstime]
                mov dword [esi+edi+cpu_downtime_tick_offset],eax
            .endif
        .endif
        add edi,CPU_offset
        cmp edi, dword [CPU_size]
        jne .time_loopstart2


        
ret
endp

proc GetEdi uses ebx, name: dword, offset: dword
    
    mov eax, dword [name]
    mov ebx, [offset]
    imul eax,ebx
    mov edi,eax
    ret
endp

proc strlen uses ecx, str: dword
    mov esi, [str]
    xor ecx, ecx
    .startloop:
        cmp byte [esi + ecx], 0
        je  .loopend
        inc ecx
        jmp .startloop
    .loopend:
    mov eax,ecx
    ret
endp

proc concatinate uses edi esi ecx ebx, str1: dword, str2: dword, resultbuffer: dword, needclean: dword

    .if [needclean] = 1
        stdcall strclean, [resultbuffer]
    .endif

    stdcall strlen, [str1]
    mov ecx,eax
    mov edi, [resultbuffer]
    rep movsb
    
    mov ebx,eax ; first len


    stdcall strlen, [str2]
    mov edi, [resultbuffer]
    add edi,ebx ; start for second str
    mov ecx,eax ; second len
    rep movsb
ret
endp

proc strclean uses esi edi ecx, str: dword
    stdcall strlen, [str]
    mov ecx,eax
    mov edi, [str]        
    mov eax, 0                      
    cld                           
    rep stosd 
    ret
endp
; index - index disk or ram to delete
proc deletefromdiskram uses esi edi ecx edx ebx, index: dword, offset: dword, arr: dword
    stdcall GetEdi,[index],[offset]
    mov esi, dword[arr]
    mov dword [esi+edi+tmp_offset],-1
ret
endp


; comparator2 push on 1 - ram, 2 - disk
; comparator1 if <> -1 - index of ram or disk to delete; depends on comparator2 
proc diskrampush uses edi esi ecx, process_topush: dword , comparator1: dword, comparator2: dword
    locals
        arr1 dd ?
        size1 dd ?
        offset1 dd ?
        arr2 dd ?
        offset2 dd ?
    endl
    push ecx ; save currentcellcount for function
    .if dword[comparator2] = 1
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
    mov esi, dword[processes]
    stdcall GetEdi, dword[process_topush],process_offset
    movzx eax, word[esi+edi+proc_name_offset]
    mov esi, dword[arr1]
    mov edi, 0
    .loopstart:
        .if word[esi+edi+tmp_offset] = -1
            mov word[esi+edi+tmp_offset],ax
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

proc RAMpush_process uses ecx edi esi, process_topush: dword
    locals
        currentcount dw 0
    endl
    mov cx, word[esi+edi+cells_count_offset]
    .loopstart:

        stdcall diskrampush, dword[process_topush],-1,1
        .if eax = -1
            stdcall diskrampush, dword[process_topush],-1,2
        .endif
        inc word[currentcount]
        cmp word[currentcount],cx
        jb .loopstart
    ret
endp


proc CPUpush, proc_index: dword

    mov esi, dword[CPU]
    mov edi, 0
    .start_loop:
        .if word[esi+edi+cpu_proc_name_offset] <> -1
            add edi,CPU_offset
            .if edi < dword[CPU_size]
                jmp .start_loop
            .endif
        .endif
    .if edi < dword[CPU_size]
        stdcall movproctocpu, dword [proc_index]
        .if word[esi+edi+was_on_CPU_offset] = 0
            stdcall RAMpush_process, dword[proc_index]
            mov word[esi+edi+was_on_CPU_offset],1
        .endif  
        mov word[esi+edi+proc_name_offset],-1
    .else
        mov eax,-1
    .endif
    ret
endp

proc CPUpop uses esi edi ecx ebx edx, process_topop: dword

    stdcall newprocess, 2, dword[process_topop]
    mov esi, dword[CPU]
    stdcall GetEdi, dword[process_topop],CPU_offset
    mov word[esi+edi+cpu_proc_name_offset], -1
    
    
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