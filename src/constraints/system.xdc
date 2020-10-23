#    Modified by Jorge Munoz Taylor
#    A53863
#    Project 4: part 2
#    Digital circuit laboratory I
#    II-2020

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# clk port, connect the system input clk with pin E3.
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];

# Configure the period time of the clk.
create_clock -add -name sys_clk_pin -period 23.00 [get_ports {clk}];

# switch port, connect the input resetn of system.v with the port V10.
set_property -dict { PACKAGE_PIN V10  IOSTANDARD LVCMOS33 } [get_ports { resetn }];

# leds

set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { out_byte_en }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { trap }];


# leds
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { out_byte[0] }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { out_byte[1] }];
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { out_byte[2] }];
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { out_byte[3] }];
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { out_byte[4] }];
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { out_byte[5] }];
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { out_byte[6] }];
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { out_byte[7] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { out_byte[8] }];
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { out_byte[9] }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { out_byte[10] }];


# 7 segment display

# Connect the catodes of the displays with the output "catodes[7:0]" of the system.v
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { catodes[0] }]; 
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { catodes[1] }]; 
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { catodes[2] }]; 
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { catodes[3] }]; 
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { catodes[4] }]; 
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { catodes[5] }]; 
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { catodes[6] }]; 
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { catodes[7] }]; 

# Connect the anodes of the displays with the output "anodes[7:0]" of the system.v
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { anodes[0] }]; 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { anodes[1] }]; 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { anodes[2] }]; 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { anodes[3] }]; 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { anodes[4] }]; 
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { anodes[5] }]; 
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { anodes[6] }]; 
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { anodes[7] }]; 


# DDR2 constraints

#set_property -dict { PACKAGE_PIN R7   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [0] }]; 
#set_property -dict { PACKAGE_PIN V6   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [1] }]; 
#set_property -dict { PACKAGE_PIN R8   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [2] }];
#set_property -dict { PACKAGE_PIN U7   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [3] }]; 
#set_property -dict { PACKAGE_PIN V7   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [4] }];
#set_property -dict { PACKAGE_PIN R6   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [5] }];
#set_property -dict { PACKAGE_PIN U6   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [6] }];
#set_property -dict { PACKAGE_PIN R5   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [7] }];
#set_property -dict { PACKAGE_PIN T5   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [8] }];
#set_property -dict { PACKAGE_PIN U3   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [9] }];
#set_property -dict { PACKAGE_PIN V5   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [10] }];
#set_property -dict { PACKAGE_PIN U4   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [11] }];
#set_property -dict { PACKAGE_PIN V4   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [12] }];
#set_property -dict { PACKAGE_PIN T4   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [13] }];
#set_property -dict { PACKAGE_PIN V1   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [14] }];
#set_property -dict { PACKAGE_PIN T3   IOSTANDARD SSTL18_II } [get_ports { ddr2_dq [15] }];
#set_property -dict { PACKAGE_PIN T6   IOSTANDARD SSTL18_II } [get_ports { ddr2_dm[0] }];
#set_property -dict { PACKAGE_PIN U1   IOSTANDARD SSTL18_II } [get_ports { ddr2_dm[1] }];
#
#set_property -dict { PACKAGE_PIN U9   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_dqs_p[0] }];
#set_property -dict { PACKAGE_PIN V9   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_dqs_n[0] }];
#set_property -dict { PACKAGE_PIN U2   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_dqs_p[1] }];
#set_property -dict { PACKAGE_PIN V2   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_dqs_n[1] }];
#
#set_property -dict { PACKAGE_PIN N6   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [12] }];
#set_property -dict { PACKAGE_PIN K5   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [11] }];
#set_property -dict { PACKAGE_PIN R2   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [10] }];
#set_property -dict { PACKAGE_PIN N5   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [9] }];
#set_property -dict { PACKAGE_PIN L4   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [8] }];
#set_property -dict { PACKAGE_PIN N1   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [7] }];
#set_property -dict { PACKAGE_PIN M2   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [6] }];
#set_property -dict { PACKAGE_PIN P5   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [5] }];
#set_property -dict { PACKAGE_PIN L3   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [4] }];
#set_property -dict { PACKAGE_PIN T1   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [3] }];
#set_property -dict { PACKAGE_PIN M6   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [2] }];
#set_property -dict { PACKAGE_PIN P4   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [1] }];
#set_property -dict { PACKAGE_PIN M4   IOSTANDARD SSTL18_II } [get_ports { ddr2_addr [0] }];
#set_property -dict { PACKAGE_PIN R1   IOSTANDARD SSTL18_II } [get_ports { ddr2_ba [2] }];
#set_property -dict { PACKAGE_PIN P3   IOSTANDARD SSTL18_II } [get_ports { ddr2_ba [1] }];
#set_property -dict { PACKAGE_PIN P2   IOSTANDARD SSTL18_II } [get_ports { ddr2_ba [0] }];
#
##OJO estas constraints
#set_property -dict { PACKAGE_PIN L6   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_ck_p }];
#set_property -dict { PACKAGE_PIN L5   IOSTANDARD DIFF_SSTL18_II } [get_ports { ddr2_ck_n }];
#
#set_property -dict { PACKAGE_PIN N4   IOSTANDARD SSTL18_II } [get_ports { ddr2_ras_n }];
#set_property -dict { PACKAGE_PIN L1   IOSTANDARD SSTL18_II } [get_ports { ddr2_cas_n }];
#set_property -dict { PACKAGE_PIN N2   IOSTANDARD SSTL18_II } [get_ports { ddr2_we_n }];
#set_property -dict { PACKAGE_PIN M1   IOSTANDARD SSTL18_II } [get_ports { ddr2_cke }];
#set_property -dict { PACKAGE_PIN M3   IOSTANDARD SSTL18_II } [get_ports { ddr2_odt }];
#set_property -dict { PACKAGE_PIN K6   IOSTANDARD SSTL18_II } [get_ports { ddr2_cs_n }];