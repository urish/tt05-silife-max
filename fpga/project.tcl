add_file -type verilog ../src/grid_8x32.v
add_file -type verilog ../src/cell.v
add_file -type verilog ../src/spi_master.v
add_file -type verilog ../src/max7219.v
add_file -type verilog ../src/demo.v
add_file -type verilog ../src/silife.v
add_file -type verilog uart_rx.v
add_file -type verilog uart_tx.v
add_file -type verilog rpll.v
add_file -type verilog fpga_top.v
add_file -type cst project.cst
add_file -type sdc project.sdc
set_device GW2AR-LV18QN88C8/I7
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name project
set_option -verilog_std sysv2017
set_option -top_module fpga_top
run all
