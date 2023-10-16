// SPDX-FileCopyrightText: © 2021 Uri Shaked <uri@wokwi.com>
// SPDX-License-Identifier: MIT

`default_nettype none
//
`timescale 1ns / 1ps

module silife_spi_master #(
    parameter HALF_BIT_CYCLES = 2
) (
    input wire reset,
    input wire clk,

    input wire [15:0] i_word,
    input wire i_start,

    output reg o_sck,
    output reg o_mosi,
    output reg o_busy
);

  reg [3:0] bit_index;
  reg [$clog2(HALF_BIT_CYCLES):0] clk_count;
  reg finish;

  always @(posedge clk) begin
    if (reset) begin
      bit_index <= 4'hf;
      o_mosi <= 0;
      clk_count <= 0;
      o_sck <= 0;
      o_busy <= 0;
    end else begin
      if (finish) begin
        finish <= 0;
        o_sck <= 0;
        o_busy <= 0;
        clk_count <= 0;
      end else if (o_busy) begin
        clk_count <= clk_count + 2'd1;
        if (clk_count == HALF_BIT_CYCLES - 1) begin
          o_sck <= !o_sck;
          clk_count <= 0;
          if (bit_index == 4'hf && o_sck) begin
            finish <= 1;
          end
        end
        if (!o_sck && clk_count == 0) begin
          o_mosi <= i_word[bit_index];
          bit_index <= bit_index - 4'd1;
        end
      end else if (i_start) begin
        o_busy <= 1;
        bit_index <= 4'hf;
      end
    end
  end

endmodule
