// Testbench for LED blink module with UART
`timescale 1ns / 1ps

module main_tb;

    reg CLK;
    wire LED1, LED2, LED3, LED4, LED5, UART_TX;

    // Instantiate the module under test
    // Override parameters for faster simulation
    main #(
        .COUNTER_MAX(100),           // Faster LED rotation
        .UART_SEND_INTERVAL(1000)    // Faster UART transmission
    ) uut (
        .CLK(CLK),
        .LED1(LED1),
        .LED2(LED2),
        .LED3(LED3),
        .LED4(LED4),
        .LED5(LED5),
        .UART_TX(UART_TX)
    );

    // Generate 12MHz clock (period = 83.33ns)
    initial CLK = 0;
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

    // Simulation
    initial begin
        // Let apio handle VCD file location - don't use $dumpfile()
        $dumpvars(0, main_tb);

        // Monitor LED pattern changes
        $monitor("Time=%0t ns | Pattern=%b%b%b LED4=%b LED5=%b | Counter=%0d",
                 $time, LED1, LED2, LED3, LED4, LED5, uut.counter);

        // Run long enough to see multiple UART transmissions
        #2000000;  // 2 milliseconds

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
