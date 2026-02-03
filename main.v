module main #(
    parameter COUNTER_MAX = 6_000_000,  // Default for hardware, can override in testbench
    parameter UART_SEND_INTERVAL = 12_000_000  // Send UART data every second
) (
    input wire CLK,
    input wire UART_RX,  // UART RX line (connect to FTDI)
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output reg LED5,
    output wire UART_TX  // UART TX line (connect to FTDI)
);

    // iCEstick has a 12MHz clock
    // To get a visible blink, divide it down to ~1Hz
    // 12,000,000 / 2 = 6,000,000 cycles for 0.5 second
    // For simulation, testbench can override with a smaller value

    // LED control registers
    reg [23:0] counter = 0;
    reg [2:0] led_pattern = 3'b001;

    // UART TX control signals
    reg uart_tx_start = 0;
    reg [7:0] uart_tx_data = 0;
    wire uart_tx_busy;
    wire uart_tx_done;
    reg [3:0] uart_state = 0;
    reg [23:0] uart_counter = 0;
    
    // UART RX control signals
    wire uart_rx_ready;
    wire [7:0] uart_rx_data;
    wire uart_rx_error;
    reg uart_rx_received = 0;
    reg [7:0] uart_rx_last_byte = 0;
    
    // Button debounce for reset
    reg [15:0] reset_debounce = 0;
    reg reset_stable = 0;
    wire reset = reset_stable;

    // UART Transmitter instance
    uart_tx #(
        .CLK_FREQ(12_000_000),
        .BAUD_RATE(9_600)
    ) uart_tx_inst (
        .clk(CLK),
        .reset(reset),
        .tx_start(uart_tx_start),
        .tx_data(uart_tx_data),
        .tx_busy(uart_tx_busy),
        .tx_done(uart_tx_done),
        .tx_line(UART_TX)
    );
    
    // UART Receiver instance
    uart_rx #(
        .CLK_FREQ(12_000_000),
        .BAUD_RATE(9_600)
    ) uart_rx_inst (
        .clk(CLK),
        .reset(reset),
        .rx_line(UART_RX),
        .rx_ready(uart_rx_ready),
        .rx_data(uart_rx_data),
        .rx_error(uart_rx_error)
    );

    // LED blinking logic
    always @(posedge CLK) begin
        if (counter == COUNTER_MAX - 1) begin
            counter <= 0;
            // Rotate LED pattern
            led_pattern <= {led_pattern[1:0], led_pattern[2]};
        end else begin
            counter <= counter + 1;
        end
    end

    // UART state machine
    always @(posedge CLK) begin
        // Default values
        uart_tx_start <= 0;  // Pulse signal, active for 1 cycle
        
        // UART transmission state machine
        case (uart_state)
            0: begin  // Wait state
                if (uart_rx_ready) begin
                    // Received data from UART - echo it back
                    uart_tx_data <= uart_rx_data;
                    uart_tx_start <= 1;
                    uart_state <= 7;  // Go to echo wait state
                end else if (uart_counter >= UART_SEND_INTERVAL) begin
                    uart_counter <= 0;
                    uart_state <= 1;  // Go to first transmit state
                end else begin
                    uart_counter <= uart_counter + 1;
                end
            end
            
            1: begin  // Send LED pattern status
                if (!uart_tx_busy) begin
                    uart_tx_data <= {5'b00000, led_pattern};  // Format: 0bXXXXX_LLL
                    uart_tx_start <= 1;
                    uart_state <= 2;
                end
            end
            
            2: begin  // Wait for transmission to complete
                if (uart_tx_done) begin
                    uart_state <= 3;
                end
            end
            
            3: begin  // Send counter MSBs
                if (!uart_tx_busy) begin
                    uart_tx_data <= counter[23:16];  // Send MSB of counter
                    uart_tx_start <= 1;
                    uart_state <= 4;
                end
            end
            
            4: begin  // Wait for transmission to complete
                if (uart_tx_done) begin
                    uart_state <= 5;
                end
            end
            
            5: begin  // Send ASCII newline
                if (!uart_tx_busy) begin
                    uart_tx_data <= 8'h0A;  // Newline character
                    uart_tx_start <= 1;
                    uart_state <= 6;
                end
            end
            
            6: begin  // Wait for transmission to complete and go back to wait state
                if (uart_tx_done) begin
                    uart_state <= 0;  // Go back to wait state
                end
            end
            
            7: begin  // Wait for echo transmission to complete
                if (uart_tx_done) begin
                    uart_state <= 0;  // Go back to wait state
                end
            end
            
            default: uart_state <= 0;
        endcase
    end

    // UART RX handling logic
    always @(posedge CLK) begin
        // Reset the received flag
        if (uart_rx_received && counter[10]) begin  // Clear after a short delay
            uart_rx_received <= 0;
        end
        
        // Handle received byte
        if (uart_rx_ready) begin
            uart_rx_last_byte <= uart_rx_data;
            uart_rx_received <= 1;  // Set flag to show we received data
        end
    end

    // Assign pattern to LEDs
    always @(*) begin
        LED1 = led_pattern[0];
        LED2 = led_pattern[1];
        LED3 = led_pattern[2];
        LED4 = uart_tx_busy;  // Show UART TX activity
        LED5 = uart_rx_received; // Show when data received (stays on longer)
    end

endmodule
