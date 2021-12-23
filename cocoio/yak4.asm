         org 9000
Payload
         orcc #$50   ; disable interrupts
         ldu #$0000  ; Register number 0
         ldx #$FF68  ; CoCoIO port
         lda #$80    ; RESET command
         ldb #$03    ; AutoInc command
Loop     sta 0,x     ; Reset.
         stb 0,x     ; AutoInc mode.
         stu 1,x     ; Point chip to reg 0
         ldb 3,x     ; Read reg 0 from chip
         bra Loop
