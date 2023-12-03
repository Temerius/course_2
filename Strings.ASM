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


proc IntToStr uses edx ebx edi esi ecx, num, buf, startBufPos
    mov ebx, 10
    mov eax, [num]
    mov esi, [buf]
    add esi, [startBufPos]

    xor ecx, ecx
    .ConvertLoop:
        xor edx, edx
        div ebx
        add edx, '0'
        mov byte[esi], dl
        
        inc ecx
        inc esi

        cmp eax, 0
        
    jnz .ConvertLoop


    ;mov byte[esi], 0 ; zero terminated string 

    dec esi ; got last digit pos in string 
    mov edi, esi ; save last pos
    dec ecx
    sub esi, ecx ; got first digit pos in string
    .invertOrderLoop:
      cmp esi, edi 
      jge .stop

      mov al, byte[esi]
      mov ah, byte[edi]
      mov byte[esi], ah
      mov byte[edi], al

      inc esi 
      dec edi
      jmp .invertOrderLoop
      
    .stop:

  ret
endp