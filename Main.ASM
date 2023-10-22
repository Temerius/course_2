format PE GUI 4.0
entry start

section '.data' data readable writeable
  CPU_count dw 4  ; variable for cpu count 
  RAMPages_count dw 16 ; variable for rampages count
  DISKPages_count dw 8 ; variable for diskpages count
  Process_count dw 8 ; variable for start process count 
  Process_size dd ? ; variable for the size off the process array

  
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


  current_name dw 0
  timer dd 0

  TIME_FOR_NEW_PROCESS=20000
  TIME_FOR_NEXT_STAGE=60
  TIME_FOR_BEREADY=25000
  TIME_FOR_REFRESH=4000





section '.text' code readable executable
  include 'win32a.inc'
proc start
  invoke GetProcessHeap

  stdcall initialisation,eax
  mov ecx,36000

  time_loop:

    stdcall timeupdate
    dec ecx
    cmp ecx,0
    jne time_loop
  invoke ExitProcess, 0
  ret
endp

proc initialisation, a:DWORD

    mov ax,word [Process_count]
    mov bx,process_offset
    imul ax,bx

    movzx eax,ax
    mov dword [Process_size],eax


    shl eax,1 ;expand array size x2
    mov ebx,eax
    invoke HeapAlloc, [a],0,ebx
    mov dword [processes],eax

    mov edi,0 ; offset in process array
    mov dx,word [current_name]

    ; filling the array of processes
    ini_loopstart:
        mov word [processes+edi],dx
        mov word [processes+edi+number_in_CPU_offset], -1
        mov word [processes+edi+cells_count_offset],4
        mov word [processes+edi+hung_stage_offset],1
        mov word [processes+edi+downtime_offset],0
        mov word [processes+edi+uptime_offset],0
        mov word [processes+edi+finaltime_offset],0
        mov word [processes+edi+need_IO_offset],0
        mov word [processes+edi+downtime_tick_offset],0
        mov word [processes+edi+uptime_tick_offset],0
        mov word [processes+edi+executed_offset],0
        add edi,process_offset
        inc edx
        cmp edi,dword [Process_size]
        jne ini_loopstart
    mov word [current_name],dx
ret
endp

proc timeupdate
    mov edi,0 ; offset in process array
    invoke GetTickCount
    time_loopstart:
        cmp word [processes+edi+executed_offset],0
        jne executed_label

            not_executed_label:
               mov dword [processes+edi+uptime_tick_offset],0 
               cmp dword [processes+edi+downtime_tick_offset],0
               je new_downtime_update_label

                    old_downtime_update_label:
                        push eax
                        sub eax,dword [processes+edi+downtime_tick_offset]
                        add word [processes+edi+downtime_offset],ax
                        cmp word [processes+edi+downtime_offset],TIME_FOR_NEXT_STAGE
                        jbe not_new_stage_label
                        
                            new_stage_label:
                                add word [processes+edi+hung_stage_offset],1
                                and bx,0
                                mov bx,word [processes+edi+hung_stage_offset]
                                mov word [processes+edi+downtime_offset],0

                            not_new_stage_label:
                                pop eax
                                jmp new_downtime_update_label

                new_downtime_update_label:
                    mov dword [processes+edi+downtime_tick_offset],eax
                
                jmp continue_timeloop

            executed_label:
                mov dword [processes+edi+downtime_tick_offset],0
                cmp dword [processes+edi+uptime_tick_offset],0
                je new_uptime_update_label

                    old_uptime_update_label:
                        push eax
                        sub eax,dword [processes+edi+uptime_tick_offset]
                        add word [processes+edi+uptime_offset],ax
                        add word [processes+edi+finaltime_offset],ax
                        pop eax
                        jmp new_uptime_update_label

                new_uptime_update_label:
                    mov dword [processes+edi+uptime_tick_offset],eax

    continue_timeloop:

        add edi,process_offset
        cmp edi,dword [Process_size]
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
         HeapFree, 'HeapFree'

  import user32,\
         MessageBox, 'MessageBoxA'