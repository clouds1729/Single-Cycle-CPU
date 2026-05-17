; sum_1_to_5.asm
; Goal: compute 1+2+3+4+5 and output result (15)
; Conventions used:
;   r1 = running sum
;   r2 = loop counter i
;   r3 = loop limit (6 so loop runs while i != 6)

addi r1, r0, 0      ; sum = 0
addi r2, r0, 1      ; i = 1
addi r3, r0, 6      ; limit = 6

loop:
add  r1, r1, r2     ; sum += i
addi r2, r2, 1      ; i++
bne  r2, r3, loop   ; continue until i == 6

output r1           ; expect TTY to show 15
