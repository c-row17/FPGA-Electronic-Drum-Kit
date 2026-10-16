`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:07:42 PM
// Design Name: 
// Module Name: Snare
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


module Snare(
    input wire clk,
    input wire reset,
    input wire trigger,
    input wire [7:0] velocity,

    output reg [7:0] amplitude,
    output reg signed [8:0] tone_out
);

    reg [31:0] sound_counter;
    reg [31:0] tone_counter;

    reg [7:0] starting_amplitude;

    reg playing;
    reg tone_state;

    // 16-bit Linear Feedback Shift Register
    reg [15:0] lfsr;

    wire feedback;
    assign feedback = lfsr[15] ^ lfsr[13] ^
                      lfsr[12] ^ lfsr[10];

    // 180 Hz tonal component
    localparam TONE_HALF_PERIOD = 277778;

    // Update noise at approximately 40 kHz
    localparam NOISE_PERIOD = 2500;
    reg [11:0] noise_counter;


    // -----------------------------------------
    // Amplitude decay envelope
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            amplitude = 0;

        else if (sound_counter < 1600000)
            amplitude = starting_amplitude;          // 100%

        else if (sound_counter < 3200000)
            amplitude = starting_amplitude
                      - (starting_amplitude >> 2);   // ~75%

        else if (sound_counter < 4800000)
            amplitude = starting_amplitude >> 1;     // 50%

        else if (sound_counter < 6400000)
            amplitude = starting_amplitude >> 2;     // 25%

        else
            amplitude = starting_amplitude >> 3;     // 12.5%

    end


    // -----------------------------------------
    // Generate snare waveform
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            tone_out = 0;

        else if (lfsr[0] ^ tone_state)
            tone_out = $signed({1'b0, amplitude});

        else
            tone_out = -$signed({1'b0, amplitude});

    end


    // -----------------------------------------
    // Snare control
    // -----------------------------------------
    always @(posedge clk) begin

        if (reset) begin
            sound_counter      <= 0;
            tone_counter       <= 0;
            noise_counter      <= 0;
            starting_amplitude <= 0;
            playing            <= 0;
            tone_state         <= 0;
            lfsr               <= 16'hACE1;
        end

        // Start snare
        else if (trigger && !playing) begin
            sound_counter      <= 0;
            tone_counter       <= 0;
            noise_counter      <= 0;
            starting_amplitude <= velocity;
            playing            <= 1;
            tone_state         <= 0;
            lfsr               <= 16'hACE1;
        end

        // Snare currently playing
        else if (playing) begin

            sound_counter <= sound_counter + 1;

            // Generate 180 Hz tonal component
            if (tone_counter >= TONE_HALF_PERIOD - 1) begin
                tone_counter <= 0;
                tone_state   <= ~tone_state;
            end
            else begin
                tone_counter <= tone_counter + 1;
            end

            // Update pseudorandom noise
            if (noise_counter >= NOISE_PERIOD - 1) begin
                noise_counter <= 0;
                lfsr <= {lfsr[14:0], feedback};
            end
            else begin
                noise_counter <= noise_counter + 1;
            end

            // End snare after 80 ms
            if (sound_counter >= 8000000 - 1) begin
                playing       <= 0;
                sound_counter <= 0;
                tone_counter  <= 0;
                noise_counter <= 0;
                tone_state    <= 0;
            end

        end

        // Idle
        else begin
            tone_counter  <= 0;
            noise_counter <= 0;
            tone_state    <= 0;
        end

    end

endmodule
