

# MINI CPU DESIGN – ARCHITECTURE AND OPERATIONAL FLOW #

## 1. System Overview

The **Mini CPU** is an 8-bit processor designed according to the **Harvard architecture**, where the instruction memory and data memory are completely separate. This system is built with the goal of visually simulating the core functional blocks of a real microprocessor, including the control unit, execution unit (ALU), register file, program counter, accumulator register, and data memory. Through sensible simplification while retaining all major components, the Mini CPU becomes an ideal learning tool, helping learners easily visualize how an instruction is fetched, decoded, executed, and how results are written back over each clock cycle. Additionally, this model can be used as a platform for testing simple control algorithms or developing small embedded systems in a simulation environment.

<img width="1018" height="429" alt="image" src="https://github.com/user-attachments/assets/1b437c06-d4f0-4d9b-bfa8-9f87ad7d545a" />

<img width="1637" height="801" alt="image" src="https://github.com/user-attachments/assets/3739e3e2-5807-4808-a730-d97f140df76b" />

## 2. Main Functional Blocks

### Control Unit – `control_unit`
- **Input:** 4-bit instruction code (`opcode`).
- **Outputs:** Control signals:
  - `rf_we`: register file write enable.
  - `alu_op`: selects the ALU operation.
  - `dmem_we`: data memory write enable.
  - `acc_we`: accumulator register write enable.
  - `pc_sel`: selects the next address for the program counter (PC + 1 or jump address).
- **Function:** Decodes the instruction and generates appropriate control signals for the other blocks.

<img width="1200" height="490" alt="image" src="https://github.com/user-attachments/assets/d1c1e389-f7e2-43e4-8f1b-7eae1f22b806" />


### Instruction Memory – `mini_imem`
- Stores the program as 16-bit instructions.
- Each instruction consists of:
  - 4-bit `opcode`: instruction code.
  - 2-bit `rd`: destination register address.
  - 2-bit `rs`: source register address.
  - 8-bit `imm`: immediate value or memory address.

<img width="1212" height="488" alt="image" src="https://github.com/user-attachments/assets/91ef722a-06c9-4a25-8871-a354f9049d1f" />


### Program Counter – `pc_unit`
- Stores the address of the current instruction.
- Increments the address by 1 each cycle or jumps to a new address upon a `JMP` instruction.

<img width="1211" height="465" alt="image" src="https://github.com/user-attachments/assets/23b39ab4-9ae0-4e0b-95d7-1a5df867542f" />


### Register File – `mini_regfile`
- Consists of 4 8-bit registers: `r0`, `r1`, `r2`, `r3`.
- Supports reading two registers simultaneously and writing one register per cycle.

<img width="1173" height="447" alt="image" src="https://github.com/user-attachments/assets/7811868a-288e-4292-9cde-79f88f97b36f" />


### ALU Block – `mini_alu`
- Performs arithmetic and logic operations:
  - `3'd0`: Addition (`a + b`)
  - `3'd1`: Subtraction (`a - b`)
  - `3'd4`: XOR (`a ^ b`)
- The result is sent to the accumulator register.

<img width="968" height="471" alt="image" src="https://github.com/user-attachments/assets/20dc1fce-9e36-4af9-9e43-25841816166d" />


### Accumulator Register – `acc_reg`
- Stores the result from the ALU when the `acc_we = 1` signal is active.
- The `debug_acc` output is used for status monitoring.

<img width="1088" height="447" alt="image" src="https://github.com/user-attachments/assets/b33980b7-a306-4f58-ad0d-dad5a0df0f79" />


### Data Memory – `mini_dmem`
- 256-byte RAM, read/write accessible via an 8-bit address.
- Used for `ST` (store) and `LD` (load) instructions.

<img width="1019" height="428" alt="image" src="https://github.com/user-attachments/assets/9552728b-965c-4324-b251-c7f8090c6361" />


### Debug Output Unit – `debug_dout_unit`
- Captures data written to or read from the data memory.
- Displays it via the `debug_dout` signal.

<img width="1148" height="425" alt="image" src="https://github.com/user-attachments/assets/2aeaf1ec-fbab-4688-ac2e-2bdb10495ec0" />


## 3. Operational Flow (Pseudo-pipeline – Single Instruction at a Time)

