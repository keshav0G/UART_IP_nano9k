# UART IP Core for Tang Nano 9K FPGA

A custom UART IP Core implemented in Verilog RTL for the Gowin Tang Nano 9K FPGA. The project was developed from scratch without using vendor UART IP and includes a configurable baud-rate generator, UART transmitter, UART receiver, and an FSM-based packet parser.

The design was verified through simulation, synthesized on hardware, and validated by interfacing with an STM32F103C8T6 (Blue Pill) over UART. As a hardware demonstration, the FPGA receives two ASCII-encoded integers from the STM32, parses the packet, performs integer addition in hardware, and returns the computed result.

---

# Project Overview

| Item | Result |
|------|--------|
| FPGA | Gowin GW1NR-9 (Tang Nano 9K) |
| Language | Verilog HDL |
| Microcontroller | STM32F103C8T6 |
| Clock Frequency | 27 MHz |
| UART Configuration | 115200 baud, 8-N-1 |
| Achieved Fmax | **112.875 MHz** |
| Logic Utilization | **123 / 8640 (2%)** |
| Registers | **67 / 6693 (2%)** |
| BRAM | **0 / 26** |
| Timing | ✅ Passed |

Implementation reports are available in the `reports/` directory.

---

# Design Goals

- Implement UART completely in RTL without vendor IP
- Create reusable and parameterizable UART modules
- Interface an FPGA with an STM32 microcontroller
- Validate the complete design in simulation and on hardware
- Demonstrate a simple hardware accelerator communicating over UART

---


The design consists of four reusable RTL modules:

- Baud Rate Generator
- UART Receiver
- UART Transmitter
- Top-level UART Parser / Hardware Accelerator

---

# UART Protocol

The communication protocol uses ASCII packets.

### STM32 → FPGA

```
<num1>,<num2>\n
```

Example

```
12,37
```

### FPGA → STM32

```
49
```

---

# RTL Modules

## Baud Rate Generator

Generates baud enable pulses for both the transmitter and receiver.

**Features**

- Parameterizable clock frequency
- Parameterizable baud rate
- Independent TX and RX clock enables

---

## UART Transmitter

Implements a standard 8-N-1 UART transmitter using a finite state machine.

**Features**

- Start bit generation
- 8-bit data transmission
- Stop bit generation
- Busy flag
- Transmission complete flag

---

## UART Receiver

Receives asynchronous serial data and reconstructs bytes using oversampling.

**Features**

- Start bit detection
- Serial-to-parallel conversion
- Byte valid pulse
- Compatible with 115200 baud

---

## Packet Parser

Implements a simple FSM for decoding ASCII packets.

State flow

```
WAIT_NUM1
     │
     ▼
WAIT_NUM2
     │
     ▼
CALCULATE
```

Incoming ASCII characters are converted into binary integers before being processed by the arithmetic unit.

---


# Simulation & Verification

Before hardware implementation, the UART IP was functionally verified using **Icarus Verilog** on **EDA Playground**, with waveforms analyzed using **EPWave**.

The simulation environment was used to validate the RTL behavior, verify UART frame timing, and debug state-machine operation prior to FPGA synthesis.

---

## Simulation Environment

| Tool | Purpose |
|------|---------|
| EDA Playground | Online RTL simulation environment |
| Icarus Verilog | Verilog compiler and simulator |
| EPWave | Waveform visualization and debugging |

---

## Functional Verification

The following functionality was verified through simulation:

- Baud-rate generator timing
- UART transmitter (8-N-1 frame generation)
- UART receiver operation
- Start and stop bit detection
- Serial-to-parallel data reconstruction
- Byte-valid and transmission-complete signaling
- FSM state transitions
- End-to-end UART communication

---

## Waveform Verification

Simulation waveforms were analyzed using **EPWave** to verify:

- Correct UART frame format (8-N-1)
- Transmit and receive timing
- Baud clock enable generation
- Receiver sampling and byte reconstruction
- State machine progression
- Valid data reception (`0x55`, `0xAA`, `0x41`) and control signals

<p align="center">
<img src="docs/simulation waveform.png" width="950">
</p>

*EPWave timing diagram showing successful UART transmission and reception, including FSM state transitions, baud clock enables, serial data, and reconstructed bytes.*

---

## Running the Simulation

The RTL can be simulated locally using **Icarus Verilog** or directly in **EDA Playground**.

```bash
iverilog -o uart_tb rtl/*.v testbench/uart_tb.v
vvp uart_tb
gtkwave dump.vcd
```

The repository includes reusable testbenches under:

```
testbench/
```

# Hardware Demonstration

The STM32 periodically transmits packets to the FPGA.

Example

```
STM32
↓

10,22

↓

FPGA

↓

32
```

---

# Hardware Setup

<p align="center">
<img src="docs/hardware setup.jpeg" width="750">
</p>

The FPGA communicates directly with the STM32 Blue Pill over UART operating at **115200 baud**.

---

# STM32 USART Configuration

<p align="center">
<img src="docs/stm pinout.png" width="450">
</p>

USART1 Configuration

| Parameter | Value |
|-----------|------|
| TX | PA9 |
| RX | PA10 |
| Baud Rate | 115200 |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |

---

# Hardware Validation

## UART Transmission

Custom UART transmitter successfully driving a serial terminal.

<p align="center">
<img src="docs/printing hello on putty.png" width="650">
</p>

---

## UART Echo Test

Hardware loopback demonstration.

<p align="center">
<img src="docs/echo on putty.png" width="650">
</p>

---

## Hardware Arithmetic

Result displayed on the Tang Nano LED array after parsing UART packets.

<p align="center">
<img src="19 (6'b010011)on led array.jpeg" width="500">
</p>

---

# Synthesis Summary

```
Logic      : 123
Registers  : 67
BRAM       : 0
```

The complete design occupies approximately **2%** of the available logic resources on the GW1NR-9 FPGA.

---

# Timing Summary

| Parameter | Value |
|-----------|------:|
| Target Clock | 27 MHz |
| Achieved Fmax | **112.875 MHz** |
| Timing Violations | None |

The implemented design comfortably exceeds the required operating frequency.

---

# Repository Structure

```
UART_IP_nano9k
│
├── rtl/
│   ├── transmitter.v
│   ├── receiver.v
│   ├── baud_rate_gen.v
│   └── top_add.v
│
├── constraints/
│
├── stm32/
│
├── testbench/
│
├── reports/
│
├── docs/
│
└── README.md
```

---

# Skills Demonstrated

- Verilog RTL Design
- FPGA Design Flow
- UART Protocol Implementation
- Finite State Machine Design
- Hardware / Software Co-design
- FPGA Synthesis
- Static Timing Analysis
- Digital Logic Design
- Hardware Debugging
- Embedded Systems
- STM32 Development

---

# Future Improvements

- Dual UART interface (Application + Debug)
- FIFO buffers
- Configurable parity support
- Variable data width
- CRC generation
- APB / AXI-Lite wrapper
- Interrupt support
- DMA-compatible interface

---

# References

- Gowin Tang Nano 9K Documentation
- STM32F103 Reference Manual
- UART Protocol Specification

---
