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

## Current Project: LED Blink

A simple LED blinker that demonstrates:
- Clock division from 12MHz to visible rates
- Rotating LED pattern across LED1-LED3
- LED4 always on for power indicator
- LED5 fast blink from counter MSB

## Learning Log

### Day 1
- Set up Apio toolchain and project structure
- Created LED blink with rotating pattern (LED1-3) and fast blink (LED5)
- Built simulation-friendly testbench with parameterized counter
- Debugged LED5 bit indexing issue using GTKWave
- Set up GitHub Actions CI for automated lint, test, build
- Learned: Verilog parameters, testbench overrides, bit significance in counters

## Resources

- [Apio Documentation](https://fpgawars.github.io/apio/)
- [iCEstick User Manual](http://www.latticesemi.com/icestick)
- [ICE40 Family Handbook](https://www.latticesemi.com/products/fpgaandcpld/ice40)
