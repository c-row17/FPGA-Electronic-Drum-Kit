`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2026 01:19:01 AM
// Design Name: 
// Module Name: HiHat_tb
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

module HiHat_tb;

    logic clk = 0;
    logic reset = 1;
    logic trigger = 0;
    logic [7:0] velocity = 0;

    wire [7:0] amplitude;
    wire signed [8:0] tone_out;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Device Under Test
    HiHat dut (
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
        #100;

        // Test 1: Soft Hi-Hat (velocity 64)
        velocity = 8'd64;
        trigger = 1;
        #100;
        trigger = 0;

        // Wait for Hi-Hat to finish
        #50000000;

        // Test 2: Medium Hi-Hat (velocity 128)
        velocity = 8'd128;
        trigger = 1;
        #100;
        trigger = 0;

        #50000000;

        // Test 3: Maximum Hi-Hat (velocity 255)
        velocity = 8'd255;
        trigger = 1;
        #100;
        trigger = 0;

        #50000000;

        $display("Hi-Hat simulation complete");
        $finish;

    end

endmodule

