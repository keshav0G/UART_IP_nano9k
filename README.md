# UART_IP_nano9k
A custom UART IP Core written in Verilog RTL for the Tang Nano 9K FPGA. The project implements a parameterizable UART transmitter, receiver, baud-rate generator, and an FSM-based ASCII parser without using vendor IP. The design was validated in simulation and demonstrated on hardware by interfacing with an STM32F103C8T6 (Blue Pill).

The hardware demonstration consists of the STM32 transmitting two ASCII integers over UART, the FPGA parsing the received packet, performing integer addition in hardware, and returning the result.


| Item | Result |
|------|--------|
| Device | Gowin GW1NR-9 |
| Clock Frequency | 27 MHz |
| UART Configuration | 115200 baud, 8-N-1 |
| Achieved Fmax | **112.875 MHz** |
| Logic Utilization | **123 / 8640 (2%)** |
| Registers | **67 / 6693 (2%)** |
| BRAM | **0 / 26** |
| Timing | Passed |

Reports are available in the `/reports` directory.

---

## Features

- UART transmitter (8-N-1)
- UART receiver
- Parameterizable baud-rate generator
- FSM-based packet parser
- ASCII to binary conversion
- Binary to ASCII conversion
- STM32 hardware integration
- Synthesizable Verilog RTL

---
## Resource Utilization

```
Logic      : 123
Registers  : 67
BRAM       : 0
```

Target device utilization remains below **2%**, leaving significant headroom for future features such as FIFOs, parity generation, or CRC.
## Hardware Demonstration

The demonstration uses an STM32F103C8T6 as the UART host.

Example transaction

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
## Future Work

- Dual UART interface (Application + Debug)
- FIFO implementation
- Configurable parity