The system operates in a **non-pipelined, single-instruction-at-a-time** manner, where each instruction is fully executed within one clock cycle.

### Step 1: Fetch
- The program counter (`pc`) provides the address to `mini_imem`.
- The 16-bit instruction is read out.

### Step 2: Decode
- The instruction is split into `opcode`, `rd`, `rs`, `imm`.
- `control_unit` decodes the `opcode` and generates control signals.

### Step 3: Register Read
- Reads values from two registers, `rdata0` and `rdata1`, from `mini_regfile`.

### Step 4: Execute
- If it is an ALU instruction (`ADD`, `SUB`, `XOR`), the result from `mini_alu` is written into `acc_reg`.

### Step 5: Memory Access
- If it is `ST`: writes `rdata0` into `mini_dmem` at address `imm`.
- If it is `LD`: reads data from `mini_dmem` at address `imm`.

### Step 6: Write-back
- If it is `LDI`: writes `imm` into register `rd`.
- If it is `LD`: writes data from RAM into register `rd`.

### Step 7: PC Update
- If it is `JMP`: `pc_next = imm`
- Otherwise: `pc_next = pc + 1`


## 4. Example Program Description (from mini_imem)

| Address | Instruction | Explanation |
|---------|-------------|-------------|
| 0x00 | LDI R0, 5 | R0 = 5 |
| 0x01 | LDI R1, 3 | R1 = 3 |
| 0x02 | ADD | ACC = R0 + R1 = 8 |
| 0x03 | ST R0, 0x10 | Store R0 into RAM[0x10] |
| 0x04 | LD R2, 0x10 | R2 = RAM[0x10] = 5 |
| 0x05 | XOR | ACC = R2 ^ R1 = 5 ^ 3 = 6 |
| 0x06 | JMP 0x02 | Jump to address 0x02 |



## 5. Conclusion

The **Mini CPU** is a simplified processor model that still encompasses all core components such as the control unit, ALU, register file, program counter, accumulator register, and data memory. Thanks to its sensible simplification, the system allows learners to easily grasp the fundamental principles of computer architecture, from the instruction fetch, decode, and execute mechanisms to the write-back process across each clock cycle.

Besides its role as an intuitive educational tool, the Mini CPU can also be applied in various other fields:
- **Control Algorithm Testing:** Used as a platform to simulate and test simple control algorithms in academic or research environments.
- **Embedded System Development:** Serves as a foundation for designing specialized microprocessors with custom instruction sets, suitable for small-scale embedded applications.
- **Hardware Simulation and Verification:** Helps students and engineers practice writing simulation programs, debugging, and optimizing designs before implementation on FPGAs or actual integrated circuits.

Overall, the Mini CPU is more than just a design exercise; it is an important stepping stone for learners to advance further in the field of computer architecture and microprocessor design.


## 6. Simulation and Verification (Testbench Simulation)

### 6.1. Testbench Structure

The testbench is written in Verilog with the name `tb_mini_cpu`, performing the following main tasks:

- **Clock generation:** A 50 MHz oscillator is created with a 20 ns period (10 ns high, 10 ns low) using the `forever #10 clk = ~clk` loop.
- **Reset signal generation:** The `rst_n` input is activated low for the first 45 ns, then goes high to release reset and start CPU operation.
- **Waveform dumping:** The `$dumpfile("wave.vcd")` and `$dumpvars(0, tb_mini_cpu)` commands are used to export waveforms to a VCD file, allowing detailed observation of internal design signals.
- **Status monitoring:** At each positive clock edge (posedge clk) after reset is released, the testbench prints the `debug_pc`, `debug_acc`, and `debug_dout` values to the console, enabling real-time tracking of CPU execution.
- **Simulation time:** The CPU runs for 2000 ns before simulation terminates with the `$finish` command.

### 6.2. Simulation Results

<img width="1673" height="938" alt="image" src="https://github.com/user-attachments/assets/c442f5db-7db9-4b8e-9c73-6e5064cf5fdb" />

