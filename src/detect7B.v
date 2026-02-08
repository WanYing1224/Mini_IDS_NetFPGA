////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : detect7B.vf
// /___/   /\     Timestamp : 01/31/2026 02:26:45
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w C:/EE533/Lab3_Mini_IDS/Schematic/detect7B.sch detect7B.vf
//Design Name: detect7B
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module detect7B(ce, 
                clk, 
                hwregA, 
                match_en, 
                mrst, 
                pipe1, 
                match);

    input ce;
    input clk;
    input [63:0] hwregA;
    input match_en;
    input mrst;
    input [71:0] pipe1;
   output match;
   
   wire [71:0] pipe0;
   wire [111:0] XLXN_34;
   wire XLXN_39;
   wire XLXN_46;
   wire XLXN_51;
   wire match_DUMMY;
   
   assign match = match_DUMMY;
   busmerge XLXI_2 (.da(pipe0[47:0]), 
                    .db(pipe1[63:0]), 
                    .q(XLXN_34[111:0]));
   wordmatch XLXI_3 (.datacomp(hwregA[55:0]), 
                     .datain(XLXN_34[111:0]), 
                     .wildcard(hwregA[62:56]), 
                     .match(XLXN_39));
   AND3B1 XLXI_4 (.I0(match_DUMMY), 
                  .I1(match_en), 
                  .I2(XLXN_39), 
                  .O(XLXN_46));
   FDCE XLXI_5 (.C(clk), 
                .CE(XLXN_46), 
                .CLR(XLXN_51), 
                .D(XLXN_46), 
                .Q(match_DUMMY));
   defparam XLXI_5.INIT = 1'b0;
   FD XLXI_6 (.C(clk), 
              .D(mrst), 
              .Q(XLXN_51));
   defparam XLXI_6.INIT = 1'b0;
   reg9B XLXI_8 (.ce(ce), 
                 .clk(clk), 
                 .clr(XLXN_51), 
                 .d(pipe1[71:0]), 
                 .q(pipe0[71:0]));
endmodule
