# iCEstick FPGA Learning Journey

![FPGA CI](https://github.com/maitiSoutrik/icestick-fpga-learning/workflows/FPGA%20CI/badge.svg)

This repository tracks my daily progress learning FPGA development with the iCEstick Eval Board (ICE40HX1K).

## Hardware

- Board: iCEstick Evaluation Kit
- FPGA: Lattice iCE40HX1K-TQ144
- Tools: Apio (open-source FPGA toolchain)

## Project Structure

- `main.v` - Top-level Verilog module
- `main_tb.v` - Testbench for simulation
- `icestick.pcf` - Pin constraint file for iCEstick
- `apio.ini` - Apio project configuration
- `.github/workflows/` - CI/CD automation

## Continuous Integration

Every push automatically:
- Runs `apio lint` to check code quality
- Runs `apio test` to verify testbenches pass
- Runs `apio build` to synthesize the bitstream
- Uploads the `.bin` file as a downloadable artifact (30-day retention)

## Quick Start

### Simulate
```bash
apio sim
```

### Build
```bash
apio build
```

### Upload to Board
```bash
apio upload
```

### Verify
```bash
apio lint
```

## Current Project: Bidirectional UART Communication

An enhanced FPGA design that demonstrates:
- Clock division from 12MHz to visible rates
- Rotating LED pattern across LED1-LED3
- LED4 indicates UART TX activity (lit during transmission)
- LED5 indicates UART RX activity (lit when data received)
- Full-duplex UART communication with configurable baud rate
- UART transmitter for sending status data
- UART receiver for accepting commands
- State machine design for sequential UART operations
- Automatic echo functionality (received data is sent back)
- Periodic status reporting over UART (9600 baud)

## Files

- `main.v` - Top-level module with LED controller and bidirectional UART
- `uart_tx.v` - UART transmitter module with configurable baud rate
- `uart_rx.v` - UART receiver module with configurable baud rate
- `main_tb.v` - Testbench for main module
- `uart_tx_tb.v` - Dedicated UART transmitter testbench
- `uart_rx_tb.v` - Dedicated UART receiver testbench
- `icestick.pcf` - Pin constraints for iCEstick board
- `UART_USAGE.md` - Documentation for using the UART TX module
- `BIDIRECTIONAL_UART.md` - Documentation for bidirectional UART communication

## Learning Log

### Day 1
- Set up Apio toolchain and project structure
- Created LED blink with rotating pattern (LED1-3) and fast blink (LED5)
- Built simulation-friendly testbench with parameterized counter
- Debugged LED5 bit indexing issue using GTKWave
- Set up GitHub Actions CI for automated lint, test, build
- Learned: Verilog parameters, testbench overrides, bit significance in counters

### Day 2
- Implemented UART transmitter module (`uart_tx.v`)
- Designed state machine for serial protocol handling
- Integrated UART with LED controller for telemetry
- Created comprehensive test bench for UART verification
- Added documentation for UART module usage
- Learned: UART protocol, FSM design, timing calculations for baud rate generation

### Day 2
- Added UART transmitter module (uart_tx.v)
- Implemented UART protocol with configurable baud rate
- Created state machine for sequential data transmission
- Integrated UART into main design to send telemetry data
- Modified LED behavior to indicate UART activity
- Enhanced testbench with UART monitoring capabilities
- Learned: FSM design, UART protocol, serial communication

### Day 3
- Implemented UART receiver module (uart_rx.v)
- Added input synchronization for metastability prevention
- Created robust receiver FSM with error detection
- Integrated bidirectional UART communication (full-duplex)
- Implemented automatic echo functionality
- Modified LED5 to indicate received data
- Created dedicated testbench for UART RX validation
- Added detailed documentation for bidirectional UART usage
- Learned: Input synchronization, framing error detection, full-duplex communication

## Resources

- [Apio Documentation](https://fpgawars.github.io/apio/)
- [iCEstick User Manual](http://www.latticesemi.com/icestick)
- [ICE40 Family Handbook](https://www.latticesemi.com/products/fpgaandcpld/ice40)
