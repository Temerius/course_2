format PE GUI 4.0
entry start

section '.data' data readable writeable
    CPU_count dw 4  ; variable for cpu count 
    RAMPages_count dw 32 ; variable for rampages count
    DISKPages_count dw 16 ; variable for diskpages count
    Process_count dw 8 ; variable for start process count 
    Process_size dd ? ; variable for the size off the process array
    Real_process_size dd ?

    processes dd ? ; address of the process array

    ; variables for process array offset  
    number_in_CPU_offset = 2
    cells_count_offset = 4
    hung_stage_offset = 6
    downtime_offset = 8
    uptime_offset = 10
    finaltime_offset = 12
    need_IO_offset = 14
    downtime_tick_offset = 16
    uptime_tick_offset = 20
    executed_offset = 24
    was_on_CPU_offset = 26
    process_offset = 28
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
    myheap dd 0 ;

    TIME_FOR_NEW_PROCESS=20000
    TIME_FOR_NEXT_STAGE=6000
    TIME_FOR_BEREADY=25000
    TIME_FOR_REFRESH=4000





section '.text' code readable executable
  include 'win32a.inc'
  include './MACRO/IF.INC'
proc start


    invoke GetProcessHeap 
    mov dword[myheap],eax
    stdcall initialisation,eax

    ; timer start

    invoke GetTickCount

    mov dword[timer],eax
    ;

    ; main loop
    mov ecx,0
    time_loop:

        stdcall timeupdate
        stdcall CPUpush,ecx
        jmp time_loop

    
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
proc initialisation, a: DWORD
    ; process array size
    mov ax, word [Process_count]
    mov bx, process_offset
    imul ax,bx
    ;

    movzx eax,ax
    mov dword [Process_size],eax


    shl eax,1 ;expand array size x2

    mov dword [Real_process_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [processes],eax
    mov esi,eax

    mov edi,0 ; offset in process array

    ; filling the array of processes
    ini_loopstart:
        stdcall addprocess
        add edi,process_offset
        cmp edi, dword [Process_size]
        jne ini_loopstart

    ;
    


    ; ini for CPU
    mov ax, word [CPU_count]
    mov bx, CPU_offset
    imul ax,bx
    movzx eax,ax
    mov dword [CPU_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [CPU],eax

    mov edi,0 ; offset in CPU array
    mov cx,0
    ; filling the array of CPUs
    inicpu_loopstart:
        stdcall addCPU
        inc cx
        add edi,CPU_offset
        cmp edi, dword [CPU_size]
        jne inicpu_loopstart


    ; ini for RAM
    mov ax, word [RAMPages_count]
    mov bx, RAM_offset
    imul ax,bx
    movzx eax,ax
    mov dword [RAM_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [RAM],eax

    mov edi,0 ; offset in RAM array
    mov cx,0
    ; filling the array of RAM
    iniram_loopstart:
        stdcall addRAM
        inc cx
        add edi,RAM_offset
        cmp edi, dword [RAM_size]
        jne iniram_loopstart

    ; ini for DISK
    mov ax, word [DISKPages_count]
    mov bx, DISK_offset
    imul ax,bx
    movzx eax,ax
    mov dword [DISK_size],eax
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [DISK],eax

    mov edi,0 ; offset in DISK array
    mov cx,0
    ; filling the array of DISK
    inidisk_loopstart:
        stdcall addDISK
        inc cx
        add edi,DISK_offset
        cmp edi, dword [DISK_size]
        jne inidisk_loopstart
ret
endp

proc addCPU
    mov esi,dword[CPU]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_CPU_offset], -1
    
    ret
endp

proc addRAM
    mov esi,dword[RAM]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_RAM_offset], -1
    
    ret
endp

proc addDISK
    mov esi,dword[DISK]
    mov word [esi+edi],cx
    mov word [esi+edi+process_on_DISK_offset], -1
    
    ret
endp
proc addprocess
    mov esi,dword[processes]
    mov dx, word[current_name]
    mov word [esi+edi],dx
    mov word [esi+edi+number_in_CPU_offset], -1
    mov word [esi+edi+cells_count_offset],4
    mov word [esi+edi+hung_stage_offset],1
    mov word [esi+edi+downtime_offset],0
    mov word [esi+edi+uptime_offset],0
    mov word [esi+edi+finaltime_offset],0
    mov word [esi+edi+need_IO_offset],0
    mov dword [esi+edi+downtime_tick_offset],0
    mov dword [esi+edi+uptime_tick_offset],0
    mov word [esi+edi+executed_offset],0
    mov word [esi+edi+was_on_CPU_offset],0
    inc dx
    mov word [current_name],dx
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
    nop eax
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

proc diskrampush, process_topush: dword , comparator1: dword, comparator2: dword
    locals
        arr1 dd ?
        size1 dd ?
        offset1 dd ?
        arr2 dd ?
        offset2 dd ?
    endl

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
        .if dword[esi+edi+tmp_offset] = -1
            mov dword[esi+edi+tmp_offset],ecx
        .else
            add edi,[offset1]
            cmp edi, dword [size1]
            jne .loopstart
        .endif

        .if edi = dword [size1]
            mov eax,-1
        .else 
            .if [comparator1] <> -1
                stdcall deletefromdiskram,[comparator1],[offset2],[arr2]
            .endif
            mov eax,0
        .endif

    ret
endp

proc RAMpush_process, process_topush: dword
    locals
        count dw ?
        currentcount dw 0
    endl
    mov ax, word[esi+edi+cells_count_offset]
    mov [count],ax
    mov cx, word[count]
    .loopstart:

        stdcall diskrampush, [process_topush],0,1
        .if eax = -1
            stdcall diskrampush, [process_topush],0,2
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
            mov word[esi+edi+process_on_CPU_offset],ax
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

section '.idata' import data readable writeable
  library kernel32, 'KERNEL32.DLL',\
          user32, 'USER32.DLL'

  import kernel32,\
         ExitProcess, 'ExitProcess',\
         GetTickCount, 'GetTickCount',\
         GetProcessHeap, 'GetProcessHeap',\
         HeapAlloc, 'HeapAlloc',\
         HeapReAlloc, 'HeapReAlloc',\
         HeapFree, 'HeapFree'

  import user32,\
         MessageBox, 'MessageBoxA'