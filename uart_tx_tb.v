// Testbench for UART Transmitter
`timescale 1ns / 1ps

module uart_tx_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;
    wire tx_done;
    wire tx_line;
    
    // Instantiate UART transmitter with faster baud rate for simulation
    uart_tx #(
        .CLK_FREQ(12_000_000),  // 12MHz
        .BAUD_RATE(115_200)     // Higher baud rate for faster simulation
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_line(tx_line)
    );
    
    // Clock generation - 12MHz (83.33ns period)
    initial clk = 0;
    always #41.67 clk = ~clk;
    
    // Calculate time for one bit at our baud rate (in ns)
    localparam BIT_PERIOD_NS = 1_000_000_000 / 115_200;
    
    // Simulation
    initial begin
        // Let apio handle VCD file location
        $dumpvars(0, uart_tx_tb);
        
        // Initialize signals
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;
        
        // Release reset after 100ns
        #100 reset = 0;
        
        // Wait a bit
        #200;
        
        // Send byte 0x55 (alternating 0 and 1)
        tx_data = 8'h55;
        tx_start = 1;
        #100 tx_start = 0;  // Pulse tx_start for one cycle
        
        // Wait until transmission completes
        @(posedge tx_done);
        $display("Transmitted 0x55 successfully");
        
        // Wait a bit
        #(BIT_PERIOD_NS * 2);
        
        // Send byte 0xAA (alternating 1 and 0)
        tx_data = 8'hAA;
        tx_start = 1;
        #100 tx_start = 0;
        
        // Wait until transmission completes
        @(posedge tx_done);
        $display("Transmitted 0xAA successfully");
        
        // Wait a bit
        #(BIT_PERIOD_NS * 2);
        
        // Send byte 0x3C (ASCII '<')
        tx_data = 8'h3C;
        tx_start = 1;
        #100 tx_start = 0;
        
        // Wait until transmission completes
        @(posedge tx_done);
        $display("Transmitted '<' successfully");
        
        // Wait a bit more to observe the waveform
        #(BIT_PERIOD_NS * 10);
        
        $display("Simulation complete!");
        $finish;
    end
    
    // Monitor UART TX activity
    initial begin
        $monitor("Time=%t, State=%d, TX=%b, Busy=%b, Done=%b, BitCnt=%d, BaudCnt=%d", 
                $time, uut.state, tx_line, tx_busy, tx_done, uut.bit_counter, uut.baud_counter);
    end

endmodule