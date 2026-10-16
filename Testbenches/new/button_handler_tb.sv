`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:10:51 PM
// Design Name: 
// Module Name: button_handler_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module button_handler_tb;

    logic clk = 0;
    logic reset = 1;
    logic button_in = 0;
    wire trigger;

    integer trigger_count = 0;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Device Under Test
    button_handler #(
        .DEBOUNCE_COUNT(10)
    ) dut (
        .clk(clk),
        .reset(reset),
        .button_in(button_in),
        .trigger(trigger)
    );

    // Count trigger pulses
    always @(posedge clk) begin
        if (reset)
            trigger_count <= 0;
        else if (trigger)
            trigger_count <= trigger_count + 1;
    end

    initial begin
        // Initial reset
        #20;
        reset = 0;

        // Test 1: Short button bounce
        button_in = 1;
        #30;
        button_in = 0;
        #200;

        if (trigger_count != 0)
            $error("Test 1 failed: Bounce caused a trigger");
        else
            $display("Test 1 passed: Bounce ignored");

        // Test 2: Valid button press
        button_in = 1;
        #200;

        if (trigger_count != 1)
            $error("Test 2 failed: Expected one trigger");
        else
            $display("Test 2 passed: One trigger detected");

        // Test 3: Hold button
        #500;

        if (trigger_count != 1)
            $error("Test 3 failed: Holding caused repeated triggers");
        else
            $display("Test 3 passed: No repeated triggers");

        // Test 4: Release and press again
        button_in = 0;
        #200;
        button_in = 1;
        #200;

        if (trigger_count != 2)
            $error("Test 4 failed: Second press not detected");
        else
            $display("Test 4 passed: Second press detected");

        $display("Button handler testing complete");
        $finish;
    end

endmodule
