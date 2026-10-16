`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 09:49:52 PM
// Design Name: 
// Module Name: Kick
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


module Kick(
    input  wire clk,
    input  wire reset,
    input  wire trigger,
    input  wire [7:0] velocity,

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

        if (sound_counter < 1000000)
            half_period = 333333;   // ~150 Hz

        else if (sound_counter < 2000000)
            half_period = 416667;   // ~120 Hz

        else if (sound_counter < 3000000)
            half_period = 555556;   // ~90 Hz

        else
            half_period = 833333;   // ~60 Hz;

    end



    // Amplitude decay envelope
    always @(*) begin
    
        if (!playing)
            amplitude = 0;
    
        else if (sound_counter < 1000000)
            amplitude = starting_amplitude;          // 100%
    
        else if (sound_counter < 2000000)
            amplitude = starting_amplitude
                      - (starting_amplitude >> 2);   // 75%
    
        else if (sound_counter < 3000000)
            amplitude = starting_amplitude >> 1;     // 50%
    
        else if (sound_counter < 4000000)
            amplitude = starting_amplitude >> 2;     // 25%
    
        else
            amplitude = starting_amplitude >> 3;     // 12.5%
    
    end


    // Apply amplitude to waveform
    
    always @(*) begin

        if (!playing)
            tone_out = 0;

        else if (wave_state)
            tone_out = $signed({1'b0, amplitude});

        else
            tone_out = -$signed({1'b0, amplitude});

    end


  
    // Kick control and waveform timing

    always @(posedge clk) begin

        if (reset) begin
            counter       <= 0;
            sound_counter <= 0;
            starting_amplitude <= 0;
            wave_state    <= 0;
            playing       <= 0;
        end

        // Start kick
        else if (trigger && !playing) begin
        
            starting_amplitude <= velocity; 
            counter       <= 0;
            sound_counter <= 0;
            wave_state    <= 0;
            playing       <= 1;
        end

        // Kick currently playing
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

            // End kick after 50 ms
            if (sound_counter >= 5000000 - 1) begin
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
