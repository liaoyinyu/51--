;串行A/D模数转换实验

;实验连线
;1) 串行A/D单元的CLK、DAT、ACS分别连接单片机的P1.0、P1.1、P1.2
;2) 串行A/D单元的ADIN连接0~5V模拟电压输出端

CLK     bit P1.0
DAT     bit P1.1
CS      bit P1.2

CS8279C equ 0fff1h
CS8279D equ 0fff0h
ledbuf  equ 70h         ;显示缓冲

        org 0

start:  call I8279      ;8279初始化

        MOV LedBuf+0,#0ah
        MOV LedBuf+1,#0dh
        MOV LedBuf+2,#10h
        MOV LedBuf+3,#10h

ADC:    call SADC
        mov b,a         ;拆送显示缓冲区
        swap a
        anl a,#0fh
        anl b,#0fh
        MOV LedBuf+4,a
        MOV LedBuf+5,b
        call disp
        SJMP ADC        ;循环

;串行A/D转换, 结果保存到ACC
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
        mov b,a         ;保存A/D转换结果
        clr CLK
        nop
        djnz r6,SADCLP
        setb CS         ;禁能TLC549，再次启动AD转换
        setb CLK
        mov a,b         ;转换结果存到ACC
        ret

;8279初始化
I8279:  PUSH DPL
        PUSH DPH
        MOV dptr,#CS8279C  ;指向命令口
        MOV A,#00H         ;8个8位显示
        MOVX @dptr,a       ;方式字写入
        MOV A,#32H         ;设分频初值
        MOVX @dptr,a       ;分频字写入
        MOV A,#0DFH        ;定义清显字
        MOVX @dptr,a       ;关闭显示器
x90s:   movx a,@dptr
        JB ACC.7,x90s      ;检测8279
        POP DPH
        POP DPL
        ret

;显示子程序
disp:   PUSH DPL
        PUSH DPH
        mov r2,#85h
        mov r0,#ledbuf
disp1:  mov dptr,#CS8279C
        mov a,r2
        movx @dptr,a
        mov dptr,#ledmap   ;指字形表首
        mov a,@r0          ;取送显数据
        movc a,@a+dptr     ;索字形代码
        mov dptr,#CS8279D  ;指向字形口
        movx @dptr,a       ;送当前字形
        dec r2
        inc r0
        cjne r0,#ledbuf+6,disp1
        POP DPH
        POP DPL
        ret

;字形表
ledmap: db 0ch,9fh,4ah,0bh,99h,29h,28h,8fh
        db 08h,09h,88h,38h,6ch,1ah,68h,0e8h,0ffh

        END

