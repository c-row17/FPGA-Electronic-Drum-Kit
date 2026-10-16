`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:11:13 PM
// Design Name: 
// Module Name: audio_mixer_tb
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

module audio_mixer_tb;

    reg signed [8:0] kick_tone;
    reg signed [8:0] tom_tone;
    reg signed [8:0] snare_tone;
    reg signed [8:0] hihat_tone;

    wire signed [8:0] mixed_audio;

    // Device Under Test
    audio_mixer dut (
        .kick_tone(kick_tone),
        .tom_tone(tom_tone),
        .snare_tone(snare_tone),
        .hihat_tone(hihat_tone),
        .mixed_audio(mixed_audio)
    );

    // Apply inputs and check the output
    task automatic check_mix(
        input signed [8:0] k,
        input signed [8:0] t,
        input signed [8:0] s,
        input signed [8:0] h,
        input signed [8:0] expected
    );
        begin
            kick_tone  = k;
            tom_tone   = t;
            snare_tone = s;
            hihat_tone = h;

            #10;

            if (mixed_audio !== expected)
                $error("FAIL: Expected %0d, got %0d",
                       expected, mixed_audio);
            else
                $display("PASS: Mixed output = %0d",
                         mixed_audio);
        end
    endtask

    initial begin

        // Test 1: Silence
        check_mix(0, 0, 0, 0, 0);

        // Test 2: Kick only
        check_mix(100, 0, 0, 0, 25);

        // Test 3: Two drums
        check_mix(100, 100, 0, 0, 50);

        // Test 4: All four drums
        check_mix(100, 100, 100, 100, 100);

        // Test 5: Maximum positive output
        check_mix(255, 255, 255, 255, 255);

        // Test 6: Maximum negative output
        check_mix(-255, -255, -255, -255, -255);

        // Test 7: Mixed positive and negative
        check_mix(200, -100, 50, 0, 37);

        // Test 8: Complete cancellation
        check_mix(100, -100, 50, -50, 0);

        // Test 9: Negative rounding
        check_mix(-101, 0, 0, 0, -26);

        // Test 10: Large mixed signals
        check_mix(255, 255, -255, -255, 0);

        $display("Audio mixer testing complete.");
        $finish;

    end

endmodule

