section '.data' data readable writeable
    _class TCHAR 'FASMWIN32', 0
    _title TCHAR 'GDI32 Test', 0
    _error TCHAR 'Startup failed.', 0

    wc WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class

    msg MSG
    hDCBuf dd 0
    hDCMain dd 0
    hwnd dd 0
    hBrush dd ?
    hPen dd ?
    hFont dd ?
    hImage dd ?
    hImageDC dd ?
    mouseX dd ?
    mouseY dd ?
    DRAWFLAG dd 1
    PAUSEFLAG dd 0
    rect RECT
    
    screen_height dd ?
    screen_width dd ?
    bmi BITMAPINFOHEADER

    ; Define the variables for heap memory allocation
    heapMemory dd 0
    heapSize dd Width * Height * 4 ; 4 bytes per pixel (32-bit)


    CPU_count dw 6  ; variable for cpu count 
    RAMPages_count dw ? ; variable for rampages count
    RAM_lines_count dw 4
    DISKPages_count dw ? ; variable for diskpages count
    DISK_lines_count dw raw_count
    Process_count dw 10 ; variable for start process count 
    Process_size dd ? ; variable for the size off the process array
    Real_process_size dd ?
    Random_probability dw 1
    Random_IOdelimiter dw 5000
    Random_RAMdelimiter dw 4
    TIME_FOR_BEREADY_delimiter dw 25
    NeedIOCount dd 0

    processes dd ? ; address of the process array
    Max_processes_count = 42
    Current_process_count dd 0

    ; variables for process array offset  
    proc_name_offset = 2
    cells_count_offset = 4  ; ram sells count
    hung_stage_offset = 6   ; current hung stage
    downtime_offset = 8     ; miliseconds from downtime start
    finaltime_offset = 10   ; miliseconds from finaltime start
    need_IO_offset = 12     ; number from 1 to 100 if < Random_probability IO 
    downtime_tick_offset = 14   ; miliseconds from start system (from func gettickcount)
    was_on_CPU_offset = 18  ; flag was process on cpu (to add new cells on ram or not)
    time_for_beready_offset = 20
    process_offset = 22     ; final offset (size of cpu structure)
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
    cpu_time_for_beready_pffset = 26
    CPU_offset = 28

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
    TIME_FOR_REFRESH=5000

    ;FROOOOOOOOOOOOOOOOOOOOONT

    Colorarray dd 0x00fff046,0x0000ff00,0x0000FFFF,0x00008aFF,0x000808FF,0x000000A6,0x00250a41
    Smilesarray dd 0,0,0,0,0,0,0,0
    Hourglassesarray dd 0,0,0,0,0,0,0
    Anima dd 0,0,0,0,0,0,0,0,0,0
    margin_top = 20
    margin_left = 30
    margin_right = 30
    margin_bottom = 10

    text_margin_top = 10
    text_margin_left = 30
    text_margin_right = 2
    text_margin_bottom = 45

    textpage_margin_top = 5
    textpage_margin_left = 2
    textpage_margin_right = 0
    textpage_margin_bottom = 15

    header_height = 40
    header_width = 1700
    left_header_width = 800
    right_header_width = 900

    square_size = 75

    cpu_cpu_gap = 5
    header_cpu_gap = 15
    cpu_middle_gap = 15
    middle_process_gap = 15
    
    proc_foottername_gap = 70
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


    procsquareY1 = margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap
    procsquareY2 = margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap+square_size*6+cpu_cpu_gap*5

    cpusquareY1 = margin_top+header_height+header_cpu_gap
    cpusquareY2 = margin_top+header_height+header_cpu_gap + square_size

    ramsquareY1 = margin_top+header_height+header_cpu_gap+square_size+cpu_middle_gap+header_height+middle_process_gap

    buffer db 24 dup (?)
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
    
    Current_anima_offset dd 0
    Time_for_new_anima dd 400
    ;Gemoji db 'D:\BSUIR\ASSembly\course_2\images\cold_face_emoji.bmp', 0
    emoji0 db './images/0.bmp', 0

    menupicture db './images/anima/0.bmp',0


    pausepicture db './images/pause.bmp',0
    pause_descriptor dd 0

    endpicture db './images/end.bmp',0
    end_descriptor dd 0

    emoji8 db './images/hourglasses/0.bmp', 0