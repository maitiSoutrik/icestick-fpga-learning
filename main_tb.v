// Testbench for LED blink module with UART
`timescale 1ns / 1ps

module main_tb;

    reg CLK;
    reg UART_RX;
    wire LED1, LED2, LED3, LED4, LED5, UART_TX;

    // Instantiate the module under test
    // Override parameters for faster simulation
    main #(
        .COUNTER_MAX(100),           // Faster LED rotation
        .UART_SEND_INTERVAL(1000)    // Faster UART transmission
    ) uut (
        .CLK(CLK),
        .UART_RX(UART_RX),
        .LED1(LED1),
        .LED2(LED2),
        .LED3(LED3),
        .LED4(LED4),
        .LED5(LED5),
        .UART_TX(UART_TX)
    );

    // Generate 12MHz clock (period = 83.33ns)
    initial begin 
        CLK = 0;
        UART_RX = 1;  // Idle state is high
    end
    always #41.67 CLK = ~CLK;

    // UART RX Monitor - simple UART receiver to log data
    reg [7:0] received_data;
    integer bit_time;
    
    task uart_receive;
        begin
            // Wait for start bit (falling edge on TX)
            @(negedge UART_TX);
            
            // Calculate bit time based on baud rate in testbench (in ns)
            bit_time = 1_000_000_000 / 9600;
            
            // Wait 1.5 bit times to sample in the middle of the first data bit
            #(bit_time * 1.5);
            
            // Sample 8 data bits
            for (integer i = 0; i < 8; i = i + 1) begin
                received_data[i] = UART_TX;  // LSB first
                #bit_time;  // Wait one bit time
            end
            
            // Verify stop bit
            if (UART_TX !== 1'b1) begin
                $display("ERROR: Invalid stop bit! Expected 1, got %b", UART_TX);
            end
            
            // Log received byte
            $display("UART RX: Received 0x%02X (%c)", received_data, 
                    (received_data >= 32 && received_data < 127) ? received_data : ".");
        end
    endtask
    
    // Task to send a byte to the FPGA's UART_RX input
    task send_byte_to_fpga;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            UART_RX = 1'b0;
            #bit_time;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                UART_RX = data[i];
                #bit_time;
            end
            
            // Stop bit (high)
            UART_RX = 1'b1;
            #bit_time;
            
            $display("Sent byte 0x%02X (%c) to FPGA", data, 
                    (data >= 32 && data < 127) ? data : ".");
        end
    endtask

    // Simulation
    initial begin
        // Let apio handle VCD file location - don't use $dumpfile()
        $dumpvars(0, main_tb);

        // Monitor LED pattern changes
        $monitor("Time=%0t ns | Pattern=%b%b%b LED4=%b LED5=%b | Counter=%0d",
                 $time, LED1, LED2, LED3, LED4, LED5, uut.counter);

        // Run for a while to see UART TX activity
        #1000000;  // 1 millisecond
        
        // Now simulate sending data to the FPGA
        $display("\nSending data to FPGA UART_RX...");
        
        // Calculate bit time based on baud rate in testbench (in ns)
        bit_time = 1_000_000_000 / 9600;
        
        // Send character 'A' (0x41)
        send_byte_to_fpga(8'h41);
        #(bit_time * 10);  // Wait for processing
        
        // Send character 'B' (0x42)
        send_byte_to_fpga(8'h42);
        #(bit_time * 10);
        
        // Send character '1' (0x31)
        send_byte_to_fpga(8'h31);
        #(bit_time * 10);
        
        // Run a bit longer to see echo responses
        #1000000;  // 1 millisecond

        $display("\nSimulation complete!");
        $display("Final: LED1=%b, LED2=%b, LED3=%b, LED4=%b, LED5=%b",
                 LED1, LED2, LED3, LED4, LED5);

        $finish;
    end
    
    // UART receiver process
    initial begin
        forever begin
            uart_receive();
        end
    end

endmodule
