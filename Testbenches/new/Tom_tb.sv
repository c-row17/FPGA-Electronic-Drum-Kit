`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 11:50:43 PM
// Design Name: 
// Module Name: Tom_tb
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


module Tom_tb;

    logic clk = 0;
    logic reset = 1;
    logic trigger = 0;
    logic [7:0] velocity = 0;

    wire [7:0] amplitude;
    wire signed [8:0] tone_out;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Device Under Test
    Tom dut (
        .clk(clk),
        .reset(reset),
        .trigger(trigger),
        .velocity(velocity),
        .amplitude(amplitude),
        .tone_out(tone_out)
    );

    initial begin

        // Initial reset
        #100;
        reset = 0;

        // Test 1: Soft tom
        velocity = 8'd64;
        trigger = 1;
        #100;
        trigger = 0;

        // Wait for sound to finish
        #110000000;

        // Test 2: Medium tom
        velocity = 8'd128;
        trigger = 1;
        #100;
        trigger = 0;

        #110000000;

        // Test 3: Maximum tom
        velocity = 8'd255;
        trigger = 1;
        #100;
        trigger = 0;

        #110000000;

        $display("Tom simulation complete");
        $finish;

    end

endmodule
