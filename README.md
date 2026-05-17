# 16-bit Single-Cycle CPU (Logisim)

A course-style CPU can be a strong portfolio project when it is documented like real hardware. This repository contains a **16-bit single-cycle CPU** implemented in **Logisim-evolution**.

> Scope note: this README documents the instruction set and behavior implemented in the current circuit files (`cpu.circ`, `memorylatch.circ`, `my_adder.circ`) without changing CPU functionality.

---

## Project Overview

This processor is a compact teaching architecture with:

- 16-bit datapath.
- 8 architectural registers (`r0`-`r7`).
- A mixed R/I/J-style instruction set.
- Single-cycle execution model (one logical instruction completion per cycle).
- Memory access, branches, jumps, and simple memory-mapped I/O style behavior through Logisim keyboard/TTY components.

The top-level circuit is in `cpu.circ`.

---

## Architecture Overview

At a high level, each instruction follows the classic single-cycle flow:

1. **Fetch** from instruction memory using `PC`.
2. **Decode** opcode and operand fields.
3. **Read operands** from register file.
4. **Execute** (ALU operation / address computation / branch compare).
5. **Memory or I/O access** when required (`lw`, `sw`, `input`, `output`).
6. **Write-back** to register file (for result-producing instructions).
7. **Update `PC`** (sequential `PC+1`, branch target, jump target, or register target).

For a deeper walkthrough, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Datapath (Conceptual)

The datapath includes the standard blocks expected for a small single-cycle machine:

- **Program Counter (PC)** register.
- **Instruction decode field extraction** for opcode/register/immediate/jump target.
- **Register file** with 8 general-purpose 16-bit registers.
- **ALU** for arithmetic, logic, shifts, and effective address calculation.
- **Data memory path** for `lw` / `sw`.
- **Control-flow next-PC logic** for `bne`, `ble`, `j`, `jr`, `jal`.
- **I/O path** to keyboard input and TTY output components.

Because the design is implemented as Logisim schematics, exact micro-level routing can be inspected directly in `cpu.circ`.

---

## Control Unit (Conceptual)

The control logic decodes the 4-bit opcode and drives signals equivalent to:

- ALU operation select.
- Register write enable.
- Data memory write enable.
- Result source select (ALU, memory, input, link address).
- Next-PC source select (sequential, branch, immediate jump, register jump).

Single-cycle implication: all required work for an instruction is combinationally resolved within one cycle boundary for state updates.

---

## Instruction Set and Encodings

### Encoding summary

This CPU uses 16-bit instructions with a 4-bit opcode. Remaining bits are interpreted by format:

- **R-type**: register-register / register-shift style operations.
- **I-type**: immediate, load/store, branch, and simple I/O ops.
- **J-type**: direct jump target field.

> Bit-field interpretation details vary by instruction role (e.g., shift amount vs. register field use). Use the example assembly forms below as the canonical programmer-facing specification.

### Supported instructions

| Instruction | Opcode (bin) | Format | Assembly form | Effect |
|---|---:|---|---|---|
| `add` | `0000` | R | `add rd, rs, rt` | `rd = rs + rt` |
| `addi` | `0001` | I | `addi rt, rs, imm` | `rt = rs + imm` |
| `sub` | `0010` | R | `sub rd, rs, rt` | `rd = rs - rt` |
| `sll` | `0011` | R | `sll rd, rs, shamt` | `rd = rs << shamt` |
| `srl` | `0100` | R | `srl rd, rs, shamt` | `rd = rs >> shamt` (logical) |
| `and` | `0101` | R | `and rd, rs, rt` | `rd = rs & rt` |
| `not` | `0110` | R | `not rd, rs` | `rd = ~rs` |
| `lw` | `0111` | I | `lw rt, D(rs)` | `rt = Mem[rs + D]` |
| `sw` | `1000` | I | `sw rt, D(rs)` | `Mem[rs + D] = rt` |
| `bne` | `1001` | I | `bne rs, rt, B` | if `rs != rt`, `PC = PC + 1 + B` |
| `ble` | `1010` | I | `ble rs, rt, B` | if `rs <= rt`, `PC = PC + 1 + B` |
| `j` | `1011` | J | `j L` | `PC = L` (upper bits zero) |
| `jr` | `1100` | R | `jr rs` | `PC = rs` |
| `jal` | `1101` | J | `jal L` | `r7 = PC + 1`; `PC = L` |
| `input` | `1110` | I | `input rt` | `rt = keyboard input` |
| `output` | `1111` | I | `output rs` | write `rs` to TTY |

---

## Register Conventions

Architectural registers:

- `r0`-`r7` are general-purpose 16-bit registers.
- `r0` is conventionally treated as constant zero.
- `r7` is the link register used by `jal`.
- `r6` is a recommended stack pointer convention for programs that need one.

Suggested software convention for small programs:

- `r1`-`r5`: temporaries / locals.
- `r6`: stack pointer.
- `r7`: return address (`jal`).

---

## Reset and Clocking Behavior

### Reset (`reset` input)

Reset acts asynchronously and initializes key state:

1. `PC` reset to `0`.
2. TTY cleared.
3. Keyboard buffer cleared.
4. Register file cleared to zero.

### Clocking domains/components

The circuit uses multiple clocked components with configured edge behavior:

- `PC`: falling edge.
- Register file: rising edge.
- Data memory: falling edge.
- Keyboard: falling edge.
- TTY: rising edge.

---

## How to Open and Run in Logisim-evolution

1. Install **Logisim-evolution** (project file reports `source="2.15.0"`).
2. Open `cpu.circ`.
3. Locate the top-level circuit (`main3` in this file).
4. Use the simulation controls:
   - **Tick once** for single-step behavior.
   - **Ticks enabled** for continuous running.
5. Use poke/edit tools to:
   - assert/deassert `reset`,
   - inspect PC/register/memory values,
   - interact with keyboard/TTY peripherals.

If you are loading custom machine code into ROM/RAM blocks, use Logisim memory editors inside the relevant subcircuits.

---

## Example Programs

See the `examples/` directory:

- [`examples/sum_1_to_5.asm`](examples/sum_1_to_5.asm): computes 1+2+3+4+5 and outputs the result.
- [`examples/echo_input.asm`](examples/echo_input.asm): reads one keyboard value and echoes it to TTY.

These are assembly-style reference programs (mnemonic-level) intended to match the documented instruction set.

---

## Testing Strategy

Recommended validation approach for this CPU:

1. **Instruction smoke tests**: verify each opcode with small isolated programs.
2. **Datapath tests**: validate ALU ops, shifts, load/store addressing, and write-back destinations.
3. **Control-flow tests**: validate taken/not-taken `bne`/`ble`, `j`, `jr`, `jal` return flow.
4. **Reset tests**: assert reset during/after execution and confirm state clears correctly.
5. **I/O tests**: verify keyboard read and TTY output behavior across cycles.

The `examples/` programs can serve as baseline smoke tests before adding more exhaustive instruction-by-instruction checks.

---

## Known Limitations

- No pipelining; single-cycle timing limits scalability/clock realism.
- Small register file (8 registers).
- Limited immediate/jump encoding space due to 16-bit fixed width.
- No documented exception/interrupt model.
- No assembler toolchain included in this repository.
- Program loading/testing remains manual through Logisim UI unless external tooling is added.

---

## Repository Layout

- `cpu.circ` — primary CPU circuit.
- `memorylatch.circ` — supporting memory latch circuit.
- `my_adder.circ` — supporting adder circuit.
- `docs/ARCHITECTURE.md` — deeper architecture explanation.
- `examples/` — assembly-style sample programs.
