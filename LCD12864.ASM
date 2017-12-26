;128*64液晶显示器演示程序

;实验连线
;1) 将液晶显示单元的R/W、R/S分别连接地址总线单元的A1、A0
;2) 液晶显示单元的E连接端口地址360

LCD     EQU 0360H
WRICODE EQU LCD+0   ;写命令
WRDATA  EQU LCD+1   ;写数据
RDSTAT  EQU LCD+2   ;读状态
RDDATA  EQU LCD+3   ;读数据


COUNT   EQU 34H
SPEED 	EOU 35H

        ORG 0000H
        AJMP MAIN

        ORG 0100H
MAIN:   MOV SP,#60H

;初始化
initial_LGS0:   
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
		RET

dis_LGS1:   
		MOV DPTR,#TAB1  ;显示汉字和字符，tab地址传送给DPTR
        MOV COUNT,#14H		;64传送给count,显示16个字符数据
        MOV A,#80H			;128传送给累加器
        LCALL SEND_I		;调用写指令
LGS11:  CLR A				;累加器清零			
        MOVC A,@A+DPTR		;tab数据传送给累加器
        LCALL SEND_D		;写数据
        INC DPTR			;指向tab的指针加一
        DJNZ COUNT,LGS11	;COUNT减一，不等于0时转移到lgs11
		;MOV A, SPEED
		;ADD A,#30H
		;LCALL SEND_D
        LCALL DELAY3		;延时子程序3
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

TAB1:   DB "     speed :    "
        DB "                "
        DB "                "
        DB "                "


        END

