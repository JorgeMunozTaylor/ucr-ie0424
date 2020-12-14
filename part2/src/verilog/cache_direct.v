/*
    Modified by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

/**/
module cache_direct
#(
    /* This parameters are for cache memory */
    parameter CACHE_SIZE_BITS = 10,
    parameter BLOCK_SIZE = 1, // Cache number of words in bits

    /* This parameter are for main memory */ 
	parameter RAM_SIZE_BITS = 14,
	parameter WIDTH         = 32,

    /* Define the number of cache blocks in bits */
    parameter index_size  = CACHE_SIZE_BITS - BLOCK_SIZE, // Index block cache in bits 
    parameter offset_size = BLOCK_SIZE, // Word that will be selected in bits
    parameter tag_size    = WIDTH - index_size - offset_size // Tag in bits
)
(
    input clk,
    
    //*********************************************************
    //  izquierda
    input                mem_valid,
    input                mem_instr, // If 1 read, if 0 write
    input [(WIDTH-1):0]  mem_addr,
    input [(WIDTH-1):0]  mem_wdata,
    input [ 3:0 ]        mem_wstrb,

    output               mem_ready,
    output [(WIDTH-1):0] mem_rdata,

    //*********************************************************
    //   derecha
    // This signal activate when the data is not in the cache
    output reg               ram_mem_valid,
    output reg               ram_mem_instr,
    output reg [(WIDTH-1):0] ram_mem_addr,
    output reg [(WIDTH-1):0] ram_mem_wdata,
    output reg [ 3:0]        ram_mem_wstrb,

    input               ram_mem_ready,
    input [(WIDTH-1):0] ram_mem_rdata
);

    reg [ (2**index_size-1):0 ] valid = 0; // Valid bit, if 1 the cache line has an valid data
    reg [ (2**index_size-1):0 ] dirty = 0; // Dirty bit, if 1 the cache line can be replaced
    reg [ (WIDTH-index_size-offset_size-1) : 0 ] tag [ (2**index_size-1):0 ]; // Tag number.


    /************************************************/
    /* Define of cache memory and his inputs */
    /************************************************/
    reg  en = 1;
    reg  write;
    reg  [ CACHE_SIZE_BITS-1:0 ] addr;
    reg  [ WIDTH-1:0 ] data_in;
    wire [ WIDTH-1:0 ] data_out;
    wire ready;
    

    MEMORY #( .SIZE (CACHE_SIZE_BITS), .WIDTH (WIDTH) ) cache
    (
        .clk      ( clk ),
        .en       ( en ),
        .write    ( write ),
        .addr     ( addr ),
        .data_in  ( data_in ),
        .data_out ( data_out ),
        .ready    ( ready )
    );
    /************************************************/


    // Store the block position in the cache. Mapped block of the main memory address
    reg [ index_size-1:0 ] request_cache_block;
    reg [ (WIDTH-1):0 ] temp;
  
    reg wire_mem_ready;
    assign mem_ready = wire_mem_ready;

    reg [(WIDTH-1):0] wire_mem_rdata;
    assign mem_rdata = wire_mem_rdata;

    reg cache_read = 0; // If 1 the cache is readed

    /************************************************/

    always @( * )
    begin

        if ( mem_valid == 1 )
        begin

            //
            request_cache_block = mem_addr [ (index_size+offset_size-1) : offset_size ];
            temp = tag [ mem_addr [ (index_size+offset_size-1) : offset_size ] ];
            
            /************************************************/
            /*                   Read                       */
            /************************************************/
            if ( |mem_wstrb == 0 ) // Read
            begin

                /* Verify the valid bit, if 1 the block contain valid data */
                /* Valid is 1 */
                if ( valid [request_cache_block] == 1 )
                begin
                    /* If the tag is in the cache there is a HIT */
                    if ( tag [request_cache_block] == mem_addr [ (WIDTH-1) : index_size+offset_size ] )
                    begin
                        //Read cache
                        write = 0; 
                        addr  = (request_cache_block*2) + mem_addr [ offset_size-1 : 0 ];

                        // If ready=1 the cache returned the data
                        if( ready==1 )
                        begin
                            wire_mem_rdata = data_out;
                            wire_mem_ready = 1;
                        end

                        else
                            wire_mem_ready = 0;
                    end


                    // The tag is NOT in the cache, MISS
                    else
                    begin
                        
                        // Dirty=1
                        if ( dirty[request_cache_block] == 1 )
                        begin
                            // Read the cache block to write it in the RAM 
                            write = 0;
                            addr  = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];

                            /* If ready=1 The cache return the data, then write to RAM and update the cache */
                            if (ready==1)
                            begin
                                cache_read = 1;
                            end
                            else
                            begin
                                wire_mem_ready = 0;
                                cache_read     = 0;
                                ram_mem_valid  = 0;
                            end


                            if ( cache_read==1 )
                            begin
                                // Read the RAM
                                ram_mem_valid = 1;
                                ram_mem_addr  = mem_addr;
                                ram_mem_wstrb = 0;
                                
                                /* If ram_mem_ready=1 The RAM return the data, then write to cache and send it to the CPU */
                                if (ram_mem_ready==1)
                                begin 
                                    tag [request_cache_block]   = mem_addr [ (WIDTH-1) : index_size+offset_size ];
                                    dirty [request_cache_block] = 0;
                            
                                    write   = 1;
                                    addr    = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                                    data_in = ram_mem_rdata;  

                                    ram_mem_addr  = {temp, request_cache_block, mem_addr [(offset_size-1):0]};;
                                    ram_mem_wdata = data_out;

                                    wire_mem_ready = 1;
                                    wire_mem_rdata = ram_mem_rdata;
                                    cache_read     = 0;
                                end
                                else
                                    wire_mem_ready = 0;
                            end

                        end

                        // Dirty=0
                        else
                        begin
                                // Read the RAM
                                ram_mem_valid = 1;
                                ram_mem_addr  = mem_addr;
                                ram_mem_wstrb = 0;
                                
                                /* If ram_mem_ready=1 The RAM return the data, then write to cache and send it to the CPU */
                                if (ram_mem_ready==1)
                                begin 
                                    tag   [request_cache_block] = mem_addr [ (WIDTH-1) : index_size+offset_size ];
                                    dirty [request_cache_block] = 0;
                            
                                    write   = 1;
                                    addr    = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                                    data_in = ram_mem_rdata;  

                                    wire_mem_ready = 1;
                                    wire_mem_rdata = ram_mem_rdata;
                                end      

                                else
                                    wire_mem_ready = 0;                      
                        end

                    end

                end

                /* Valid is 0 */
                else
                begin
                    // Read the RAM
                    ram_mem_valid = 1;
                    ram_mem_addr  = mem_addr;
                    ram_mem_wstrb = 0;
                    
                    /* If ram_mem_ready=1 The RAM return the data, then write to cache and send it to the CPU */
                    if (ram_mem_ready==1)
                    begin  
                        tag   [request_cache_block] = mem_addr [ (WIDTH-1) : index_size+offset_size ];
                        dirty [request_cache_block] = 0;
                
                        write   = 1;
                        addr    = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                        data_in = ram_mem_rdata;  

                        wire_mem_ready = 1;
                        wire_mem_rdata = ram_mem_rdata;
                    end                      
                end
                
            end // End of read process





            /************************************************/
            /*                   Write                      */
            /*                Hit or miss?                  */
            /************************************************/
            else // Write
            begin
                  
                /* Verify the valid bit, if 1 the block contain valid data */
                /* Valid is 1 */
                if ( valid [request_cache_block] == 1 )
                begin
                    
                    /* If the tag is in the cache there is a HIT */
                    if ( tag [request_cache_block] == mem_addr [ (WIDTH-1) : index_size+offset_size ] )
                    begin
                        dirty [request_cache_block] = 1;
                        
                        write   = 1;
                        addr    = (request_cache_block*2) + mem_addr [ offset_size-1 : 0 ];
                        data_in = mem_wdata;

                        wire_mem_ready = 1;
                    end

                    /* The tag is not in the cache block, MISS */
                    else
                    begin
       
                        // Write cache data to the RAM
                        if ( dirty[request_cache_block] == 1 )
                        begin

                            // Read the cache 
                            write = 0;
                            addr  = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];

                            /* If ready=1 The cache return the data, then write to RAM and update the cache */
                            if (ready==1)
                            begin
                                ram_mem_valid = 1;
                                ram_mem_addr  = {temp, request_cache_block, mem_addr [(offset_size-1):0]};
                                ram_mem_wdata = data_out;
                                ram_mem_wstrb = 4;

                                tag [request_cache_block] = mem_addr [ (WIDTH-1) : index_size+offset_size ];
                        
                                write   = 1;
                                addr    = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                                data_in = mem_wdata;  

                                wire_mem_ready = 1;
                            end

                            else 
                                wire_mem_ready = 0;
                        end

                        // Write the data only to the cache 
                        else
                        begin
                        
                            dirty [request_cache_block] = 1;
                            tag   [request_cache_block] = mem_addr [ (WIDTH-1) : index_size+offset_size ];

                            write   = 1;
                            addr    = (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                            data_in = ram_mem_rdata;

                            wire_mem_ready = 1;
                        end
                        
                    end

                end






                /* Here Valid is 0 */
                else
                begin
                    //******SUMAR UN MISS
                    valid [request_cache_block] <= 1;
                    dirty [request_cache_block] <= 1;
                    tag   [request_cache_block] <= mem_addr [ (WIDTH-1) : index_size+offset_size ];
               
                    write   <= 1;
                    addr    <= (request_cache_block*2) + mem_addr [ (offset_size-1) : 0 ];
                    data_in <= mem_wdata;  

                    wire_mem_ready <= 1;             
                end

            end // End of write process

        end

        else
            wire_mem_ready <= 0;

    end
    /************************************************/

endmodule