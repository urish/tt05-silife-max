`default_nettype none

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

  grid_8x8 grid(
    .clk(clk),
    .reset(!rst_n),
    .enable(en),
    .row_select(ui_in[2:0]),
    .clear_cells(wr_en ? ~uio_in : 8'b0),
    .set_cells(wr_en ? uio_in : 8'b0),
    .cells(uo_out),
    .i_n(8'b0),
    .i_e(8'b0),
    .i_s(8'b0),
    .i_w(8'b0),
    .i_ne(1'b0),
    .i_se(1'b0),
    .i_sw(1'b0),
    .i_nw(1'b0),
    .o_n(),
    .o_w(),
    .o_s(),
    .o_e(),
    .row_select2(3'b0),
    .cells2()
  );

  wire _unused_ok = &{
    1'b0,
    ena,
    ui_in[5:3],
    1'b0
  };

endmodule
