;128*64液晶显示器演示程序

;实验连线
;1) 将液晶显示单元的R/W、R/S分别连接地址总线单元的A1、A0
;2) 液晶显示单元的E连接端口地址360
;步进电机接线
;P1.4——P1.7 
;串行AD接口
;P1.0,P1.1,P1.2
LCD     EQU 0360H
WRICODE EQU LCD+0   ;写命令
WRDATA  EQU LCD+1   ;写数据
RDSTAT  EQU LCD+2   ;读状态
RDDATA  EQU LCD+3   ;读数据


COUNT   EQU 34H
SPEED 	EOU 35H
SPEEDH 	EQU 36H
MOTOR_COUNT EQU 39H
CLK     BIT P1.0	;串行AD接口
DAT     BIT P1.1
CS      BIT P1.2
        ORG 0000H
        AJMP MAIN

        ORG 0100H
MAIN:   MOV SP,#60H

;初始化
INITIAL_LGS0:   
		MOV A,#30H      ;30H--基本指令操作
        LCALL SEND_I
        MOV A,#01H      ;清除显示
        LCALL SEND_I
        LCALL DELAY2
        LCALL DELAY2
        MOV A,#06H      ;指定在资料写入或读取时，光标的移动方向
        LCALL SEND_I
        MOV A,#0CH      ;开显示,关光标,不闪烁
        LCALL SEND_I
MAIN1:						;主函数
        LCALL SADC;			;AD转换
        LCALL MOTOR_RUN		;电机转动
        LCALL DIS_LGS1;		;12864显示
        SJMP MAIN1

DIS_LGS1:   
		MOV DPTR,#TAB1  ;显示汉字和字符，TAB地址传送给DPTR
        MOV COUNT,#14H		;64传送给COUNT,显示16个字符数据
        MOV A,#80H			;128传送给累加器
        LCALL SEND_I		;调用写指令
LGS11:  CLR A				;累加器清零			
        MOVC A,@A+DPTR		;TAB数据传送给累加器
        LCALL SEND_D		;写数据
        INC DPTR			;指向TAB的指针加一
        DJNZ COUNT,LGS11	;COUNT减一，不等于0时转移到LGS11
		MOV A, SPEEDH
		ADD A,#30H
		LCALL SEND_D
        RET			
SADC:   MOV B,#0			;AD转换
        CLR CLK
        CLR CS
        MOV R6,#8
SADCLP: SETB CLK
        NOP
        NOP
        MOV C,DAT
        MOV A,B
        RLC A
        MOV B,A         ;保存A/D转换结果
        CLR CLK
        NOP
        DJNZ R6,SADCLP
        SETB CS         ;禁能TLC549，再次启动AD转换
        SETB CLK
        MOV A,B         ;转换结果存到ACC
        MOV SPEED,A;	结果保存在SPEED
        RET
MOTOR_RUN:					;电机转动
        MOV A,#11001100B
		MOV MOTOR_COUNT,#8
START:  MOV B,P1
        ANL B,#0FH
        PUSH ACC;
        ANL A,#0F0H
        ORL A,B;
        MOV P1,A		;电机接口为P1
        POP ACC;
        RR A
        CALL MOT_DELAY
        DJNZ MOTOR_COUNT,START
		RET
MOT_DELAY:
		PUSH ACC
		MOV A,SPEED
		CJNE A,#80H,MOT_DELAY3
		MOV R6,#08H
        MOV SPEEDH,#04H
		SJMP DLP;
MOT_DELAY3:
		JC MOT_DELAY2
		MOV R6,#10H
        MOV SPEEDH,#03H
		SJMP DLP
MOT_DELAY2:
		MOV R6,#04H
        MOV SPEEDH,#05H
DLP:    MOV R7,#0
        DJNZ R7,$
        DJNZ R6,DLP
		POP ACC
        RET
SEND_D: PUSH DPL        ;写数据子程序
        PUSH DPH
        LCALL CHKBUSY
        MOV DPTR,#WRDATA
        MOVX @DPTR,A
        POP DPH
        POP DPL
        RET

SEND_I: PUSH DPL        ;写指令子程序
        PUSH DPH
        LCALL CHKBUSY
        MOV DPTR,#WRICODE
        MOVX @DPTR,A
        POP DPH
        POP DPL
        RET

CHKBUSY:PUSH ACC        ;测忙碌子程序
        MOV DPTR,#RDSTAT
        MOV R4,#100
BUSY1:  MOVX A,@DPTR
        JNB ACC.7,BUSY2
        DJNZ R4,BUSY1
BUSY2:  POP ACC
        RET

DELAY3: MOV R5,#16H		;延时子程序3
DEL31:  MOV R6,#0FFH
DEL32:  MOV R7,#0FFH
DEL33:  DJNZ R7,DEL33
        DJNZ R6,DEL32
        DJNZ R5,DEL31
        RET

DELAY2: MOV R6,#0CH		;延时子程序2
DEL21:  MOV R7,#18H
DEL22:  DJNZ R7,DEL22
        DJNZ R6,DEL21
        RET

TAB1:   DB "     SPEED :    "
        DB "                "
        DB "                "
        DB "                "


        END

