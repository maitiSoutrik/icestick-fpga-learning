module main #(
    parameter COUNTER_MAX = 6_000_000  // Default for hardware, can override in testbench
) (
    input wire CLK,
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output reg LED5
);

    // iCEstick has a 12MHz clock
    // To get a visible blink, divide it down to ~1Hz
    // 12,000,000 / 2 = 6,000,000 cycles for 0.5 second
    // For simulation, testbench can override with a smaller value

    reg [23:0] counter = 0;
    reg [2:0] led_pattern = 3'b001;

    always @(posedge CLK) begin
        if (counter == COUNTER_MAX - 1) begin
            counter <= 0;
            // Rotate LED pattern
            led_pattern <= {led_pattern[1:0], led_pattern[2]};
        end else begin
            counter <= counter + 1;
        end
    end

    // Assign pattern to LEDs (with some always on for visual feedback)
    always @(*) begin
        LED1 = led_pattern[0];
        LED2 = led_pattern[1];
        LED3 = led_pattern[2];
        LED4 = 1'b1;  // Always on
        LED5 = counter[5]; // Fast blink - bit 5 works for both sim and hardware
    end

endmodule
