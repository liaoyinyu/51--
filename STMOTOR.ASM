;步进电机控制

;P1.0~P1.3 ---- BA,BB,BC,BD
VOL EQ 36H
        org 0
        mov a,#11001100b
start:  mov p1,a
        rr a
        call MOT_delay
        sjmp start
		
MOT_delay:  
		mov a,VOL
		CJNE A,#80H,MOT_delay3		
		mov r6,#08H
		SJMP DLP;
MOT_delay3:
		JC MOT_delay2
		MOV R6,#10H
		SJMP DLP
MOT_delay2:
		MOV R6,#04H		
dlp:    mov r7,#0
        djnz r7,$
        djnz r6,dlp
        ret
        
        end

