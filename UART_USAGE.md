# UART Communication Module Guide

This document provides information on using the UART transmitter module with the iCEstick FPGA.

## Overview

The UART (Universal Asynchronous Receiver-Transmitter) module enables serial communication between the FPGA and other devices such as a computer or microcontroller. This implementation provides a transmitter-only module that can be used to send debug information, status updates, or sensor data to a PC or other external devices.

## Hardware Connection

The iCEstick has a built-in FTDI FT2232H USB-to-Serial converter that makes it easy to establish UART communication:

1. Connect the iCEstick to your computer via USB
2. The UART TX pin is connected to the FTDI RX pin (Pin 8 on the FPGA)

## Module Interface

The UART TX module provides the following interface:

```verilog
module uart_tx #(
    parameter CLK_FREQ = 12_000_000,  // 12MHz for iCEstick
    parameter BAUD_RATE = 9_600       // Standard baud rate
) (
    input wire clk,          // System clock
    input wire reset,        // Asynchronous reset
    input wire tx_start,     // Start transmission
    input wire [7:0] tx_data,// Data to transmit
    output reg tx_busy,      // Transmission in progress
    output reg tx_done,      // Transmission complete pulse
    output reg tx_line       // TX line output (connect to FTDI)
);
```

## Usage Example

```verilog
// Example: Send a data byte
reg [7:0] data_to_send = 8'h55;
reg start_tx = 0;

// Start transmission on some condition
always @(posedge clk) begin
    if (condition_met && !uart_tx_busy) begin
        start_tx <= 1;
        data_to_send <= my_data;
    end else begin
        start_tx <= 0;
    end
end

// Instantiate the UART TX module
uart_tx my_uart (
    .clk(clk),
    .reset(reset),
    .tx_start(start_tx),
    .tx_data(data_to_send),
    .tx_busy(uart_tx_busy),
    .tx_done(uart_tx_done),
    .tx_line(uart_tx_pin)
);
```

## Receiving Data on PC

To receive and view the data transmitted from the FPGA:

1. On Linux, use screen or minicom:
   ```
   screen /dev/ttyUSB1 9600
   ```
   
2. On Windows, use PuTTY or TeraTerm:
   - COM Port: Check Device Manager for the appropriate COM port
   - Baud Rate: 9600
   - Data Bits: 8
   - Stop Bits: 1
   - Parity: None
   - Flow Control: None

## Customization

You can customize the UART module by changing the parameters:

1. **Baud Rate**: Change the BAUD_RATE parameter (common values: 9600, 19200, 115200)
2. **Clock Frequency**: If you're using a different clock, adjust CLK_FREQ

## Protocol Format

The module implements standard UART protocol:
- 1 start bit (low)
- 8 data bits (LSB first)
- 1 stop bit (high)
- No parity

## Additional Features

- **tx_busy** signal: Indicates when the module is transmitting
- **tx_done** signal: Pulses high for one clock cycle when transmission completes
- **State Machine**: Implements a 4-state machine (IDLE, START_BIT, DATA_BITS, STOP_BIT)

## Example Projects

1. **LED Status Monitor**: Transmit the status of LEDs over UART
2. **Counter Telemetry**: Send the value of various counters to PC for monitoring
3. **Debug Logger**: Send debug information during development