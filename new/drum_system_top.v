`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:06:24 PM
// Design Name: 
// Module Name: drum_system_top
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


module drum_system_top(
    input wire clk,
    input wire btnU,
    input wire btnD,
    input wire btnL,
    input wire btnR,
    input wire btnC,
    input wire [1:0] sw,

    output wire [7:0] led
);

    // -----------------------------------------
    // Internal signals
    // -----------------------------------------

    wire kick_trigger;
    wire tom_trigger;
    wire snare_trigger;
    wire hihat_trigger;
    
    wire [7:0] velocity;

    wire signed [8:0] kick_tone;
    wire signed [8:0] tom_tone;
    wire signed [8:0] snare_tone;
    wire signed [8:0] hihat_tone;
    
    wire signed [8:0] mixed_audio;


    wire [7:0] kick_amplitude;
    wire [7:0] tom_amplitude;
    wire [7:0] snare_amplitude;
    wire [7:0] hihat_amplitude;

    // -----------------------------------------
    // Velocity selection
    // -----------------------------------------

    velocity_select velocity_control (
        .sw(sw),
        .velocity(velocity)
    );


    // -----------------------------------------
    // Button handlers
    // -----------------------------------------

    // BTND - Kick
    button_handler kick_button (
        .clk(clk),
        .reset(btnC),
        .button_in(btnD),
        .trigger(kick_trigger)
    );

    // BTNR - Tom
    button_handler tom_button (
        .clk(clk),
        .reset(btnC),
        .button_in(btnR),
        .trigger(tom_trigger)
    );

    // BTNL - Snare
    button_handler snare_button (
        .clk(clk),
        .reset(btnC),
        .button_in(btnL),
        .trigger(snare_trigger)
    );
    
    button_handler hihat_button (
        .clk(clk),
        .reset(btnC),
        .button_in(btnU),
        .trigger(hihat_trigger)
    );


    // -----------------------------------------
    // Drum generators
    // -----------------------------------------

    Kick kick_drum (
        .clk(clk),
        .reset(btnC),
        .trigger(kick_trigger),
        .velocity(velocity),
        .amplitude(kick_amplitude),
        .tone_out(kick_tone)
    );

    Tom tom_drum (
        .clk(clk),
        .reset(btnC),
        .trigger(tom_trigger),
        .velocity(velocity),
        .amplitude(tom_amplitude),
        .tone_out(tom_tone)
    );

    Snare snare_drum (
        .clk(clk),
        .reset(btnC),
        .trigger(snare_trigger),
        .velocity(velocity),
        .amplitude(snare_amplitude),
        .tone_out(snare_tone)
    );
    
    HiHat hihat_drum (
        .clk(clk),
        .reset(btnC),
        .trigger(hihat_trigger),
        .velocity(velocity),
        .amplitude(hihat_amplitude),
        .tone_out(hihat_tone)
    );
    
    // -----------------------------------------
    // Audio mixer
    // -----------------------------------------
    
    audio_mixer mixer (
        .kick_tone(kick_tone),
        .tom_tone(tom_tone),
        .snare_tone(snare_tone),
        .hihat_tone(hihat_tone),
        .mixed_audio(mixed_audio)
    );


    // -----------------------------------------
    // LED indicators
    // -----------------------------------------

    // Drum activity LEDs
    assign led[0] = (kick_amplitude != 0);
    assign led[1] = (tom_amplitude != 0);
    assign led[2] = (snare_amplitude != 0);
    assign led[3] = (hihat_amplitude != 0);
    
    // Velocity indicator LEDs
    assign led[4] = 1'b1;
    assign led[5] = sw[0] | sw[1];
    assign led[6] = sw[1];
    assign led[7] = sw[1] & sw[0];
    
endmodule