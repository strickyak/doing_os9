         org 9000
Payload
         orcc #$50   ; disable interrupts
         ldx #$FF68  ; CoCoIO port
         lda #$80    ; RESET command
         lda #$03    ; AutoInc command
Loop     sta 0,x     ; Reset.
         stb 0,x     ; AutoInc mode.
         clr 1,x     ; Hi addr of reg is 0
         clr 2,x     ; Lo addr or reg is 0
         ldb 3,x     ; Read reg 0
         bra Loop
