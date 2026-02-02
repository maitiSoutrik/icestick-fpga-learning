// UART Transmitter Module
// Configurable baud rate, 8 data bits, 1 stop bit, no parity
// Simplified for FPGA implementation - no FIFO

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

    // Calculate baud rate divider
    localparam BAUD_DIVIDER = CLK_FREQ / BAUD_RATE;
    
    // FSM states
    localparam IDLE = 2'b00;
    localparam START_BIT = 2'b01;
    localparam DATA_BITS = 2'b10;
    localparam STOP_BIT = 2'b11;
    
    // Registers
    reg [1:0] state = IDLE;
    reg [31:0] baud_counter = 0;  // Increased width to avoid warning
    reg [2:0] bit_counter = 0;
    reg [7:0] tx_data_reg = 0;
    
    // UART TX state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx_busy <= 0;
            tx_done <= 0;
            tx_line <= 1;  // Idle state is high
            baud_counter <= 0;
            bit_counter <= 0;
            tx_data_reg <= 0;
        end else begin
            // Default tx_done to 0 (pulse only for one cycle)
            tx_done <= 0;
            
            case (state)
                IDLE: begin
                    tx_line <= 1;  // Idle state is high
                    tx_busy <= 0;
                    baud_counter <= 0;
                    
                    if (tx_start) begin
                        tx_data_reg <= tx_data;
                        tx_busy <= 1;
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    tx_line <= 0;  // Start bit is low
                    
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        baud_counter <= 0;
                        state <= DATA_BITS;
                        bit_counter <= 0;
                    end
                end
                
                DATA_BITS: begin
                    tx_line <= tx_data_reg[bit_counter];  // LSB first
                    
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        baud_counter <= 0;
                        
                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end else begin
                            state <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    tx_line <= 1;  // Stop bit is high
                    
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        tx_done <= 1;  // Pulse tx_done for one cycle
                        tx_busy <= 0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule