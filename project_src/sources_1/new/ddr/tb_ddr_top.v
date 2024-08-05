//*****************************************************************************

// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.

//

// This file contains confidential and proprietary information

// of Xilinx, Inc. and is protected under U.S. and

// international copyright and other intellectual property

// laws.

//

// DISCLAIMER

// This disclaimer is not a license and does not grant any

// rights to the materials distributed herewith. Except as

// otherwise provided in a valid license issued to you by

// Xilinx, and to the maximum extent permitted by applicable

// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND

// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES

// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING

// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-

// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and

// (2) Xilinx shall not be liable (whether in contract or tort,

// including negligence, or under any other theory of

// liability) for any loss or damage of any kind or nature

// related to, arising under or in connection with these

// materials, including for any direct, or any indirect,

// special, incidental, or consequential loss or damage

// (including loss of data, profits, goodwill, or any type of

// loss or damage suffered as a result of any action brought

// by a third party) even if such damage or loss was

// reasonably foreseeable or Xilinx had been advised of the

// possibility of the same.

//

// CRITICAL APPLICATIONS

// Xilinx products are not designed or intended to be fail-

// safe, or for use in any application requiring fail-safe

// performance, such as life-support or safety devices or

// systems, Class III medical devices, nuclear facilities,

// applications related to the deployment of airbags, or any

// other applications that could lead to death, personal

// injury, or severe property or environmental damage

// (individually and collectively, "Critical

// Applications"). Customer assumes the sole risk and

// liability of any use of Xilinx products in Critical

// Applications, subject only to applicable laws and

// regulations governing limitations on product liability.

//

// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS

// PART OF THIS FILE AT ALL TIMES.

//

//*****************************************************************************

//   ____  ____

//  /   /\/   /

// /___/  \  /    Vendor             : Xilinx

// \   \   \/     Version            : 4.2

//  \   \         Application        : MIG

//  /   /         Filename           : sim_tb_top.v

// /___/   /\     Date Last Modified : $Date: 2011/06/07 13:45:16 $

// \   \  /  \    Date Created       : Tue Sept 21 2010

//  \___\/\___\

//

// Device           : 7 Series

// Design Name      : DDR3 SDRAM

// Purpose          :

//                   Top-level testbench for testing DDR3.

//                   Instantiates:

//                     1. IP_TOP (top-level representing FPGA, contains core,

//                        clocking, built-in testbench/memory checker and other

//                        support structures)

//                     2. DDR3 Memory

//                     3. Miscellaneous clock generation and reset logic

//                     4. For ECC ON case inserts error on LSB bit

//                        of data from DRAM to FPGA.

// Reference        :

// Revision History :

//*****************************************************************************



`timescale 1ps/100fs
`define DEBUG_FBC


module tb_ddr_top;





   //***************************************************************************

   // Traffic Gen related parameters

   //***************************************************************************

   parameter SIMULATION            = "TRUE";

   parameter PORT_MODE             = "BI_MODE";

   parameter DATA_MODE             = 4'b0010;

   parameter TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE";

   parameter EYE_TEST              = "FALSE";

                                     // set EYE_TEST = "TRUE" to probe memory

                                     // signals. Traffic Generator will only

                                     // write to one single location and no

                                     // read transactions will be generated.

   parameter DATA_PATTERN          = "DGEN_ALL";

                                      // For small devices, choose one only.

                                      // For large device, choose "DGEN_ALL"

                                      // "DGEN_HAMMER", "DGEN_WALKING1",

                                      // "DGEN_WALKING0","DGEN_ADDR","

                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"

   parameter CMD_PATTERN           = "CGEN_ALL";

                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",

                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"

   parameter BEGIN_ADDRESS         = 32'h00000000;

   parameter END_ADDRESS           = 32'h00000fff;

   parameter PRBS_EADDR_MASK_POS   = 32'hff000000;



   //***************************************************************************

   // The following parameters refer to width of various ports

   //***************************************************************************

   parameter COL_WIDTH             = 10;

                                     // # of memory Column Address bits.

   parameter CS_WIDTH              = 1;

                                     // # of unique CS outputs to memory.

   parameter DM_WIDTH              = 8;

                                     // # of DM (data mask)

   parameter DQ_WIDTH              = 64;

                                     // # of DQ (data)

   parameter DQS_WIDTH             = 8;

   parameter DQS_CNT_WIDTH         = 3;

                                     // = ceil(log2(DQS_WIDTH))

   parameter DRAM_WIDTH            = 8;

                                     // # of DQ per DQS

   parameter ECC                   = "OFF";

   parameter RANKS                 = 1;

                                     // # of Ranks.

   parameter ODT_WIDTH             = 1;

                                     // # of ODT outputs to memory.

   parameter ROW_WIDTH             = 16;

                                     // # of memory Row Address bits.

   parameter ADDR_WIDTH            = 30;

                                     // # = RANK_WIDTH + BANK_WIDTH

                                     //     + ROW_WIDTH + COL_WIDTH;

                                     // Chip Select is always tied to low for

                                     // single rank devices

   //***************************************************************************

   // The following parameters are mode register settings

   //***************************************************************************

   parameter BURST_MODE            = "8";

                                     // DDR3 SDRAM:

                                     // Burst Length (Mode Register 0).

                                     // # = "8", "4", "OTF".

                                     // DDR2 SDRAM:

                                     // Burst Length (Mode Register).

                                     // # = "8", "4".

   parameter CA_MIRROR             = "OFF";

                                     // C/A mirror opt for DDR3 dual rank

   

   //***************************************************************************

   // The following parameters are multiplier and divisor factors for PLLE2.

   // Based on the selected design frequency these parameters vary.

   //***************************************************************************

   parameter CLKIN_PERIOD          = 4000;

                                     // Input Clock Period





   //***************************************************************************

   // Simulation parameters

   //***************************************************************************

   parameter SIM_BYPASS_INIT_CAL   = "FAST";

                                     // # = "SIM_INIT_CAL_FULL" -  Complete

                                     //              memory init &

                                     //              calibration sequence

                                     // # = "SKIP" - Not supported

                                     // # = "FAST" - Complete memory init & use

                                     //              abbreviated calib sequence



   //***************************************************************************

   // IODELAY and PHY related parameters

   //***************************************************************************

   parameter TCQ                   = 100;

   //***************************************************************************

   // IODELAY and PHY related parameters

   //***************************************************************************

   parameter RST_ACT_LOW           = 1;

                                     // =1 for active low reset,

                                     // =0 for active high.



   //***************************************************************************

   // Referece clock frequency parameters

   //***************************************************************************

   parameter REFCLK_FREQ           = 200.0;

                                     // IODELAYCTRL reference clock frequency

   //***************************************************************************

   // System clock frequency parameters

   //***************************************************************************

   parameter tCK                   = 2000;

                                     // memory tCK paramter.

                     // # = Clock Period in pS.

   parameter nCK_PER_CLK           = 4;

                                     // # of memory CKs per fabric CLK



   



   //***************************************************************************

   // Debug and Internal parameters

   //***************************************************************************

   parameter DEBUG_PORT            = "OFF";

                                     // # = "ON" Enable debug signals/controls.

                                     //   = "OFF" Disable debug signals/controls.

   //***************************************************************************

   // Debug and Internal parameters

   //***************************************************************************

   parameter DRAM_TYPE             = "DDR3";



    



  //**************************************************************************//

  // Local parameters Declarations

  //**************************************************************************//



  localparam real TPROP_DQS          = 0.00;

                                       // Delay for DQS signal during Write Operation

  localparam real TPROP_DQS_RD       = 0.00;

                       // Delay for DQS signal during Read Operation

  localparam real TPROP_PCB_CTRL     = 0.00;

                       // Delay for Address and Ctrl signals

  localparam real TPROP_PCB_DATA     = 0.00;

                       // Delay for data signal during Write operation

  localparam real TPROP_PCB_DATA_RD  = 0.00;

                       // Delay for data signal during Read operation



  localparam MEMORY_WIDTH            = 16;

  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;

  localparam ECC_TEST 		   	= "OFF" ;

  localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;

  



  localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));

  localparam RESET_PERIOD = 200000; //in pSec  

  localparam real SYSCLK_PERIOD = tCK;

    

    



  //**************************************************************************//

  // Wire Declarations

  //**************************************************************************//

  reg                                sys_rst_n;

  wire                               sys_rst;





  reg                     sys_clk_i;
  reg                     clk_100m;
  reg                     rst_100m;


  reg clk_ref_i;



  

  wire                               ddr3_reset_n;

  wire [DQ_WIDTH-1:0]                ddr3_dq_fpga;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_fpga;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_fpga;

  wire [ROW_WIDTH-1:0]               ddr3_addr_fpga;

  wire [3-1:0]              ddr3_ba_fpga;

  wire                               ddr3_ras_n_fpga;

  wire                               ddr3_cas_n_fpga;

  wire                               ddr3_we_n_fpga;

  wire [1-1:0]               ddr3_cke_fpga;

  wire [1-1:0]                ddr3_ck_p_fpga;

  wire [1-1:0]                ddr3_ck_n_fpga;

    

  

  wire                               init_calib_complete;

  wire                               tg_compare_error;

  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_fpga;

    

  wire [DM_WIDTH-1:0]                ddr3_dm_fpga;

    

  wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;

    

  

  reg [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram_tmp;

    

  reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;

    

  reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;

    



  

  wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;

  reg [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];

  reg [3-1:0]               ddr3_ba_sdram [0:1];

  reg                                ddr3_ras_n_sdram;

  reg                                ddr3_cas_n_sdram;

  reg                                ddr3_we_n_sdram;

  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram;

  wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;

  reg [1-1:0]                ddr3_cke_sdram;

  wire [DM_WIDTH-1:0]                ddr3_dm_sdram;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;

  reg [1-1:0]                 ddr3_ck_p_sdram;

  reg [1-1:0]                 ddr3_ck_n_sdram;

  

    



//**************************************************************************//



  //**************************************************************************//

  // Reset Generation

  //**************************************************************************//

  initial begin

    sys_rst_n = 1'b0;

    #RESET_PERIOD

      sys_rst_n = 1'b1;

   end



   assign sys_rst = RST_ACT_LOW ? sys_rst_n : ~sys_rst_n;



  //**************************************************************************//

  // Clock Generation

  //**************************************************************************//



  initial

    sys_clk_i = 1'b0;

  always

    sys_clk_i = #(4000/2.0) ~sys_clk_i;


    initial

    clk_100m = 1'b0;

  always

    clk_100m = #(10000/2.0) ~clk_100m;

    initial
    begin
        #(10000*2) rst_100m  =  1;
        #(10000*2) rst_100m  =  0;
    end
reg user_clk = 'd0;
    
    initial

    user_clk = 1'b0;

  always

  user_clk = #(6622/2.0) ~user_clk;
    
  initial

    clk_ref_i = 1'b0;

  always

    clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;









  always @( * ) begin

    ddr3_ck_p_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;

    ddr3_ck_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;

    ddr3_addr_sdram[0]   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;

    ddr3_addr_sdram[1]   <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?

                                                 {ddr3_addr_fpga[ROW_WIDTH-1:9],

                                                  ddr3_addr_fpga[7], ddr3_addr_fpga[8],

                                                  ddr3_addr_fpga[5], ddr3_addr_fpga[6],

                                                  ddr3_addr_fpga[3], ddr3_addr_fpga[4],

                                                  ddr3_addr_fpga[2:0]} :

                                                 ddr3_addr_fpga;

    ddr3_ba_sdram[0]     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;

    ddr3_ba_sdram[1]     <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?

                                                 {ddr3_ba_fpga[3-1:2],

                                                  ddr3_ba_fpga[0],

                                                  ddr3_ba_fpga[1]} :

                                                 ddr3_ba_fpga;

    ddr3_ras_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;

    ddr3_cas_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;

    ddr3_we_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;

    ddr3_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;

  end

    



  always @( * )

    ddr3_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;

  assign ddr3_cs_n_sdram =  ddr3_cs_n_sdram_tmp;

    



  always @( * )

    ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation

  assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;

    



  always @( * )

    ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;

  assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;

    



// Controlling the bi-directional BUS



  genvar dqwd;

  generate

    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay

      WireDelay #

       (

        .Delay_g    (TPROP_PCB_DATA),

        .Delay_rd   (TPROP_PCB_DATA_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dq

       (

        .A             (ddr3_dq_fpga[dqwd]),

        .B             (ddr3_dq_sdram[dqwd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete)

       );

    end

          WireDelay #

       (

        .Delay_g    (TPROP_PCB_DATA),

        .Delay_rd   (TPROP_PCB_DATA_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dq_0

       (

        .A             (ddr3_dq_fpga[0]),

        .B             (ddr3_dq_sdram[0]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete)

       );

  endgenerate



  genvar dqswd;

  generate

    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay

      WireDelay #

       (

        .Delay_g    (TPROP_DQS),

        .Delay_rd   (TPROP_DQS_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dqs_p

       (

        .A             (ddr3_dqs_p_fpga[dqswd]),

        .B             (ddr3_dqs_p_sdram[dqswd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete)

       );



      WireDelay #

       (

        .Delay_g    (TPROP_DQS),

        .Delay_rd   (TPROP_DQS_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dqs_n

       (

        .A             (ddr3_dqs_n_fpga[dqswd]),

        .B             (ddr3_dqs_n_sdram[dqswd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete)

       );

    end

  endgenerate

    



    



  //===========================================================================

  //                         FPGA Memory Controller

  //===========================================================================

//TX Interface
  wire    [63:0]          tx_tdata                ; 
  wire                    tx_tvalid               ;
  wire    [7:0]           tx_tkeep                ;  
  wire                    tx_tlast                ;
  wire                    tx_tready               ;
  
  wire                    aurora_fbc_en           ;
  wire    [64-1:0]        aurora_fbc_data         ;
  wire                    aurora_fbc_full         ;
  wire                    aurora_fbc_empty        ;
  wire                    aurora_fbc_almost_full  ;
  wire                    aurora_fbc_prog_empty   ;
  wire fbc_fifo_wrst;

// FBC to IMC
  wire                ddr3_init_done                  ;
  wire                pmt_scan_en                     ;
  wire                fbc_scan_start                  ;
  wire                fbc_cache_full                  ;
  wire                fbc_cache_vld                   ;
  wire    [256-1:0]   fbc_cache_data                  ;
  wire                fbc_vout_empty                  ;
  wire                fbc_vout_rd_seq                 ;
  wire    [64-1:0]    fbc_vout_rd_data                ;
  wire                fbc_vout_end                    ;
  wire                aurora_fbc_vout_vld             ;
  wire    [64-1:0]    aurora_fbc_vout_data            ;

  wire                fbc_up_start                    ;
  wire    [3-1:0]     fbc_up_en                       ;
  wire                fbc_scan_en                     ;
  wire    [3-1:0]     aurora_fbc_end                  ;
  
  reg     [2:0]       pmt_start_en            = 'd0;
  reg     [2:0]       pcie_pmt_end_en         = 'd0;
  reg                 main_scan_start         = 'd0;


  `ifdef SIMULATE
  reg    [23-1:0]    fbc_time_unit            = 'd0;
  reg                fbc_time_tick            = 'd0;
  reg    [23-1:0]    fbc_out_cnt              = 'd0;
  
  wire               FBCi_out_en_sim          = fbc_time_tick ;
  wire   [23:0]      FBCi_out_a_sim           = fbc_out_cnt + 1   ;
  wire   [23:0]      FBCi_out_b_sim           = fbc_out_cnt + 1   ;
  wire               FBCr1_out_en_sim         = fbc_time_tick ;
  wire   [23:0]      FBCr1_out_a_sim          = fbc_out_cnt + 2   ;
  wire   [23:0]      FBCr1_out_b_sim          = fbc_out_cnt + 2   ;
  wire               FBCr2_out_en_sim         = fbc_time_tick ;
  wire   [23:0]      FBCr2_out_a_sim          = fbc_out_cnt + 3   ;
  wire   [23:0]      FBCr2_out_b_sim          = fbc_out_cnt + 3   ;
  
  wire   [31:0]      precise_encode_w_sim     = {8'h00,fbc_out_cnt};
  wire   [31:0]      precise_encode_x_sim     = {8'h00,fbc_out_cnt};
  
  always @(posedge clk_100m) begin
      if(rst_100m)begin
          fbc_time_tick <= 'd0;
          fbc_time_unit <= 'd0;
      end
      else if(fbc_time_unit>='d10 - 1)begin
          fbc_time_tick <= 'd1;
          fbc_time_unit <= 'd0;
      end
      else begin
          fbc_time_tick <= 'd0;
          fbc_time_unit <= fbc_time_unit + 1; 
      end
  end
  
  always @(posedge clk_100m) begin
      if(pmt_scan_en)begin
          if(fbc_time_tick)
              fbc_out_cnt <= fbc_out_cnt + 4;
      end
      else 
          fbc_out_cnt <= 'd0;
  end
  
  `endif // DEBUG_FBC


  FBC_cache FBC_cache_inst(
    // clk & rst
    .clk_i                          ( clk_100m                              ),
    .rst_i                          ( rst_100m                              ),
`ifdef DEBUG_FBC
    // FBC actual voltage
    .FBCi_out_en_i                  ( FBCi_out_en_sim                       ),
    .FBCi_out_a_i                   ( FBCi_out_a_sim                        ),
    .FBCi_out_b_i                   ( FBCi_out_b_sim                        ),
    .FBCr1_out_en_i                 ( FBCr1_out_en_sim                      ),
    .FBCr1_out_a_i                  ( FBCr1_out_a_sim                       ),
    .FBCr1_out_b_i                  ( FBCr1_out_b_sim                       ),
    .FBCr2_out_en_i                 ( FBCr2_out_en_sim                      ),
    .FBCr2_out_a_i                  ( FBCr2_out_a_sim                       ),
    .FBCr2_out_b_i                  ( FBCr2_out_b_sim                       ),

    // Enocde
    .encode_w_i                     ( precise_encode_w_sim                  ),
    .encode_x_i                     ( precise_encode_x_sim                  ),

`else
    // FBC actual voltage
    .FBCi_out_en_i                  ( FBCi_out_en                           ),
    .FBCi_out_a_i                   ( FBCi_out_a                            ),
    .FBCi_out_b_i                   ( FBCi_out_b                            ),
    .FBCr1_out_en_i                 ( FBCr1_out_en                          ),
    .FBCr1_out_a_i                  ( FBCr1_out_a                           ),
    .FBCr1_out_b_i                  ( FBCr1_out_b                           ),
    .FBCr2_out_en_i                 ( FBCr2_out_en                          ),
    .FBCr2_out_a_i                  ( FBCr2_out_a                           ),
    .FBCr2_out_b_i                  ( FBCr2_out_b                           ),

    // Enocde
    .encode_w_i                     ( real_precise_encode_w                 ),
    .encode_x_i                     ( {4'd0,real_precise_encode_x[31:4]}    ),
`endif // DEBUG_FBC

    .pmt_scan_en_i                  ( pmt_scan_en                           ),
    .real_scan_flag_i               ( main_scan_start                       ),
    .fbc_scan_en_o                  ( fbc_scan_en                           ),
    .fbc_up_en_i                    ( fbc_up_en                             ),

    // ddr write
    .fbc_cache_vld_o                ( fbc_cache_vld                         ),
    .fbc_cache_data_o               ( fbc_cache_data                        ),

    .fbc_vout_empty_i               ( fbc_vout_empty                        ),
    .fbc_vout_rd_seq_o              ( fbc_vout_rd_seq                       ),
    .fbc_vout_rd_vld_i              ( fbc_vout_rd_vld                       ),
    .fbc_vout_rd_data_i             ( fbc_vout_rd_data                      ),
    
    .aurora_fbc_vout_vld_o          ( aurora_fbc_vout_vld                   ),
    .aurora_fbc_vout_data_o         ( aurora_fbc_vout_data                  ),
    .aurora_fbc_almost_full_1_i     ( aurora_fbc_almost_full                ),
    .aurora_fbc_almost_full_2_i     ( 0              ),
    .aurora_fbc_almost_full_3_i     ( 0              )
);

widen_enable #(
    .WIDEN_TYPE                 ( 1                             ),  // 1 = posedge lock
    .WIDEN_NUM                  ( 15                            )
)fbc_fifo_rst_inst(
    .clk_i                      ( clk_100m                      ),
    .rst_i                      ( 0                             ),

    .src_signal_i               ( pmt_start_en[0]               ),
    .dest_signal_o              ( fbc_fifo_wrst                 ) 
);

cache_rd_fifo fbc_to_aurora_fifo_inst(
    .rst                        ( fbc_fifo_wrst                 ),
    .wr_clk                     ( clk_100m                      ),
    .rd_clk                     ( user_clk                      ),
    .din                        ( aurora_fbc_vout_data          ),
    .wr_en                      ( aurora_fbc_vout_vld && fbc_up_en[0]),
    .rd_en                      ( aurora_fbc_en                 ),
    .dout                       ( aurora_fbc_data               ),
    .full                       ( aurora_fbc_full               ),
    .empty                      ( aurora_fbc_empty              ),
    // .almost_empty               ( aurora_fbc_almost_empty       ),  // flag indicating 1 word from empty
    .almost_full                ( aurora_fbc_almost_full        ),
    .prog_empty                 ( aurora_fbc_prog_empty         ),
    .wr_rst_busy                ( aurora_fbc_wr_rst_busy        ),  // output wire wr_rst_busy
    .rd_rst_busy                ( aurora_fbc_rd_rst_busy        )   // output wire rd_rst_busy
);

aurora_64b66b_tx aurora_64b66b_tx_inst(
    // FBC 
    .fbc_up_start_i             ( fbc_up_start && fbc_up_en[0]  ),
    .aurora_fbc_end_o           ( aurora_fbc_end[0]             ),
    .aurora_fbc_en_o            ( aurora_fbc_en                 ),
    .aurora_fbc_data_i          ( aurora_fbc_data               ),
    .aurora_fbc_prog_empty_i    ( aurora_fbc_prog_empty         ),
    .aurora_fbc_empty_i         ( aurora_fbc_empty              ),
    
    // System Interface
    .USER_CLK                   ( user_clk                      ),
    .RESET                      ( 0                             ),
    .CHANNEL_UP                 ( 'd1                           ),
    
    .tx_tvalid_o                ( tx_tvalid                     ),
    .tx_tdata_o                 ( tx_tdata                      ),
    .tx_tkeep_o                 ( tx_tkeep                      ),
    .tx_tlast_o                 ( tx_tlast                      ),
    .tx_tready_i                ( init_calib_complete           )
);

scan_flag_generate scan_flag_generate_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .pmt_start_en_i                 ( pmt_start_en                  ),
    .pmt_end_en_i                   ( pcie_pmt_end_en               ),
    .pmt_scan_en_o                  ( pmt_scan_en                   ),

    .fbc_up_start_i                 ( fbc_up_start                  ),
    .fbc_up_end_i                   ( {3{aurora_fbc_end[0]}}        ),
    .fbc_up_en_o                    ( fbc_up_en                     )
);

ddr_top u_ip_top(

     .ddr3_dq              (ddr3_dq_fpga),
     .ddr3_dqs_n           (ddr3_dqs_n_fpga),
     .ddr3_dqs_p           (ddr3_dqs_p_fpga),



     .ddr3_addr            (ddr3_addr_fpga),
     .ddr3_ba              (ddr3_ba_fpga),
     .ddr3_ras_n           (ddr3_ras_n_fpga),
     .ddr3_cas_n           (ddr3_cas_n_fpga),
     .ddr3_we_n            (ddr3_we_n_fpga),
     .ddr3_reset_n         (ddr3_reset_n),
     .ddr3_ck_p            (ddr3_ck_p_fpga),
     .ddr3_ck_n            (ddr3_ck_n_fpga),
     .ddr3_cke             (ddr3_cke_fpga),
     .ddr3_cs_n            (ddr3_cs_n_fpga),
     .ddr3_dm              (ddr3_dm_fpga),
     .ddr3_odt             (ddr3_odt_fpga),

     .clk_250m_i            (sys_clk_i),
     .clk_200m_i            (clk_ref_i),
     .init_calib_complete_o (init_calib_complete),

     .clk_i                          ( clk_100m                          ),
     .rst_i                          ( rst_100m                          ),
     
    .fbc_scan_en_i                  ( fbc_scan_en                       ),
    .fbc_cache_vld_i                ( fbc_cache_vld                     ),
    .fbc_cache_data_i               ( fbc_cache_data                    ),

    .fbc_up_start_o                 ( fbc_up_start                      ),
    .fbc_vout_empty_o               ( fbc_vout_empty                    ),
    .fbc_vout_rd_seq_i              ( fbc_vout_rd_seq                   ),
    .fbc_vout_rd_vld_o              ( fbc_vout_rd_vld                   ),
    .fbc_vout_rd_data_o             ( fbc_vout_rd_data                  )

     );


  //**************************************************************************//

  // Memory Models instantiations

  //**************************************************************************//



  genvar r,i;

  generate

    for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk

      if(DQ_WIDTH/16) begin: mem

        for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem

          ddr3_model u_comp_ddr3

            (

             .rst_n   (ddr3_reset_n),

             .ck      (ddr3_ck_p_sdram),

             .ck_n    (ddr3_ck_n_sdram),

             .cke     (ddr3_cke_sdram[r]),

             .cs_n    (ddr3_cs_n_sdram[r]),

             .ras_n   (ddr3_ras_n_sdram),

             .cas_n   (ddr3_cas_n_sdram),

             .we_n    (ddr3_we_n_sdram),

             .dm_tdqs (ddr3_dm_sdram[(2*(i+1)-1):(2*i)]),

             .ba      (ddr3_ba_sdram[r]),

             .addr    (ddr3_addr_sdram[r]),

             .dq      (ddr3_dq_sdram[16*(i+1)-1:16*(i)]),

             .dqs     (ddr3_dqs_p_sdram[(2*(i+1)-1):(2*i)]),

             .dqs_n   (ddr3_dqs_n_sdram[(2*(i+1)-1):(2*i)]),

             .tdqs_n  (),

             .odt     (ddr3_odt_sdram[r])

             );

        end

      end

      if (DQ_WIDTH%16) begin: gen_mem_extrabits

        ddr3_model u_comp_ddr3

          (

           .rst_n   (ddr3_reset_n),

           .ck      (ddr3_ck_p_sdram),

           .ck_n    (ddr3_ck_n_sdram),

           .cke     (ddr3_cke_sdram[r]),

           .cs_n    (ddr3_cs_n_sdram[r]),

           .ras_n   (ddr3_ras_n_sdram),

           .cas_n   (ddr3_cas_n_sdram),

           .we_n    (ddr3_we_n_sdram),

           .dm_tdqs ({ddr3_dm_sdram[DM_WIDTH-1],ddr3_dm_sdram[DM_WIDTH-1]}),

           .ba      (ddr3_ba_sdram[r]),

           .addr    (ddr3_addr_sdram[r]),

           .dq      ({ddr3_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)],

                      ddr3_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)]}),

           .dqs     ({ddr3_dqs_p_sdram[DQS_WIDTH-1],

                      ddr3_dqs_p_sdram[DQS_WIDTH-1]}),

           .dqs_n   ({ddr3_dqs_n_sdram[DQS_WIDTH-1],

                      ddr3_dqs_n_sdram[DQS_WIDTH-1]}),

           .tdqs_n  (),

           .odt     (ddr3_odt_sdram[r])

           );

      end

    end

  endgenerate

    

    





  //***************************************************************************

  // Reporting the test case status

  // Status reporting logic exists both in simulation test bench (sim_tb_top)

  // and sim.do file for ModelSim. Any update in simulation run time or time out

  // in this file need to be updated in sim.do file as well.

  //***************************************************************************

  initial

  begin : Logging

        begin : calibration_done

           wait (init_calib_complete);

           $display("Calibration Done");
           #1000000;
           $display("FBC test begin");
            main_scan_start = 1;
            #100000;
            
            pmt_start_en    = 1;
            pcie_pmt_end_en = 'd0;
            #800000_00;

            main_scan_start = 0;
            pmt_start_en    = 0;
            #1000000;
            pcie_pmt_end_en = 1;
            #1000000;
            pcie_pmt_end_en = 0;
            #100000;
            $finish;

        end


  end

    

endmodule



