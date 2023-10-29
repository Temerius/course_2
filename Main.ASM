format PE GUI 4.0
entry start

section '.data' data readable writeable
  CPU_count dw 4  ; variable for cpu count 
  RAMPages_count dw 16 ; variable for rampages count
  DISKPages_count dw 8 ; variable for diskpages count
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
  process_offset = 26
  ;



  ; CPUs [4]: word
  process_on_CPU_offset = 1



  ; RAMPages [8]: word
  process_on_RAM_offset = 1


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

    mov eax,2
    mov ebx,4
    .if eax < ebx
        mov ecx,eax 
        .else
        mov ecx,ebx
    .endif


    invoke GetProcessHeap 
    mov dword[myheap],eax
    stdcall initialisation,eax

    ; timer start

    invoke GetTickCount

    mov dword[timer],eax
    ;

    ; main loop
    time_loop:

        stdcall timeupdate

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
proc initialisation, a:DWORD
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