`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:06:51 PM
// Design Name: 
// Module Name: button_handler
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


module button_handler(
    input wire clk,
    input wire reset,
    input wire button_in,
    output reg trigger
);

    // 100 MHz clock: 1,000,000 cycles = 10 ms
    parameter DEBOUNCE_COUNT = 1000000;

    reg button_meta = 0;
    reg button_sync = 0;
    reg button_stable = 0;

    reg [31:0] debounce_counter = 0;

    // Synchronize the asynchronous button input
    always @(posedge clk) begin
        if (reset) begin
            button_meta <= 0;
            button_sync <= 0;
        end
        else begin
            button_meta <= button_in;
            button_sync <= button_meta;
        end
    end

    // Debounce and generate one-clock trigger
    always @(posedge clk) begin
        if (reset) begin
            button_stable    <= 0;
            debounce_counter <= 0;
            trigger          <= 0;
        end
        else begin
            trigger <= 0;

            if (button_sync == button_stable) begin
                debounce_counter <= 0;
            end
            else if (debounce_counter >= DEBOUNCE_COUNT - 1) begin
                debounce_counter <= 0;
                button_stable <= button_sync;

                // Trigger only when the button becomes pressed
                if (button_sync)
                    trigger <= 1;
            end
            else begin
                debounce_counter <= debounce_counter + 1;
            end
        end
    end

endmodule
