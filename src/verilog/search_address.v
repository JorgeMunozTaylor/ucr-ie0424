	/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/
	
module search_address 
(
	input 		 mem_la_write,
	input [31:0] mem_la_addr,

	output       out_byte_en
);	
		
	genvar i;
	generate
		for ( i=32'h1000; i<32'h4000; i=i+1 ) // Rows
		begin
		     
			assign out_byte_en = ( mem_la_write && mem_la_addr == (32'h1000 + i) ) ? 1:0;
			
		end
	endgenerate

endmodule