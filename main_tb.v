// Testbench for LED blink module
`timescale 1ns / 1ps

module main_tb;

    reg CLK;
    wire LED1, LED2, LED3, LED4, LED5;

    // Instantiate the module under test
    main uut (
        .CLK(CLK),
        .LED1(LED1),
        .LED2(LED2),
        .LED3(LED3),
        .LED4(LED4),
        .LED5(LED5)
    );

    // Generate 12MHz clock (period = 83.33ns)
    initial CLK = 0;
    always #41.67 CLK = ~CLK;

    // Simulation
    initial begin
        // Let apio handle VCD file location - don't use $dumpfile()
        $dumpvars(0, main_tb);

        // Run for a short time to verify functionality
        #100000;  // 100 microseconds

        $display("LED1=%b, LED2=%b, LED3=%b, LED4=%b, LED5=%b",
                 LED1, LED2, LED3, LED4, LED5);

        $finish;
    end

endmodule
