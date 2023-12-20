proc DrawEnd uses ebx ecx edx esi edi

    stdcall DrawImage, dword[end_descriptor],0,0, dword[screen_width], dword[screen_height] 
    
    stdcall DrawSettingName

    stdcall MyDrawText, 0x00d87900,0x00FFFFFF,40,LineX, LineY,LineX+160,LineY+Line_height,Difficulty,DT_SINGLELINE+DT_LEFT+DT_VCENTER
    stdcall MyDrawText, 0x00d87900,0x00FFFFFF,40,LineX+160, LineY,LineX+320,LineY+Line_height,buffer,DT_SINGLELINE+DT_LEFT+DT_VCENTER

    stdcall DrawTime
    stdcall MyDrawText,0x00d87900, 0x00FFFFFF,40, LineX, LineY+Line_height,LineX+500,LineY+Line_height*2,result_buffer,DT_LEFT+DT_SINGLELINE+DT_VCENTER
    stdcall strclean, buffer

    stdcall DrawScore
    stdcall MyDrawText, 0x00d87900,0x00FFFFFF,40, LineX, LineY+Line_height*2,LineX+500,LineY+Line_height*3,result_buffer,DT_SINGLELINE+DT_LEFT+DT_VCENTER
    stdcall strclean, buffer

    stdcall MyDrawText, 0x00d87900,0x00FFFFFF,25, LineX, PressY,LineX+1000,PressY+Text_height,PressESC,DT_SINGLELINE+DT_LEFT+DT_VCENTER
    stdcall MyDrawText, 0x00d87900,0x00FFFFFF,25, LineX, PressY+Text_height,LineX+1000,PressY+Text_height*2,PressTAB,DT_SINGLELINE+DT_LEFT+DT_VCENTER
ret
endp