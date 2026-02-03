# Bidirectional UART Communication Guide

This document explains how to use the bidirectional UART implementation for the iCEstick FPGA.

## Overview

The iCEstick FPGA now supports full-duplex UART communication through:
1. **UART TX** - Transmitter that sends data from FPGA to PC
2. **UART RX** - Receiver that processes data sent from PC to FPGA

This enables interactive applications, command processing, and real-time control of FPGA functions.

## Hardware Connection

The iCEstick has a built-in FTDI FT2232H USB-to-Serial converter that enables simple bidirectional communication:

- **UART TX** (FPGA → PC): Connected to FTDI RX (Pin 8 on FPGA)
- **UART RX** (PC → FPGA): Connected to FTDI TX (Pin 9 on FPGA)

No additional wiring is needed - just connect the USB cable.

## Modules

### UART Transmitter

```verilog
uart_tx #(
    parameter CLK_FREQ = 12_000_000,
    parameter BAUD_RATE = 9_600
) (
    input  wire clk,
    input  wire reset,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg  tx_busy,
    output reg  tx_done,
    output reg  tx_line
);
```

### UART Receiver

```verilog
uart_rx #(
    parameter CLK_FREQ = 12_000_000,
    parameter BAUD_RATE = 9_600,
    parameter SAMPLE_MID = 1
) (
    input  wire clk,
    input  wire reset,
    input  wire rx_line,
    output reg  rx_ready,
    output reg  [7:0] rx_data,
    output reg  rx_error
);
```

## Current Implementation

The main module implements basic UART echo functionality:
1. Data received via UART RX is stored and displayed (LED5 indicates reception)
2. Received data is immediately echoed back via UART TX
3. Periodic status updates are still sent via the original TX logic

## PC Communication

### Terminal Settings
- Baud Rate: 9600
- Data Bits: 8
- Stop Bits: 1
- Parity: None
- Flow Control: None

### Linux
```bash
# Replace ttyUSB1 with your device
screen /dev/ttyUSB1 9600
```

### Windows
Use PuTTY, TeraTerm or similar with the appropriate COM port.

## Example Application Ideas

### Command Processor
Implement a simple command parser that responds to specific characters or sequences:

| Command | Action |
|---------|--------|
| '1'-'5' | Toggle specific LED |
| 'p'     | Pause/resume LED pattern |
| 's'     | Status report |
| 'r'     | Reset counters |

### Data Logger
Configure the FPGA to collect data (e.g., toggle counts, uptime) and send reports when requested.

### Interactive Demo
Create an interactive demo that shows different LED patterns based on user input.

## Advanced Features

### Error Handling
The RX module includes framing error detection. In the current implementation, errors are reported but not specifically handled.

### Baud Rate Configuration
Both TX and RX modules support configurable baud rates. Ensure both are set to the same rate (currently 9600 baud).

### Sample Point Adjustment
The RX module has a SAMPLE_MID parameter that allows tuning the sampling point within each bit period:
- 1: Sample in the middle of the bit (more tolerant of clock variations)
- 0: Sample at 3/4 through the bit period

## Future Enhancements

1. **Command Buffer**: Store multiple received bytes for complex commands
2. **UART RX FIFO**: Add a small FIFO to handle burst transmissions
3. **Parity Checking**: Add optional parity bit support
4. **Auto Baud Detection**: Automatically detect and adjust to the sender's baud rate
5. **Multiple UART Channels**: Implement additional UART interfaces for more complex systems