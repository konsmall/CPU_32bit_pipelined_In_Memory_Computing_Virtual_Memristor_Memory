# CPU_32bit_pipelined_Virtual_Memristor_Memory

**32-bit RISC-V Pipelined Processor with Memristive In Memory Computing capabilities.**

The design and implementation of a 32-bit Reduced Instruction Set Computer (RISC) processor. The project is aimed at developing a RISC-V processor with an extra Memristor based memory unit, that is capable of performing In Memory
Computing operations.



 

**Features**:

**32-bit Architecture**: Supports 32-bit data paths, registers, and instruction formats.

**Instruction Set**: Implements the basic Integer instructions set.

**Pipeline Stages**: Includes all stages such as Fetch, Decode, Execute, Memory Access, and Write-back.

**ALU (Arithmetic Logic Unit)**: Supports arithmetic and logical operations.

**Registers**: General-purpose registers, including a dedicated program counter (PC).

**Memory Access**: Support for load and store instructions between registers and memory.

**Control Unit**: Manages execution flow and instruction decoding.

**Virtual Crossbar Memristor Memory**: A Virtual memory designed to operate as an analogous Memristor crossbar memory, capable of not only storing and loading data but also performing in memory computing (IMC),
vy being able to perform and output the product of Logic operations between memory adresses. 

**Virtual Memristor Memory Controller**: Control Unit that translates the CPU RISC-V signal into pulses that can drive the Memristor Memory. Fully capable of stalling the pipeline when the logic of the Memristor memory is written
into the memristor memory itdelf, through feedback.

 

The Memristor Crossbar Memory is capable of performing AND, OR, XOR and NOT logical operations based on the SCOUTING LOGIC set:
https://doi.org/10.1016/j.aeue.2024.155505

 

![image](https://github.com/user-attachments/assets/817ea9b2-168a-4336-a7c4-32020257d7fd)


Binary code that can be inputed into the CPU memory for simulation processes can be produced using the following repo [ASSEMBLER_32_BIT_for_RISCV_Arechitecture] (https://github.com/konsmall/ASSEMBLER_32_BIT_for_RISCV_Arechitecture)

An OUTDATED and more simplified 16 bit architecture has also been set up: [CPU_16bit_pipelined_In_Memory_Computing_Virtual_Memristor_Memory] (https://github.com/konsmall/CPU_16bit_pipelined_In_Memory_Computing_Virtual_Memristor_Memory). 
