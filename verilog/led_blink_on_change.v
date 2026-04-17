`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 06:24:04 PM
// Design Name: 
// Module Name: led_blink_on_change
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


module led_blink_on_change(
    input wire clk,
    input wire rst,
    input wire [31:0] counter,
    output reg led
);

reg [31:0] prev_counter = 0;
reg [31:0] timer = 0;
reg initialized = 0;

localparam ON_TIME  = 50_000_000 / 20; // adjust later
localparam OFF_TIME = 50_000_000 / 20;

reg [1:0] state = 0;
// 0 = idle
// 1 = ON
// 2 = OFF

always @(posedge clk) begin
    if (rst) begin
        //rst signal
        prev_counter <= 0;
        timer <= 0;
        state <= 0;
        led <= 0;
        initialized <= 0;
    end else begin
        if (!initialized) begin
            // no rst, but not initialized yet
            prev_counter <= counter;
            timer <= 0;
            state <= 0;
            led <= 0;
            initialized <= 1;
        end else begin
            // initialized - detect change of counter
            if ((counter != prev_counter) && (state == 0)) begin
                prev_counter <= counter;
                state <= 1;
                timer <= 0;
                led <= 1;
            end

            // timing FSM
            case (state)
                0: begin
                    led <= 0;
                end

                1: begin // ON
                    if (timer >= ON_TIME) begin
                        state <= 2;
                        timer <= 0;
                        led <= 0;
                    end else begin
                        timer <= timer + 1;
                    end
                end

                2: begin // OFF
                    if (timer >= OFF_TIME) begin
                        state <= 0;
                        timer <= 0;
                    end else begin
                        timer <= timer + 1;
                    end
                end
            endcase
        end
    end
end

endmodule