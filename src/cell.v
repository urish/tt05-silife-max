// SPDX-FileCopyrightText: © 2021 Uri Shaked <uri@wokwi.com>
// SPDX-License-Identifier: MIT

module silife_cell (
    input  wire reset,
    input  wire clk,
    input  wire enable,
    input  wire revive,
    /* Neighbors */
    input  wire nw,
    input  wire n,
    input  wire ne,
    input  wire e,
    input  wire se,
    input  wire s,
    input  wire sw,
    input  wire w,
    output wire out
);

  reg state;
  assign out = state;

  wire [7:0] neighbors = {nw, n, ne, e, se, s, sw, w};
  reg [2:0] living_neighbors;

  always @(*) begin : count_neighbors
    integer j;
    living_neighbors = 3'd0;
    for (j = 0; j < 8; j++) living_neighbors += {2'b00, neighbors[j]};
  end

  always @(posedge clk) begin
    if (reset) state <= 0;
    else if (revive) state <= 1;
    else if (enable) state <= (state && living_neighbors == 2) || living_neighbors == 3;
  end

endmodule