**Result explanation:**
- At `t=45ns`, reset is released, and the PC starts from address `00`.
- The `LDI R0, 5` instruction at `0x00` executes, writing value 5 to register R0 (ACC remains unchanged).
- The `LDI R1, 3` instruction at `0x01` writes 3 to R1.
- The `ADD` instruction at `0x02` computes R0 + R1 = 8, and the result is written to ACC (`debug_acc = 08`).
- The `ST R0, 0x10` instruction at `0x03` stores the value of R0 (5) into RAM at address `0x10`, shown by `debug_dout = 05`.
- The `LD R2, 0x10` instruction at `0x04` reads data from RAM (5) into register R2, while ACC retains the value 8.
- The `XOR` instruction at `0x05` performs R2 ^ R1 = 5 ^ 3 = 6, updating ACC to `06`.
- The `JMP 0x02` instruction at `0x06` sets the PC back to address `0x02`, preparing to execute the loop again.

The simulation results perfectly match the example program described earlier, confirming that the Mini CPU operates as designed.

## 7. Physical Design Implementation (RTL-to-GDS Flow)

After completing the functional verification of the Mini CPU through simulation, the next step is to take the design through the **synthesis and physical layout generation flow** – a critical phase in preparing for actual integrated circuit fabrication. This flow consists of several key stages: logic synthesis, placement and routing, GDS file export, and layout verification.

### 7.1. Logic Synthesis with Yosys

The goal of this step is to convert the Verilog code at the Register Transfer Level (RTL) into a **gate-level netlist** based on a specific **standard cell library**.

- **Tool used:** Yosys
- **Implementation process:** Yosys reads all Verilog source files of the Mini CPU (including modules such as `control_unit`, `mini_alu`, `mini_regfile`, `pc_unit`, etc.), performs logic optimization, and maps the behavioral descriptions in the RTL code to basic logic gates available in the cell library (e.g., AND, OR, XOR, DFF).
- **Output:** A netlist file (`.v` format) detailing all instances and their interconnections. This serves as a crucial input for subsequent physical processing steps.

### 7.2. Placement and Routing with OpenROAD

With the netlist ready, the next step is to determine the physical locations of each cell on the chip surface and create the metal interconnections between them.

- **Tool used:** OpenROAD
- **Implementation process via the `run_openroad.tcl` script:**
  - **Input data handling:** Accepts the netlist from Yosys, timing constraint file (`.sdc`), and technology library.
  - **Floorplanning:** Determines chip dimensions, I/O pin locations, and allocates areas for major functional blocks.
  - **Placement:** Arranges logic cells into predefined rows and columns, optimizing for area and performance.
  - **Clock Tree Synthesis (CTS):** With support from the `constraints.sdc` file, OpenROAD builds a clock distribution tree, ensuring the `clk` signal reaches all flip-flops with minimal skew and meets timing requirements.
  - **Routing:** Creates metal interconnection paths between cells according to the netlist schematic.
- **Output:** A **DEF (Design Exchange Format)** file containing geometric information about cell positions and routing paths across various metal layers.

### 7.3. Complete Layout Generation and GDS Export with Magic

To prepare for manufacturing, the design must be converted from a positional description (DEF) into a detailed geometric representation of actual material layers.

- **Tool used:** Magic VLSI Layout Tool
- **Implementation process:**
  - **Import DEF file:** Using Tcl commands within Magic, the DEF file from OpenROAD is read along with the corresponding technology library.
  - **Layout inspection and editing (if needed):** Magic allows viewing and manual editing of the layout to ensure no geometric violations exist.
  - **Export GDS file:** Using the command `gds write mini_cpu.gds` to generate a GDSII file – the industry-standard format containing all physical parameters (diffusion layers, polysilicon, metal layers) required by the foundry.

### 7.4. Layout Verification and Visualization with KLayout

Before proceeding to "Tape-out" – sending the design for fabrication – a final verification is necessary to ensure no design rule violations exist.

- **Tool used:** KLayout
- **Role:**
  - **Detailed layout viewing:** KLayout provides the ability to display different color-coded layers, allowing zooming, panning, and precise measurements on the layout.
  - **Visual inspection:** Engineers can easily identify potential issues such as layer overlaps, insufficient spacing between paths, or connectivity problems.
- **Final result:** A complete Mini CPU layout, verified and ready for the **Tape-out** stage – the final step before mass production.

This RTL-to-GDS flow not only closes the integrated circuit design cycle from concept to physical product but also provides valuable hands-on experience for any IC design engineer seeking to deeply understand the synthesis and physical layout creation process.

---
