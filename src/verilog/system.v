/*
    Modified by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

`timescale 1 ns / 1 ps

`define SHOW_IN_DISPLAYS 32'h1000_0000
`define CACHE_ADDR       32'h1000_0008
`define CACHE_DATA       32'h1000_000C
`define GET_MEMORY_ADDR  32'h1000_0004


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
	parameter FAST_MEMORY = 1;

	// 16384 32bit words = 64kB memory
	parameter MEM_SIZE = 16384;

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

	reg [31:0] memory [0:MEM_SIZE-1];

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

	// Store the num to display in the nexys 4 DDR (LEDS or 7-segment ).
	reg [31:0] num_to_display;
	reg [31:0] temp_addr;
	
	
	seven_segment_dec DISPLAY_ODD 
	(
		.clk			( clk ),           //
		.num_to_display	( num_to_display), // 32 bit number that will show on the displays.
		.reset			( reset ),         //
		.catodes		( catodes ),       // 7 segment code of digit for the display.
		.anodes			( anodes ) 		   // Select display that turn on.
	);
 
	// ******************************************

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];

			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end

			else
			if (mem_la_write && mem_la_addr == `SHOW_IN_DISPLAYS) begin
				out_byte_en    <= 1;
				out_byte       <= mem_la_wdata;
				num_to_display <= mem_la_wdata; // Store the desired number for use it in the circuit.
			end

			else 
			if (mem_la_write && mem_la_addr == `CACHE_ADDR) 
			begin
				memory [mem_la_wdata] <= mem_la_wdata+8;
				temp_addr = mem_la_wdata+4;	
			end
				
			else 
			if (mem_la_write && mem_la_addr == `CACHE_DATA) 
			begin
				memory [temp_addr] <= mem_la_wdata;		
			end		
		
				
			/**/
			else 
			if (mem_la_write && mem_la_addr == `GET_MEMORY_ADDR) 
			begin
				temp_addr <= mem_la_wdata;
			end	

			else 
			if (mem_la_read && mem_la_addr == `CACHE_ADDR) 
			begin
				mem_rdata <= memory[temp_addr];
			end					

			else 
			if (mem_la_read && mem_la_addr == `CACHE_DATA) 
			begin
				mem_rdata <= memory[temp_addr+4];
			end	
			

		end
	end else begin
		always @(posedge clk) begin
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
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end

			endcase
		end
	end endgenerate
endmodule
