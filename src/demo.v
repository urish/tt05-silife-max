module silife_demo(
  input wire clk,
  input wire rst_n,
  input wire en,
  input wire pattern_select,
  output reg [4:0] row_select,
  output wire [7:0] cells,
  output reg wr_en,
  output reg step
);

`include "demo_patterns.v"

function [7:0] reverse8(input [7:0] value);
  integer i;
  for (i = 0; i < 8; i = i + 1) begin
    reverse8[7-i] = value[i];
  end
endfunction

wire [255:0] DEMO_PATTERN = pattern_select ? DEMO_PATTERN_1 : DEMO_PATTERN_0;
assign cells = reverse8(DEMO_PATTERN[{5'd31-row_select, 3'b000}+:8]);

reg init_done;
reg [31:0] counter;

always @(posedge clk) begin
    if (!rst_n) begin
        row_select <= 5'b0;
        init_done <= 1'b0;
        wr_en <= 1'b0;
    end else if (en) begin
        if (!init_done) begin
          if (wr_en) begin
            row_select <= row_select + 5'd1;
          end else 
          begin
            wr_en <= 1'b1;
          end
          if (row_select == 'd31) begin
            init_done <= 1'b1;
            wr_en <= 1'b0;
          end
        end
        if (counter == 'd3_999_999) begin
          step <= 1'b1;
          counter <= 'd0;
        end else begin
          counter <= counter + 1;
          step <= 1'b0;
        end
    end else begin
      wr_en <= 1'b0;
    end
end

endmodule