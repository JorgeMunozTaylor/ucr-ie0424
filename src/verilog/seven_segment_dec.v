/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/


// Max number that can be displayed on the 7 segment displays.
`define MAX_NUM_TO_DISPLAY 32'b1111_1111_1111_1111_1111_1111_1111_1111 

// Delay for refresh the 7 segment displays.
`define LIMIT 100000


/*
    Part 2 circuit

    Decimal ascending counter.
*/
module seven_segment_dec 
(
    input clk,                  // Main clock of the circuit.   
    input [31:0] num_to_display,// 32 bit number that will show on the displays.
    input reset,                // Reset the circuit to 0's.

    output reg [7:0] catodes,   // 7 segment code of digit for the display.
    output reg [7:0] anodes     // Select display that turn on.
);

    wire    [31:0] BCD;
    wire    [7:0]  number_catodes [7:0];   // Wire used to connect the output catodes with the correct code.
    integer        num_counter        = 0; // Counter used to activate every display, one by one.
    integer        catodes_to_display = 0; // Store the code of the catodes that will be ON.
    reg     [7:0]  an_init            = 8'b1111_1110; // Initial anode value to display.


    always @(posedge clk)
    begin

        if ( num_counter == `LIMIT )
        begin

            // If reach the max possible number show 9999 9999 on the displays.
            if ( num_to_display <= `MAX_NUM_TO_DISPLAY )
            begin

                // Assign the correct code of the digit and anode to show.
                catodes = number_catodes[ catodes_to_display ];
                anodes  = an_init;

                // If the number to show need less displays turn them off.
                if ( num_to_display < 10)  anodes [7:1] = 7'b1111111;
                if ( num_to_display < 100) anodes [7:2] = 6'b111111;
                if ( num_to_display < 1000) anodes [7:3] = 5'b11111;
                if ( num_to_display < 10000) anodes [7:4] = 4'b1111;
                if ( num_to_display < 100000) anodes [7:5] = 3'b111;
                if ( num_to_display < 1000000) anodes [7:6] = 2'b11;
                if ( num_to_display < 10000000) anodes [7] = 1'b1;

                // Circular left shift.
                an_init = { an_init [6:0] , an_init [7] };

                // If the catodes_to_display is 7 assign 0 to it.
                if ( catodes_to_display == 7 ) catodes_to_display = 0; 
                else                           catodes_to_display = catodes_to_display+1;
            end
            else
            begin
                catodes = 8'b1001_0000;
                anodes  = 8'b0000_0000;   
            end

            // Re-init the num_counter (delay).
            num_counter = 0;

        end

        else num_counter = num_counter+1;

    end


    // Convert the number num_to_display to a 32 bit stream in BCD.
    binary_to_bcd BINARY_TO_BCD
    (
        .num_binary ( num_to_display ),
        .BCD        ( BCD )
    );

    // Here the BCD stream is traduce to a stream of 7-segment codes.
    bcd_to_7seg DISPLAY_7 ( .BCD ( BCD [31:28] ), .number_catodes ( number_catodes[7] ) );
    bcd_to_7seg DISPLAY_6 ( .BCD ( BCD [27:24] ), .number_catodes ( number_catodes[6] ) );
    bcd_to_7seg DISPLAY_5 ( .BCD ( BCD [23:20] ), .number_catodes ( number_catodes[5] ) );
    bcd_to_7seg DISPLAY_4 ( .BCD ( BCD [19:16] ), .number_catodes ( number_catodes[4] ) );
    bcd_to_7seg DISPLAY_3 ( .BCD ( BCD [15:12] ), .number_catodes ( number_catodes[3] ) );
    bcd_to_7seg DISPLAY_2 ( .BCD ( BCD [11:8]  ), .number_catodes ( number_catodes[2] ) );
    bcd_to_7seg DISPLAY_1 ( .BCD ( BCD [7:4]   ), .number_catodes ( number_catodes[1] ) );
    bcd_to_7seg DISPLAY_0 ( .BCD ( BCD [3:0]   ), .number_catodes ( number_catodes[0] ) );

endmodule


/*
    Convert a binary number to a BCD number.
*/
module binary_to_bcd
(
    input  [31:0] num_binary, // 32 bit binary number that will be converted to a BCD one.
    output reg [31:0] BCD     // Return the BCD stream of the binary number.
);

    reg [31:0] local_binary; // Copy the binary number passed.
    reg [31:0] num_BCD;      // Store the 7-segment code.     
    integer i;


    always @( num_binary )
    begin
        
        local_binary = num_binary; //Local copie of the binary number.
        num_BCD      = 0; //Final BCD number.

    
        for ( i=0; i<32; i=i+1 )
        begin
            num_BCD      = num_BCD << 1;
            num_BCD [0]  = local_binary [31];
            local_binary = local_binary << 1;

            if ( i!=31)
            begin
                if ( num_BCD [3:0]   >= 5 )  num_BCD [3:0]   = num_BCD [3:0]   + 3;
                if ( num_BCD [7:4]   >= 5 )  num_BCD [7:4]   = num_BCD [7:4]   + 3;
                if ( num_BCD [11:8]  >= 5 )  num_BCD [11:8]  = num_BCD [11:8]  + 3;
                if ( num_BCD [15:12] >= 5 )  num_BCD [15:12] = num_BCD [15:12] + 3;
                if ( num_BCD [19:16] >= 5 )  num_BCD [19:16] = num_BCD [19:16] + 3;
                if ( num_BCD [23:20] >= 5 )  num_BCD [23:20] = num_BCD [23:20] + 3;
                if ( num_BCD [27:24] >= 5 )  num_BCD [27:24] = num_BCD [27:24] + 3;
                if ( num_BCD [31:28] >= 5 )  num_BCD [31:28] = num_BCD [31:28] + 3;
            end
        end

        BCD = num_BCD; // Return the 7-segment code.

    end

endmodule


/*
    Convert a BCD number to a 7-segment one.
*/
module bcd_to_7seg
(
    input  [3:0] BCD,               // BCD number that will be converted to a 7-segment one.
    output reg [7:0] number_catodes // Return catodes value
);

    // Return the 7-segment code of a digit from 0 to F.
    always @(BCD)
        case( BCD )      
            4'b0000: number_catodes = 8'b1100_0000; // C0 
            4'b0001: number_catodes = 8'b1111_1001; // F9
            4'b0010: number_catodes = 8'b1010_0100; // A4
            4'b0011: number_catodes = 8'b1011_0000; // 70
            4'b0100: number_catodes = 8'b1001_1001; // 99
            4'b0101: number_catodes = 8'b1001_0010; // 92
            4'b0110: number_catodes = 8'b1000_0010; // 82
            4'b0111: number_catodes = 8'b1111_1000; // F8
            4'b1000: number_catodes = 8'b1000_0000; // 80
            4'b1001: number_catodes = 8'b1001_0000; // 90

            // For Hex numbers
            4'b1010: number_catodes = 8'b1000_1000; // 10
            4'b1011: number_catodes = 8'b1000_0011; // 11
            4'b1100: number_catodes = 8'b1100_0110; // 12 
            4'b1101: number_catodes = 8'b1010_0001; // 13
            4'b1110: number_catodes = 8'b1000_0110; // 14
            4'b1111: number_catodes = 8'b1000_1110; // 15
            default: number_catodes = 8'b1000_0000; // 80         
        endcase      
        
endmodule