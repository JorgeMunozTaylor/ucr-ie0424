/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

`timescale 1 ns / 1 ps

/* Module that define a distributed synchronous memory, the size and width 
can be modified, this can be doing in the parameters SIZE, SIZE_BITS and WIDTH */
module MEMORY #(
	parameter SIZE  = 14, 
	parameter WIDTH = 32 
)
(
	input clk,
	input en,
	input write,
	input [ (SIZE-1):0] addr,
	input [ (WIDTH-1):0 ] data_in,

	output reg [(WIDTH-1):0] data_out
);
	reg [(WIDTH-1):0] memory [ 0:(2**SIZE-1)];
	

	always @(posedge clk)
	begin
		if (en)
		begin
			if ( write )
				memory [addr] <= data_in;
			else
				data_out <= memory [addr];	
		end
	end

endmodule