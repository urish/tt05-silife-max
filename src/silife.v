`default_nettype none

`define GRID_WIDTH 8
`define GRID_HEIGHT 32

/* verilator lint_off PINCONNECTEMPTY */

module tt_um_urish_silife (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b00000000; 
  assign uio_out = 8'b00000000;

  wire en = ui_in[6];
  wire wr_en = ui_in[7];

  wire [`GRID_WIDTH-1:0] grid_n;
  wire [`GRID_HEIGHT-1:0] grid_e;
  wire [`GRID_WIDTH-1:0] grid_s;
  wire [`GRID_HEIGHT-1:0] grid_w;

  grid_8x32 grid(
    .clk(clk),
    .reset(!rst_n),
    .enable(en),
    .row_select(ui_in[4:0]),
    .clear_cells(wr_en ? ~uio_in : 8'b0),
    .set_cells(wr_en ? uio_in : 8'b0),
    .cells(uo_out),
    .i_n(grid_s),
    .i_e(grid_w),
    .i_s(grid_n),
    .i_w(grid_e),
    .i_ne(grid_s[0]),
    .i_se(grid_w[0]),
    .i_sw(grid_n[`GRID_WIDTH-1]),
    .i_nw(grid_e[`GRID_HEIGHT-1]),
    .o_n(grid_n),
    .o_e(grid_e),
    .o_s(grid_s),
    .o_w(grid_w),
    .row_select2(5'b0),
    .cells2()
  );

  wire _unused_ok = &{
    1'b0,
    ena,
    ui_in[5],
    1'b0
  };

`ifdef SILIFE_TEST
  /* Pretty output for the test bench */
  localparam string_bits = `GRID_WIDTH * 8;
  integer i;
  function [string_bits-1:0] row_to_string(input clk, input [`GRID_WIDTH-1:0] row);
    begin
      for (i = 0; i < `GRID_WIDTH; i = i + 1) begin
        row_to_string[i*8+:8] = clk ? (row[`GRID_WIDTH-1-i] ? "*" : " ") : 8'bz;
      end
    end
  endfunction

  wire [string_bits-1:0] row00 = row_to_string(clk, grid.cell_values['d00*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row01 = row_to_string(clk, grid.cell_values['d01*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row02 = row_to_string(clk, grid.cell_values['d02*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row03 = row_to_string(clk, grid.cell_values['d03*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row04 = row_to_string(clk, grid.cell_values['d04*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row05 = row_to_string(clk, grid.cell_values['d05*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row06 = row_to_string(clk, grid.cell_values['d06*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row07 = row_to_string(clk, grid.cell_values['d07*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row08 = row_to_string(clk, grid.cell_values['d08*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row09 = row_to_string(clk, grid.cell_values['d09*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row10 = row_to_string(clk, grid.cell_values['d10*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row11 = row_to_string(clk, grid.cell_values['d11*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row12 = row_to_string(clk, grid.cell_values['d12*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row13 = row_to_string(clk, grid.cell_values['d13*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row14 = row_to_string(clk, grid.cell_values['d14*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row15 = row_to_string(clk, grid.cell_values['d15*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row16 = row_to_string(clk, grid.cell_values['d16*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row17 = row_to_string(clk, grid.cell_values['d17*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row18 = row_to_string(clk, grid.cell_values['d18*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row19 = row_to_string(clk, grid.cell_values['d19*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row20 = row_to_string(clk, grid.cell_values['d20*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row21 = row_to_string(clk, grid.cell_values['d21*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row22 = row_to_string(clk, grid.cell_values['d22*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row23 = row_to_string(clk, grid.cell_values['d23*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row24 = row_to_string(clk, grid.cell_values['d24*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row25 = row_to_string(clk, grid.cell_values['d25*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row26 = row_to_string(clk, grid.cell_values['d26*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row27 = row_to_string(clk, grid.cell_values['d27*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row28 = row_to_string(clk, grid.cell_values['d28*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row29 = row_to_string(clk, grid.cell_values['d29*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row30 = row_to_string(clk, grid.cell_values['d30*`GRID_WIDTH+:`GRID_WIDTH]);
  wire [string_bits-1:0] row31 = row_to_string(clk, grid.cell_values['d31*`GRID_WIDTH+:`GRID_WIDTH]);

`endif

endmodule
