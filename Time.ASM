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
    push eax
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
                mov eax, dword [timer]
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
            mov eax, dword [timer]
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
                mov dword[esi+edi+cpu_downtime_tick_offset], 0
                mov word[esi+edi+cpu_downtime_offset], 0
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
                .if word[esi+edi+cpu_hung_stage_offset] <> 0
                    mov dword[esi+edi+cpu_uptime_tick_offset], 0
                    mov word[esi+edi+cpu_uptime_offset], 0
                    
                    .if dword [esi+edi+cpu_downtime_tick_offset] > 0
                        mov eax, dword [timer]
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
                    mov eax, dword [timer]
                    mov dword [esi+edi+cpu_downtime_tick_offset],eax
                .endif
            .endif
        .endif
        add edi,CPU_offset
        cmp edi, dword [CPU_size]
        jne .time_loopstart2    
ret
endp


