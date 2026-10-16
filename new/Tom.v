`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:07:59 PM
// Design Name: 
// Module Name: Tom
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


module Tom(
    input wire clk,
    input wire reset,
    input wire trigger,
    input wire [7:0] velocity,

    output reg [7:0] amplitude,
    output reg signed [8:0] tone_out
);

    reg [31:0] counter;
    reg [31:0] sound_counter;
    reg [31:0] half_period;

    reg [7:0] starting_amplitude;

    reg playing;
    reg wave_state;


    // -----------------------------------------
    // Pitch decay
    // -----------------------------------------
    always @(*) begin

        if (sound_counter < 2500000)
            half_period = 166667;   // ~300 Hz

        else if (sound_counter < 5000000)
            half_period = 208333;   // ~240 Hz

        else if (sound_counter < 7500000)
            half_period = 250000;   // ~200 Hz

        else
            half_period = 333333;   // ~150 Hz

    end


    // -----------------------------------------
    // Amplitude decay envelope
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            amplitude = 0;

        else if (sound_counter < 2000000)
            amplitude = starting_amplitude;          // 100%

        else if (sound_counter < 4000000)
            amplitude = starting_amplitude
                      - (starting_amplitude >> 2);   // ~75%

        else if (sound_counter < 6000000)
            amplitude = starting_amplitude >> 1;     // 50%

        else if (sound_counter < 8000000)
            amplitude = starting_amplitude >> 2;     // 25%

        else
            amplitude = starting_amplitude >> 3;     // 12.5%

    end


    // -----------------------------------------
    // Apply amplitude to waveform
    // -----------------------------------------
    always @(*) begin

        if (!playing)
            tone_out = 0;

        else if (wave_state)
            tone_out = $signed({1'b0, amplitude});

        else
            tone_out = -$signed({1'b0, amplitude});

    end


    // -----------------------------------------
    // Tom control and waveform timing
    // -----------------------------------------
    always @(posedge clk) begin

        if (reset) begin
            counter            <= 0;
            sound_counter      <= 0;
            starting_amplitude <= 0;
            wave_state         <= 0;
            playing            <= 0;
        end

        // Start tom
        else if (trigger && !playing) begin
            starting_amplitude <= velocity;
            counter            <= 0;
            sound_counter      <= 0;
            wave_state         <= 0;
            playing            <= 1;
        end

        // Tom currently playing
        else if (playing) begin

            sound_counter <= sound_counter + 1;

            // Generate waveform frequency
            if (counter >= half_period - 1) begin
                counter    <= 0;
                wave_state <= ~wave_state;
            end
            else begin
                counter <= counter + 1;
            end

            // End tom after 100 ms
            if (sound_counter >= 10000000 - 1) begin
                playing       <= 0;
                wave_state    <= 0;
                counter       <= 0;
                sound_counter <= 0;
            end

        end

        // Idle
        else begin
            counter    <= 0;
            wave_state <= 0;
        end

    end

endmodule
