// SPDX-FileCopyrightText: © 2021-2023 Uri Shaked <uri@wokwi.com>
// SPDX-License-Identifier: MIT

`default_nettype none
//
`timescale 1ns / 1ps

/**
  Displays the game matrix on a MAX7219 LED matrix display.

  The display consists of four 8x8 LED matrix displays, daisy-chained together.
*/

module silife_max7219 (
    input wire reset,
    input wire clk,

    input wire i_enable,
    input wire [7:0] i_cells,
    input wire [3:0] i_brightness,
    input wire i_frame,

    // MAX7219 SPI interface
    output reg  o_cs,
    output wire o_sck,   // 100ns
    output wire o_mosi,
    output wire o_busy,

    output wire [4:0] o_row_select
);

  localparam StateInit = 3'd0;
  localparam StateStart = 3'd1;
  localparam StateData = 3'd2;
  localparam StateEnable = 3'd3;
  localparam StatePause = 3'd4;

  reg [2:0] state;
  assign o_busy = (state == StateStart || state == StateData || state == StateEnable) | spi_busy;

  reg [15:0] spi_word;
  reg spi_start;
  wire spi_busy;

  reg load_row;
  reg [7:0] row_data;
  reg [2:0] col_index;

  reg [1:0] init_index;
  reg [2:0] max7219_row;
  reg [1:0] matrix_index;

  reg max7219_enabled;

  assign o_row_select = {matrix_index, col_index};

  function [7:0] reverse8(input [7:0] value);
    integer i;
    for (i = 0; i < 8; i = i + 1) begin
      reverse8[7-i] = value[i];
    end
  endfunction

  // Debug output
  reg [63:0] dbg_state_name;

  always @(*) begin
    case (state)
      StateInit: dbg_state_name <= "Init";
      StateStart: dbg_state_name <= "Start";
      StateData: dbg_state_name <= "Data";
      StateEnable: dbg_state_name <= "Enable";
      StatePause: dbg_state_name <= "Pause";
      default: dbg_state_name <= "Invalid";
    endcase
  end

  silife_spi_master spim (
      .reset(reset),
      .clk(clk),
      .i_word(spi_word),
      .i_start(spi_start),
      .o_sck(o_sck),
      .o_mosi(o_mosi),
      .o_busy(spi_busy)
  );

  always @(*) begin
    case (state)
      StateInit: spi_word = 16'b0;
      StateStart: begin
        case (init_index)
          0: spi_word = {8'h0f, 8'h00};  // Disable test mode
          1: spi_word = {8'h0b, 8'h07};  // Set scanlines to 8
          2: spi_word = {8'h09, 8'h00};  // Disable decode mode
          3: spi_word = {8'h0a, 4'b0000, i_brightness};  // Configure max brightness
        endcase
      end
      StateData: spi_word = {4'b0, (max7219_row + 4'd1), reverse8(row_data)};
      StateEnable: spi_word = {8'h0c, 8'h01};  // Enable display
      default: spi_word = 16'b0;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= StateInit;
      init_index <= 'd0;
      matrix_index <= 'd0;
      load_row <= 'b0;
      col_index <= 'd0;
      row_data <= 'd0;
      max7219_row <= 'd0;
      max7219_enabled <= 'd0;
      o_cs <= 'd1;
      spi_start <= 'b0;
    end else begin
      if (load_row) begin
        row_data[col_index] <= i_cells[max7219_row];
        col_index <= col_index + 3'd1;
        if (col_index == 'd7) begin
          col_index <= 'd0;
          load_row <= 'b0;
        end
      end

      spi_start <= 'b0;
      if (!i_enable) begin
        state <= StateInit;
      end else if (!spi_start && !spi_busy) begin
        case (state)
          StateInit: begin
            init_index <= 'b0;
            matrix_index <= '0;
            col_index <= 'd0;
            load_row <= 'b0;
            max7219_enabled <= 'b0;
            max7219_row <= 'd0;
            o_cs <= 'b1;
            if (i_enable) begin
              o_cs <= 0;
              state <= StateStart;
              spi_start <= 1;
            end
          end
          StateStart: begin
            matrix_index <= matrix_index + 2'd1;
            spi_start <= 'b1;
            if (matrix_index == 'd3) begin
              matrix_index <= 'd3;
              if (!o_cs) begin
                o_cs <= 'b1;
                spi_start <= 'b0;
              end else begin
                o_cs <= 'b0;
                matrix_index <= 'd0;
                init_index <= init_index + 2'd1;
                if (init_index == 'd3) begin
                  state <= StateData;
                  load_row <= 'b1;
                end
              end
            end
          end
          StateData: begin
            spi_start <= 'b1;
            matrix_index <= matrix_index + 2'd1;
            load_row <= 'b1;
            if (matrix_index == 'd3) begin
              if (!o_cs) begin
                o_cs <= 'b1;
                matrix_index <= 'd3;
                spi_start <= 0;
                load_row <= 0;
                if (max7219_row == 'd7 && max7219_enabled) begin
                  if (!i_frame) state <= StatePause;
                end
              end else begin
                o_cs <= 'b0;
                max7219_row <= max7219_row + 3'd1;
                matrix_index <= 'd0;
                if (max7219_row == 'd7 && !max7219_enabled) begin
                  state <= StateEnable;
                end
              end
            end
          end
          StateEnable: begin
            if (matrix_index != 3) begin
              matrix_index <= matrix_index + 2'd1;
              spi_start <= 'b1;
            end else begin
              if (!o_cs) begin
                max7219_enabled <= 'b1;
                o_cs <= 'b1;
                if (max7219_row == 'd7 && max7219_enabled) begin
                  if (!i_frame) state <= StatePause;
                end
              end else begin
                o_cs <= 0;
                matrix_index <= 'd0;
                max7219_row <= 'd0;
                state <= StateData;
                spi_start <= 'b1;
                load_row <= 'b1;
              end
            end
          end
          default: begin
            /* We are paused */
            matrix_index <= 'd0;
            max7219_row <= 'd0;
            if (i_frame) begin
              o_cs <= 'b0;
              state <= StateData;
              spi_start <= 'b1;
              load_row <= 'b1;
            end
          end
        endcase
      end
    end
  end
endmodule
