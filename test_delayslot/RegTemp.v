`timescale 1ns / 1ps

module RegTemp
#(parameter SIZE = 32)
(reset, clk, choice, Data_i, Data_o);
    input reset;
    input clk;
	input [1:0] choice;
    input [SIZE-1:0] Data_i;
    output [SIZE-1:0] Data_o;
	
	(* max_fanout="90" *)reg [SIZE-1:0] Data_o;
    
    always@(posedge reset or posedge clk) begin
        if (reset) begin
            Data_o <= 0;
        end else begin
			if(choice==2'b00) begin
				Data_o <= 0;
			end
			else if(choice==2'b01) begin
				Data_o <= Data_i;
			end
			else begin
				Data_o <= Data_o;
			end
        end
    end
endmodule
