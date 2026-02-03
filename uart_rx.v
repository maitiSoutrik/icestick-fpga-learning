// UART Receiver Module
// Configurable baud rate, 8 data bits, 1 stop bit, no parity
// Simplified for FPGA implementation - no FIFO

module uart_rx #(
    parameter CLK_FREQ = 12_000_000,  // 12MHz for iCEstick
    parameter BAUD_RATE = 9_600,      // Standard baud rate
    parameter SAMPLE_MID = 1          // Sample in middle (1) or 3/4 through bit (0)
) (
    input wire clk,           // System clock
    input wire reset,         // Asynchronous reset
    input wire rx_line,       // RX line input (connect to FTDI)
    output reg rx_ready,      // Data ready pulse
    output reg [7:0] rx_data, // Received data
    output reg rx_error       // Framing error detected
);

    // Calculate baud rate divider
    localparam BAUD_DIVIDER = CLK_FREQ / BAUD_RATE;
    
    // Calculate sample point
    // In middle of bit (safer for inconsistent baud rates)
    localparam SAMPLE_POINT = SAMPLE_MID ? (BAUD_DIVIDER / 2) : (BAUD_DIVIDER * 3 / 4);
    
    // FSM states
    localparam IDLE = 3'b000;
    localparam START_BIT = 3'b001;
    localparam DATA_BITS = 3'b010;
    localparam STOP_BIT = 3'b011;
    localparam CLEANUP = 3'b100;
    
    // Registers
    reg [2:0] state = IDLE;
    reg [31:0] baud_counter = 0;  // Increased width to avoid warning
    reg [2:0] bit_counter = 0;
    reg [7:0] rx_shift_reg = 0;
    
    // Synchronize input to prevent metastability
    reg rx_sync_0 = 1;
    reg rx_sync_1 = 1;
    
    always @(posedge clk) begin
        rx_sync_0 <= rx_line;
        rx_sync_1 <= rx_sync_0;
    end
    
    // UART RX state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_ready <= 0;
            rx_data <= 0;
            rx_error <= 0;
            baud_counter <= 0;
            bit_counter <= 0;
            rx_shift_reg <= 0;
        end else begin
            // Default rx_ready to 0 (pulse only for one cycle)
            rx_ready <= 0;
            
            case (state)
                IDLE: begin
                    // Wait for start bit (falling edge)
                    if (rx_sync_1 == 1'b1 && rx_sync_0 == 1'b0) begin
                        state <= START_BIT;
                        baud_counter <= 0;
                        rx_error <= 0;  // Clear any previous errors
                    end
                end
                
                START_BIT: begin
                    // Verify the start bit by sampling at sample point
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                        
                        // Check if we're at sample point
                        if (baud_counter == SAMPLE_POINT) begin
                            // If line is high at sample point, it was a glitch
                            if (rx_sync_1 == 1'b1) begin
                                state <= IDLE;  // Go back to IDLE
                            end
                        end
                    end else begin
                        // Start bit confirmed, move to data bits
                        state <= DATA_BITS;
                        baud_counter <= 0;
                        bit_counter <= 0;
                    end
                end
                
                DATA_BITS: begin
                    // Sample data bits at specified sample point
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                        
                        // Sample the RX line at the sample point
                        if (baud_counter == SAMPLE_POINT) begin
                            rx_shift_reg[bit_counter] <= rx_sync_1;  // LSB first
                        end
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
                    // Wait for stop bit and check it's high
                    if (baud_counter < BAUD_DIVIDER - 1) begin
                        baud_counter <= baud_counter + 1;
                        
                        // Check stop bit at sample point
                        if (baud_counter == SAMPLE_POINT) begin
                            // Stop bit should be high (1)
                            if (rx_sync_1 == 1'b0) begin
                                rx_error <= 1;  // Framing error
                            end else begin
                                rx_error <= 0;  // No error
                            end
                        end
                    end else begin
                        // Transfer data to output register
                        rx_data <= rx_shift_reg;
                        rx_ready <= 1;  // Pulse rx_ready for one cycle
                        state <= CLEANUP;
                        baud_counter <= 0;
                    end
                end
                
                CLEANUP: begin
                    // Short wait state to ensure minimum gap between bytes
                    if (baud_counter < (BAUD_DIVIDER / 4) - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        state <= IDLE;
                        baud_counter <= 0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule