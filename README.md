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

## Current Project: LED Blink with UART Telemetry

An enhanced FPGA design that demonstrates:
- Clock division from 12MHz to visible rates
- Rotating LED pattern across LED1-LED3
- LED4 indicates UART activity (lit during transmission)
- LED5 fast blink from counter MSB
- UART transmitter with configurable baud rate
- State machine design for sequential UART data transmission
- Periodic status reporting over UART (9600 baud)

## Files

- `main.v` - Top-level module with LED controller and UART integration
- `uart_tx.v` - UART transmitter module with configurable baud rate
- `main_tb.v` - Testbench for main module
- `uart_tx_tb.v` - Dedicated UART transmitter testbench
- `icestick.pcf` - Pin constraints for iCEstick board
- `UART_USAGE.md` - Documentation for using the UART module

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

## Resources

- [Apio Documentation](https://fpgawars.github.io/apio/)
- [iCEstick User Manual](http://www.latticesemi.com/icestick)
- [ICE40 Family Handbook](https://www.latticesemi.com/products/fpgaandcpld/ice40)
