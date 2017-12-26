;����A/Dģ��ת��ʵ��

;ʵ������
;1) ����A/D��Ԫ��CLK��DAT��ACS�ֱ����ӵ�Ƭ����P1.0��P1.1��P1.2
;2) ����A/D��Ԫ��ADIN����0~5Vģ���ѹ�����

CLK     bit P1.0
DAT     bit P1.1
CS      bit P1.2

CS8279C equ 0fff1h
CS8279D equ 0fff0h
ledbuf  equ 70h         ;��ʾ����

        org 0

start:  call I8279      ;8279��ʼ��

        MOV LedBuf+0,#0ah
        MOV LedBuf+1,#0dh
        MOV LedBuf+2,#10h
        MOV LedBuf+3,#10h

ADC:    call SADC
        mov b,a         ;������ʾ������
        swap a
        anl a,#0fh
        anl b,#0fh
        MOV LedBuf+4,a
        MOV LedBuf+5,b
        call disp
        SJMP ADC        ;ѭ��

;����A/Dת��, ������浽ACC
SADC:   mov b,#0
        clr CLK
        clr CS
        mov r6,#8
SADCLP: setb CLK
        nop
        nop
        mov c,DAT
        mov a,b
        rlc a
        mov b,a         ;����A/Dת�����
        clr CLK
        nop
        djnz r6,SADCLP
        setb CS         ;����TLC549���ٴ�����ADת��
        setb CLK
        mov a,b         ;ת������浽ACC
        ret

;8279��ʼ��
I8279:  PUSH DPL
        PUSH DPH
        MOV dptr,#CS8279C  ;ָ�������
        MOV A,#00H         ;8��8λ��ʾ
        MOVX @dptr,a       ;��ʽ��д��
        MOV A,#32H         ;���Ƶ��ֵ
        MOVX @dptr,a       ;��Ƶ��д��
        MOV A,#0DFH        ;����������
        MOVX @dptr,a       ;�ر���ʾ��
x90s:   movx a,@dptr
        JB ACC.7,x90s      ;���8279
        POP DPH
        POP DPL
        ret

;��ʾ�ӳ���
disp:   PUSH DPL
        PUSH DPH
        mov r2,#85h
        mov r0,#ledbuf
disp1:  mov dptr,#CS8279C
        mov a,r2
        movx @dptr,a
        mov dptr,#ledmap   ;ָ���α���
        mov a,@r0          ;ȡ��������
        movc a,@a+dptr     ;�����δ���
        mov dptr,#CS8279D  ;ָ�����ο�
        movx @dptr,a       ;�͵�ǰ����
        dec r2
        inc r0
        cjne r0,#ledbuf+6,disp1
        POP DPH
        POP DPL
        ret

;���α�
ledmap: db 0ch,9fh,4ah,0bh,99h,29h,28h,8fh
        db 08h,09h,88h,38h,6ch,1ah,68h,0e8h,0ffh

        END
