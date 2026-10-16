`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:10:33 PM
// Design Name: 
// Module Name: drum_system_tb
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



module drum_system_tb;

    reg clk = 0;
    reg btnU = 0;
    reg btnD = 0;
    reg btnL = 0;
    reg btnR = 0;
    reg btnC = 0;

    reg [1:0] sw = 0;
    wire [7:0] led;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Device Under Test
    drum_system_top dut (
        .clk(clk),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .sw(sw),
        .led(led)
    );

    // Shorten debounce times for simulation
    defparam dut.kick_button.DEBOUNCE_COUNT = 10;
    defparam dut.tom_button.DEBOUNCE_COUNT = 10;
    defparam dut.snare_button.DEBOUNCE_COUNT = 10;
    defparam dut.hihat_button.DEBOUNCE_COUNT = 10;
    
    
    // ---------------------------------
    // Integrated audio mixer verification
    // ---------------------------------

    integer mixer_checks = 0;
    integer mixer_errors = 0;

    reg signed [10:0] expected_sum;
    reg signed [8:0] expected_audio;

    // Verify mixer output whenever drum waveforms change
    always @(negedge clk) begin

        expected_sum =
            $signed(dut.kick_tone) +
            $signed(dut.tom_tone) +
            $signed(dut.snare_tone) +
            $signed(dut.hihat_tone);

        expected_audio = expected_sum >>> 2;

        mixer_checks = mixer_checks + 1;

        if (dut.mixed_audio !== expected_audio) begin
            mixer_errors = mixer_errors + 1;

            $error("Mixer mismatch at %0t: Expected %0d, Got %0d",
                   $time, expected_audio, dut.mixed_audio);
        end
    end


    initial begin

        // Initial reset
        btnC = 1;
        #100;
        btnC = 0;
        #100;

        // ---------------------------------
        // Test 1: Kick only, velocity 64
        // ---------------------------------
        sw = 2'b00;
        btnD = 1;
        #1000;
        btnD = 0;
        #120000000;

        // ---------------------------------
        // Test 2: Tom only, velocity 128
        // ---------------------------------
        sw = 2'b01;
        btnR = 1;
        #1000;
        btnR = 0;
        #120000000;

        // ---------------------------------
        // Test 3: Snare only, velocity 192
        // ---------------------------------
        sw = 2'b10;
        btnL = 1;
        #1000;
        btnL = 0;
        #120000000;

        // ---------------------------------
        // Test 4: Hi-Hat only, velocity 255
        // ---------------------------------
        sw = 2'b11;
        btnU = 1;
        #1000;
        btnU = 0;
        #120000000;

        // ---------------------------------
        // Test 5: All four simultaneously
        // ---------------------------------
        sw = 2'b11;

        btnD = 1;
        btnR = 1;
        btnL = 1;
        btnU = 1;

        #1000;

        btnD = 0;
        btnR = 0;
        btnL = 0;
        btnU = 0;

        #120000000;

        // ---------------------------------
        // Test 6: Overlapping drum hits
        // ---------------------------------
        sw = 2'b01;

        // Kick first
        btnD = 1;
        #1000;
        btnD = 0;

        // Tom 10 ms later
        #10000000;
        btnR = 1;
        #1000;
        btnR = 0;

        // Snare 10 ms later
        #10000000;
        btnL = 1;
        #1000;
        btnL = 0;

        // Hi-Hat 10 ms later
        #10000000;
        btnU = 1;
        #1000;
        btnU = 0;

        #120000000;

        $display("-----------------------------------");
        $display("Integrated drum system testing complete");
        $display("Mixer checks performed: %0d", mixer_checks);
        $display("Mixer errors detected: %0d", mixer_errors);
        
        if (mixer_errors == 0)
            $display("PASS: Integrated audio mixer");
        else
            $display("FAIL: Integrated audio mixer");
        
        $finish;

    end

endmodule
