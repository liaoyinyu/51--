;128*64Һ����ʾ����ʾ����

;ʵ������
;1) ��Һ����ʾ��Ԫ��R/W��R/S�ֱ����ӵ�ַ���ߵ�Ԫ��A1��A0
;2) Һ����ʾ��Ԫ��E���Ӷ˿ڵ�ַ360

LCD     EQU 0360H
WRICODE EQU LCD+0   ;д����
WRDATA  EQU LCD+1   ;д����
RDSTAT  EQU LCD+2   ;��״̬
RDDATA  EQU LCD+3   ;������


COUNT   EQU 34H

        ORG 0000H
        AJMP MAIN

        ORG 0100H
MAIN:   MOV SP,#60H

;��ʼ��
initial_LGS0:   
		MOV A,#30H      ;30H--����ָ�����
        LCALL SEND_I
        MOV A,#01H      ;�����ʾ
        LCALL SEND_I
        LCALL DELAY2
        LCALL DELAY2
        MOV A,#06H      ;ָ��������д����ȡʱ�������ƶ�����
        LCALL SEND_I
        MOV A,#0CH      ;����ʾ,�ع��,����˸
        LCALL SEND_I
		RET

dis_LGS1:   
		MOV DPTR,#TAB1  ;��ʾ���ֺ��ַ���tab��ַ���͸�DPTR
        MOV COUNT,#01H		;64���͸�count,��ʾ16���ַ�����
        MOV A,#80H			;128���͸��ۼ���
        LCALL SEND_I		;����дָ��
LGS11:  CLR A				;�ۼ�������			
        MOVC A,@A+DPTR		;tab���ݴ��͸��ۼ���
        LCALL SEND_D		;д����
        INC DPTR			;ָ��tab��ָ���һ
        DJNZ COUNT,LGS11	;COUNT��һ��������0ʱת�Ƶ�lgs11
		;
		;
		;
		;
        LCALL DELAY3		;��ʱ�ӳ���3
        LJMP LGS1			;������ת��


SEND_D: PUSH DPL        ;д�����ӳ���
        PUSH DPH
        LCALL CHKBUSY
        MOV DPTR,#WRDATA
        MOVX @DPTR,A
        POP DPH
        POP DPL
        RET

SEND_I: PUSH DPL        ;дָ���ӳ���
        PUSH DPH
        LCALL CHKBUSY
        MOV DPTR,#WRICODE
        MOVX @DPTR,A
        POP DPH
        POP DPL
        RET

CHKBUSY:PUSH ACC        ;��æµ�ӳ���
        MOV DPTR,#RDSTAT
        MOV R4,#100
BUSY1:  MOVX A,@DPTR
        JNB ACC.7,BUSY2
        DJNZ R4,BUSY1
BUSY2:  POP ACC
        RET

DELAY3: MOV R5,#16H		;��ʱ�ӳ���3
DEL31:  MOV R6,#0FFH
DEL32:  MOV R7,#0FFH
DEL33:  DJNZ R7,DEL33
        DJNZ R6,DEL32
        DJNZ R5,DEL31
        RET

DELAY2: MOV R6,#0CH		;��ʱ�ӳ���2
DEL21:  MOV R7,#18H
DEL22:  DJNZ R7,DEL22
        DJNZ R6,DEL21
        RET

TAB1:   DB "                "
        DB "     speed��    "
        DB "                "
        DB "                "


        END
