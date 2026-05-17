# CPU Architecture Deep Dive

This document expands on the 16-bit single-cycle CPU implemented in `cpu.circ`.

## 1) Design Intent

The design aims to be:

- Small enough for full visual inspection in Logisim.
- Rich enough to demonstrate full instruction lifecycle (fetch/decode/execute/memory/write-back/control-flow).
- Practical enough to run simple interactive programs with keyboard input and TTY output.

## 2) Execution Model

The CPU is single-cycle at the architectural level:

- One instruction's functional work is completed within one cycle window.
- State-holding blocks (PC, register file, memory/peripherals) update on configured edges.
- Next-state values are produced by combinational logic from current state + instruction bits.

## 3) Datapath Walkthrough

### Fetch

- `PC` addresses instruction memory.
- Instruction word is presented to decode logic.

### Decode

- Opcode determines instruction class and control behavior.
- Register and immediate/jump fields are routed to operand/target paths.

### Operand Read

- Source register operands are read from the register file.
- For immediate operations, the immediate field is selected for ALU/address generation.

### Execute

- ALU performs:
  - arithmetic (`add`, `addi`, `sub`),
  - logic (`and`, `not`),
  - shifts (`sll`, `srl`),
  - comparisons supporting branch decisions.

### Memory / I/O Access

- `lw` and `sw` use ALU-computed effective addresses.
- `input` consumes keyboard-provided data.
- `output` drives TTY output data path.

### Write-back

- Destination register gets one of:
  - ALU result,
  - loaded memory data,
  - input data,
  - link value (`PC+1` for `jal`, into `r7`).

### PC Update

- Default: `PC + 1`.
- Branches: `PC + 1 + offset` when predicate is true.
- Jumps:
  - `j`: absolute/immediate target mapping,
  - `jr`: register-sourced target,
  - `jal`: jump + link.

## 4) Control Organization

Conceptually, control can be viewed as a decode table keyed by opcode that drives:

- ALU function code.
- Register write enable and destination selection.
- Memory write enable.
- Write-back source mux.
- Branch/jump decision and next-PC mux selection.

This is a canonical hardwired single-cycle control scheme.

## 5) ISA Notes

Supported instructions are documented in the root README and should be treated as the source of truth for programming the CPU.

Important semantic notes:

- `srl` is logical right shift (zero-fill behavior).
- `jal` writes return address (`PC+1`) into `r7`.
- `j` uses a limited-width target representation (upper bits effectively zeroed per project spec).

## 6) Register/Software Conventions

While hardware exposes `r0`-`r7`, software conventions improve readability:

- `r0`: zero-like register usage.
- `r6`: stack pointer convention.
- `r7`: link register / return address.

## 7) Reset and Timing Notes

Reset is asynchronous and clears architectural-visible state (PC/registers/peripherals per README).

Clock edges are intentionally split across blocks (PC/memory/keyboard on falling, regfile/TTY on rising), which helps avoid accidental same-edge ordering ambiguity in Logisim teaching designs.

## 8) Validation Approach

A practical architecture-level validation plan:

- Per-opcode directed tests.
- Branch boundary/offset tests.
- Link/return (`jal` + `jr`) tests.
- Load/store round-trip tests.
- Reset-mid-execution tests.
- Keyboard/TTY integration tests.

## 9) Extension Ideas (Future Work)

Potential improvements if the project evolves:

- Add a tiny assembler + ROM image generator.
- Add an automated test harness with ROM fixtures.
- Add a pipelined variant and compare hazards/performance.
- Expand ISA with explicit compare/set instructions.
- Add memory-mapped timer or interrupt controller.
