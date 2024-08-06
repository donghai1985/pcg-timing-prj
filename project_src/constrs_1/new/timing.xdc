#create_clock -period 10.000 -name SRIO_MGT_REFCLK [get_ports SRIO_MGT_REFCLK_C_P]
#create_clock -period 10 -name FPGA_SSD1_PCIE_MGTREFCLK0 [get_ports FPGA_SSD1_PCIE_MGTREFCLK0_C_P]
create_clock -period 10.000 -name SFP_MGT_REFCLK0 [get_ports SFP_MGT_REFCLK0_C_P]
create_clock -period 10.000 -name SFP_MGT_REFCLK1 [get_ports SFP_MGT_REFCLK1_C_P]
create_clock -period 10.000 -name FPGA_MASTER_CLOCK [get_ports FPGA_MASTER_CLOCK_P]
create_clock -period 20.000 -name FPGA_TO_SFPGA_RESERVE0 [get_ports FPGA_TO_SFPGA_RESERVE0]

set_clock_groups -name async_clk_group -asynchronous -group [get_clocks FPGA_MASTER_CLOCK -include_generated_clocks] -group [get_clocks FPGA_TO_SFPGA_RESERVE0] -group [get_clocks SFP_MGT_REFCLK0 -include_generated_clocks] -group [get_clocks SFP_MGT_REFCLK1 -include_generated_clocks]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets FPGA_TO_SFPGA_RESERVE0]

# set_clock_groups -asynchronous -group [get_clocks clk_out4_pll] -group [get_clocks user_clk_i]
# set_clock_groups -asynchronous -group [get_clocks clk_out4_pll] -group [get_clocks user_clk_i_1]
# set_clock_groups -asynchronous -group [get_clocks clk_out4_pll] -group [get_clocks user_clk_i_2]
set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins aurora_64b66b_exdes_inst_1/aurora_64b66b_0_block_i/clock_module_i/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins aurora_64b66b_exdes_inst_2/aurora_64b66b_0_block_i/clock_module_i/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins aurora_64b66b_exdes_inst_3/aurora_64b66b_0_block_i/clock_module_i/mmcm_adv_inst/CLKOUT0]]

# set_false_path -from [get_pins scan_flag_generate_inst/pmt_scan_en_reg/C] -to [get_pins u_ddr_top/FBC_vin_ctrl_inst/mem_vin_buffer_ctrl_inst/laser_start_d0_reg/D]
set_false_path -from [get_pins FBC_cache_inst/pmt_scan_en_d_reg/C] -to [get_pins u_ddr_top/FBC_vin_ctrl_inst/mem_vin_buffer_ctrl_inst/laser_start_d0_reg/D]
set_false_path -from [get_pins FBC_cache_inst/real_scan_flag_latch_reg/C] -to [get_pins u_ddr_top/FBC_vin_ctrl_inst/mem_vin_buffer_ctrl_inst/laser_start_d0_reg/D]

set_false_path -from [get_pins aurora_64b66b_exdes_inst_2/aurora_64b66b_0_block_i/support_reset_logic_i/gt_rst_r_reg/C] -to [get_pins aurora_64b66b_exdes_inst_2/aurora_64b66b_0_block_i/support_reset_logic_i/u_rst_sync_gt/stg1_aurora_64b66b_1_cdc_to_reg/D]
set_false_path -from [get_pins aurora_64b66b_exdes_inst_1/aurora_64b66b_0_block_i/support_reset_logic_i/gt_rst_r_reg/C] -to [get_pins aurora_64b66b_exdes_inst_1/aurora_64b66b_0_block_i/support_reset_logic_i/u_rst_sync_gt/stg1_aurora_64b66b_0_cdc_to_reg/D]
set_false_path -from [get_pins aurora_64b66b_exdes_inst_3/aurora_64b66b_0_block_i/support_reset_logic_i/gt_rst_r_reg/C] -to [get_pins aurora_64b66b_exdes_inst_3/aurora_64b66b_0_block_i/support_reset_logic_i/u_rst_sync_gt/stg1_aurora_64b66b_0_cdc_to_reg/D]