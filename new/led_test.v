`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2026 02:46:02 AM
// Design Name: 
// Module Name: led_test
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


module led_test (
    input wire [1:0] sw,
    output wire [7:0] led
);

    assign led[0] = 1'b1;
    assign led[1] = 1'b1;
    assign led[2] = 1'b1;
    assign led[3] = 1'b1;
    assign led[4] = 1'b1;
    assign led[5] = 1'b1;
    assign led[6] = 1'b1;
    assign led[7] = 1'b1;

endmodule
