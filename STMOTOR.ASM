;步进电机控制

;P1.0~P1.3 ---- BA,BB,BC,BD

        org 0
        mov a,#11001100b
start:  mov p1,a
        rr a
        call delay
        sjmp start

delay:  mov r6,#8
dlp:    mov r7,#0
        djnz r7,$
        djnz r6,dlp
        ret
        
        end

