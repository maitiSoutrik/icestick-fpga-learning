# iCEstick FPGA Learning Journey

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

## Current Project: LED Blink

A simple LED blinker that demonstrates:
- Clock division from 12MHz to visible rates
- Rotating LED pattern across LED1-LED3
- LED4 always on for power indicator
- LED5 fast blink from counter MSB

## Learning Log

### Day 1
- Set up Apio toolchain
- Created basic LED blink project
- Learned iCEstick pin mappings
- Initial commit

## Resources

- [Apio Documentation](https://fpgawars.github.io/apio/)
- [iCEstick User Manual](http://www.latticesemi.com/icestick)
- [ICE40 Family Handbook](https://www.latticesemi.com/products/fpgaandcpld/ice40)
