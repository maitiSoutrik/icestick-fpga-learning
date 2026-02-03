// Testbench for UART Receiver
`timescale 1ns / 1ps

module uart_rx_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg rx_line;
    wire rx_ready;
    wire [7:0] rx_data;
    wire rx_error;
    
    // Instantiate UART receiver with faster baud rate for simulation
    uart_rx #(
        .CLK_FREQ(12_000_000),  // 12MHz
        .BAUD_RATE(115_200)     // Higher baud rate for faster simulation
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx_line(rx_line),
        .rx_ready(rx_ready),
        .rx_data(rx_data),
        .rx_error(rx_error)
    );
    
    // Clock generation - 12MHz (83.33ns period)
    initial clk = 0;
    always #41.67 clk = ~clk;
    
    // Calculate time for one bit at our baud rate (in ns)
    localparam BIT_PERIOD_NS = 1_000_000_000 / 115_200;
    
    // Task to transmit a byte over UART to our receiver
    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            rx_line = 1'b0;
            #BIT_PERIOD_NS;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_line = data[i];
                #BIT_PERIOD_NS;
            end
            
            // Stop bit (high)
            rx_line = 1'b1;
            #BIT_PERIOD_NS;
            
            // Small gap between transmissions
            #(BIT_PERIOD_NS / 2);
        end
    endtask
    
    // Task to send a framing error (bad stop bit)
    task uart_send_framing_error;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            rx_line = 1'b0;
            #BIT_PERIOD_NS;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_line = data[i];
                #BIT_PERIOD_NS;
            end
            
            // BAD Stop bit (should be high but send low)
            rx_line = 1'b0;
            #BIT_PERIOD_NS;
            
            // Return to idle state
            rx_line = 1'b1;
            #(BIT_PERIOD_NS / 2);
        end
    endtask
    
    // Monitor for rx_ready signal
    always @(posedge rx_ready) begin
        $display("Time=%0t: Byte received: 0x%02X (%c) [Error=%b]", 
                 $time, rx_data, 
                 (rx_data >= 32 && rx_data < 127) ? rx_data : ".", 
                 rx_error);
    end
    
    // Simulation
    initial begin
        // Let apio handle VCD file location
        $dumpvars(0, uart_rx_tb);
        
        // Initialize signals
        reset = 1;
        rx_line = 1;  // Idle state is high
        
        // Release reset after 100ns
        #100 reset = 0;
        
        // Wait a bit
        #200;
        
        // Send test bytes
        $display("Sending test data...");
        uart_send_byte(8'h55);  // Alternating 0/1
        
        // Wait for reception
        wait(rx_ready);
        #(BIT_PERIOD_NS * 2);
        
        // Send another byte
        uart_send_byte(8'hAA);  // Alternating 1/0
        
        // Wait for reception
        wait(rx_ready);
        #(BIT_PERIOD_NS * 2);
        
        // Send ASCII character
        uart_send_byte(8'h41);  // 'A'
        
        // Wait for reception
        wait(rx_ready);
        #(BIT_PERIOD_NS * 2);
        
        // Test error detection with bad stop bit
        $display("Testing framing error detection...");
        uart_send_framing_error(8'h42);  // 'B' with bad stop bit
        
        // Wait for reception
        wait(rx_ready);
        #(BIT_PERIOD_NS * 4);
        
        // Send one more valid byte
        uart_send_byte(8'h43);  // 'C'
        
        // Wait for reception
        wait(rx_ready);
        #(BIT_PERIOD_NS * 4);
        
        $display("Simulation complete!");
        $finish;
    end
    
    // Monitor UART RX activity
    initial begin
        $monitor("Time=%t, State=%d, RX=%b, Ready=%b, Error=%b, BitCnt=%d, BaudCnt=%d", 
                $time, uut.state, rx_line, rx_ready, rx_error, uut.bit_counter, uut.baud_counter);
    end

endmodule