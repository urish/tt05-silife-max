`default_nettype none

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

  wire en = ui_in[3];
  wire wr_en = ui_in[4];

  grid_8x8 grid(
    .clk(clk),
    .reset(!rst_n),
    .enable(en),
    .row_select(ui_in[2:0]),
    .clear_cells(wr_en ? ~uio_in : 8'b0),
    .set_cells(wr_en ? uio_in : 8'b0),
    .cells(uo_out)
  );

endmodule
