`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 10:07:07 PM
// Design Name: 
// Module Name: velocity_select
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


module velocity_select(
    input wire [1:0] sw,
    output reg [7:0] velocity
);

    always @(*) begin
        case (sw)
            2'b00: velocity = 8'd64;
            2'b01: velocity = 8'd128;
            2'b10: velocity = 8'd192;
            2'b11: velocity = 8'd255;
            default: velocity = 8'd64;
        endcase
    end

endmodule
