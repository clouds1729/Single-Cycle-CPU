# 16-Bit CPU Project in Logisim

## Overview
This project involves the implementation of a 16-bit CPU using the Logisim simulation environment. The CPU supports a set of instructions as specified in the provided instruction set table.

## Features
- 16-bit architecture
- Supports a range of instructions including arithmetic, logical, memory access, and control flow operations
- 8 general-purpose registers, with $r7 serving as the link register for the `jal` instruction
- Asynchronous reset functionality
- Clocking design with separate clocks for PC, register file, data memory, keyboard, and TTY display

## Instruction Set
The CPU supports the following instruction set:

| Instruction | Opcode | Type | Usage | Operation |
| --- | --- | --- | --- | --- |
| add | 0000 | R | `add $rd, $rs, $rt` | `$rd = $rs + $rt` |
| addi | 0001 | I | `addi $rt, $rs, Imm` | `$rt = $rs + Imm` |
| sub | 0010 | R | `sub $rd, $rs, $rt` | `$rd = $rs - $rt` |
| sll | 0011 | R | `sll $rd, $rs, <shamt>` | `$rd = $rs << shamt` (shamt is unsigned) |
| srl | 0100 | R | `srl $rd, $rs, <shamt>` | `$rd = $rs >> shamt` (logical shift: no special treatment of sign bit; shamt is unsigned) |
| and | 0101 | R | `and $rd, $rs, $rt` | `$rd = $rs & $rt` |
| not | 0110 | R | `not $rd, $rs` | `$rd = ~$rs` |
| lw | 0111 | I | `lw $rt, D($rs)` | `$rt = Mem[$rs+D]` |
| sw | 1000 | I | `sw $rt, D($rs)` | `Mem[$rs+D] = $rt` |
| bne | 1001 | I | `bne $rs, $rt, B` | `if ($rs!=$rt) then PC=PC+1+B` |
| ble | 1010 | I | `ble $rs, $rt, B` | `if ($rs<=$rt) then PC=PC+1+B` |
| j | 1011 | J | `j L` | `PC = L` (upper 4 bits zeroed) |
| jr | 1100 | R | `jr $rs` | `PC = $rs` |
| jal | 1101 | J | `jal L` | `$r7=PC+1; PC = L` |
| input | 1110 | I | `input $rt` | `$rt = keyboard input` |
| output | 1111 | I | `output $rs` | `print $rs on a TTY display` |

## Registers
There are 8 general-purpose registers: `$r0`-`$r7`. The register `$r7` is the link register for the `jal` instruction. `$r0` is the constant value 0, and users are advised to use `$r6` as the stack pointer.

## Reset Input
The processor has a single input called `reset` which resets the state of the computer by:
1. Resetting the PC to 0 asynchronously.
2. Clearing the TTY display asynchronously.
3. Clearing the keyboard input buffer asynchronously.
4. Resetting the registers in the register file to all-zero asynchronously.

## Clocking
There are five clocked items in the design:
- PC register, clocked on the falling edge
- Register file, clocked on the rising edge
- Data memory, clocked on the falling edge
- Keyboard, clocked on the falling edge
- TTY, clocked on the rising edge
