;串行A/D模数转换实验

;实验连线
;1) 串行A/D单元的CLK、DAT、ACS分别连接单片机的P1.0、P1.1、P1.2
;2) 串行A/D单元的ADIN连接0~5V模拟电压输出端

CLK     bit P1.0
DAT     bit P1.1
CS      bit P1.2


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

        END

