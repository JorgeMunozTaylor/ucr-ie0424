/*
    Modified by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

`timescale 1 ns / 1 ps

/* Memory position used to exchange data between the firmware and the CPU */
`define SHOW_IN_DISPLAYS 32'h1000_0000


module system (
	input             clk,
	input             resetn,
	output            trap,
	output reg [10:0] out_byte,
	output reg        out_byte_en,
	output     [7:0]  catodes,
	output     [7:0]  anodes
);

	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

	/* CPU memory */
	reg [31:0] memory [ 0:MEM_SIZE-1];

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	picorv32 picorv32_core
	(
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);
 

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;


	/*
	*********************************************
	Part 1: Display the last odd numbers.
	*********************************************
	*/

	reg [31:0] num_to_display; // Store the num to display in the nexys 4 DDR (LEDS or 7-segment ).

	/* Circuit that show the numbers on the displays */	
	seven_segment_dec DISPLAY_ODD 
	(
		.clk			( clk ),           //
		.num_to_display	( num_to_display), // 32 bit number that will show on the displays.
		.reset			( reset ),         //
		.catodes		( catodes ),       // 7 segment code of digit for the display.
		.anodes			( anodes ) 		   // Select display that turn on.
	);
 


    /************************************************/

	always @(wire_mem_ready) mem_ready = wire_mem_ready;
	always @(wire_mem_rdata) mem_rdata = wire_mem_rdata;

	/*
	******************************************
	Main memory driver circuit
	******************************************
	*/

	memory_driver  #(
		.SIZE  (14), 
		.WIDTH (32) 	
	) RAM_DRIVER
	(
		.clk       ( clk ),
    	.mem_valid ( ram_mem_valid ),
    	.mem_instr ( ram_mem_instr ),
    	.mem_addr  ( ram_mem_addr ),
    	.mem_wdata ( ram_mem_wdata ),
    	.mem_wstrb ( ram_mem_wstrb ),
    	.mem_ready ( ram_mem_ready ),
    	.mem_rdata ( ram_mem_rdata )		
	);

	







	/*
	******************************************
	Cache direct implementation
	******************************************
	*/
	wire		wire_mem_ready;
	wire [31:0] wire_mem_rdata;

    wire        ram_mem_valid;
    wire        ram_mem_instr;
    wire [31:0] ram_mem_addr;
    wire [31:0] ram_mem_wdata;
    wire [ 3:0] ram_mem_wstrb;

    wire        ram_mem_ready;
    wire [31:0] ram_mem_rdata;

	reg valido; // Set a memory transaction

	cache_direct #(
		.CACHE_SIZE_BITS (10), // 1024 block of cache
		.BLOCK_SIZE      (1),  // Cache number of words in bits
		.RAM_SIZE_BITS   (14), // 16384 blocks of main memory
		.WIDTH           (32)  // Address width
	) CACHE
	(
		.clk 			(clk),
		//*********************************************************
		.mem_valid		( valido ),
		.mem_instr		( mem_instr ), 
		.mem_addr		( mem_addr  ),
		.mem_wdata		( mem_wdata ),
		.mem_wstrb		( mem_wstrb ), // If 0 read, if not 0 write

		.mem_ready		( wire_mem_ready ),
		.mem_rdata		( wire_mem_rdata ),
		//*********************************************************
		.ram_mem_valid	( ram_mem_valid ),
		.ram_mem_instr	( ram_mem_instr ),
		.ram_mem_addr	( ram_mem_addr ),
		.ram_mem_wdata	( ram_mem_wdata ),
		.ram_mem_wstrb	( ram_mem_wstrb ),

		.ram_mem_ready	( ram_mem_ready ),
		.ram_mem_rdata	( ram_mem_rdata )
	);



	


	//****************************************

	integer wait_clk = 0;
	reg write;
	reg [ 13:0 ] addr;
	reg [ 31:0 ] data_in;
	wire [ 31:0 ] data_out;

	generate if (FAST_MEMORY) begin
		always @(posedge clk)		
		begin

			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];

			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) 
			begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];			
			end


			/* Get the odd number to display */
			else
			if (mem_la_write && mem_la_addr == `SHOW_IN_DISPLAYS) 
			begin
				out_byte_en    <= 1;
				out_byte       <= mem_la_wdata;
				num_to_display <= mem_la_wdata; 
			end


			/* Write the data and adress of the next data to the memory */
			else 
			if ( mem_la_write && (mem_la_addr > 32'h1000_0000) && (mem_la_addr >= 32'h1000_1000) && (mem_la_addr < 32'h1000_4000) ) 
			begin
					write   <= 1;
					data_in <= mem_la_wdata;
					addr    <= mem_la_addr[13:0];
					wait_clk  <= 0;
			end


			/* Get the data and the address tothe next data to the firmware */
			else 
			if ( mem_la_read && (mem_la_addr > 32'h1000_0000) && (mem_la_addr >= 32'h1000_1000) && (mem_la_addr < 32'h1000_4000) ) 
			begin

				/* To get the data from memory is necesary wait 1 clock cycle, the wait_clk register is used for that purpose */
				if ( wait_clk == 0 )
				begin
					write    <= 0;
					addr     <= mem_la_addr[13:0];
					wait_clk <= 1;
				end

				else if ( wait_clk == 1 )
				begin
					write     <= 0;
					mem_rdata <= data_out;
					wait_clk  <= 0;
				end
			end

		end
	end else begin
		always @(posedge clk) begin
			valido <= 0;

			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: 
				begin
					m_read_en <= 1;
				end

				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: 
				begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end

				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: 
				begin
					out_byte_en <= 1;
					out_byte    <= mem_wdata;
					mem_ready   <= 1;
				end


				mem_valid && !mem_ready && |mem_wstrb && (mem_addr > 32'h1000_0000) && (mem_addr >= 32'h1000_1000) && (mem_addr < 32'h1000_4000):
				begin
					valido <= 1;
				end

				mem_valid && !mem_ready && |mem_wstrb==0 && (mem_addr > 32'h1000_0000) && (mem_addr >= 32'h1000_1000) && (mem_addr < 32'h1000_4000):
				begin
					valido <= 1;
				end

			endcase
		end
	end endgenerate
endmodule
