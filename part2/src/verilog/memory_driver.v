/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

`timescale 1 ns / 1 ps

/* Module that define the RAM controller */
module memory_driver #(
	parameter SIZE  = 14, 
	parameter WIDTH = 32 
)
(
    input               clk,
    input               mem_valid,
    input               mem_instr,
    input [(WIDTH-1):0] mem_addr,
    input [(WIDTH-1):0] mem_wdata,
    input [ 3:0]        mem_wstrb,

    output               mem_ready,
    output [(WIDTH-1):0] mem_rdata
);

	reg en;
	reg write;
    reg wire_mem_ready;
    wire ready;
		
    
    /**/
    always @( * )
    begin
        
        if ( mem_valid )
        begin 
            en = 1;   

            if ( mem_wstrb == 0 )
            begin
                write = 0;

                if (ready)
                    wire_mem_ready = 1;
            end
            
            else
                write = 1;      
        end

        else
        begin
            wire_mem_ready = 0;
            en = 0;
        end
  
    end //Always end


    assign mem_ready = wire_mem_ready;


    
    




	/* 64kB of memory that store the linked list */
	MEMORY #(
		.SIZE  (14), 
		.WIDTH (32) 		
	) RAM
	(
		.clk      ( clk ),
		.en       ( en ),
		.write    ( write ),
		.addr     ( mem_addr [ (SIZE-1):0 ] ),
		.data_in  ( mem_wdata ),
		.data_out ( mem_rdata ),
        .ready    ( ready )		
	);

endmodule