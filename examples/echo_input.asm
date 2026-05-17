; echo_input.asm
; Goal: read one keyboard value and emit it to TTY

input  r1           ; r1 = keyboard input
output r1           ; print to TTY

; optional: idle loop
j 2                 ; keep executing this jump to stay stable
