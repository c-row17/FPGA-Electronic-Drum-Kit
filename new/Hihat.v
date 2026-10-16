`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:08:14 PM
// Design Name: 
// Module Name: Hihat
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


module HiHat(
    input wire clk,
    input wire reset,
    input wire trigger,
    input wire [7:0] velocity,

    output reg [7:0] amplitude,
    output reg signed [8:0] tone_out
);

    reg [31:0] sound_counter;
    reg [31:0] noise_counter;

    reg [7:0] starting_amplitude;

    reg playing;

    // 16-bit Linear Feedback Shift Register
    reg [15:0] lfsr;

    wire feedback;
    assign feedback = lfsr[15] ^ lfsr[13] ^
                      lfsr[12] ^ lfsr[10];

    // 100 MHz / 2000 = 50 kHz
    localparam NOISE_PERIOD = 2000;


    // -----------------------------------------
    // Amplitude decay envelope
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            amplitude = 0;

        else if (sound_counter < 800000)
            amplitude = starting_amplitude;          // 100%

        else if (sound_counter < 1600000)
            amplitude = starting_amplitude
                      - (starting_amplitude >> 2);   // ~75%

        else if (sound_counter < 2400000)
            amplitude = starting_amplitude >> 1;     // 50%

        else if (sound_counter < 3200000)
            amplitude = starting_amplitude >> 2;     // 25%

        else
            amplitude = starting_amplitude >> 3;     // 12.5%

    end


    // -----------------------------------------
    // Generate Hi-Hat waveform
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            tone_out = 0;

        else if (lfsr[0])
            tone_out = $signed({1'b0, amplitude});

        else
            tone_out = -$signed({1'b0, amplitude});

    end


    // -----------------------------------------
    // Hi-Hat control
    // -----------------------------------------
    always @(posedge clk) begin

        if (reset) begin
            sound_counter      <= 0;
            noise_counter      <= 0;
            starting_amplitude <= 0;
            playing            <= 0;
            lfsr               <= 16'hACE1;
        end

        // Start Hi-Hat
        else if (trigger && !playing) begin
            sound_counter      <= 0;
            noise_counter      <= 0;
            starting_amplitude <= velocity;
            playing            <= 1;
            lfsr               <= 16'hACE1;
        end

        // Hi-Hat currently playing
        else if (playing) begin

            sound_counter <= sound_counter + 1;

            // Generate pseudorandom noise
            if (noise_counter >= NOISE_PERIOD - 1) begin
                noise_counter <= 0;
                lfsr <= {lfsr[14:0], feedback};
            end
            else begin
                noise_counter <= noise_counter + 1;
            end

            // End Hi-Hat after 40 ms
            if (sound_counter >= 4000000 - 1) begin
                playing       <= 0;
                sound_counter <= 0;
                noise_counter <= 0;
            end

        end

        // Idle
        else begin
            noise_counter <= 0;
        end

    end

endmodule
