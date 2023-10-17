`default_nettype none

module fpga_top(
    input  wire  clk27,
    input  wire  rst,
    input  wire  sw_demo,
    input  wire  uart_rx,
    output wire  uart_tx,
    output wire  uart_tx_2,
    output reg   led,
    output reg   led2,
    output wire  max7129_cs,
    output wire  max7129_clk,
    output wire  max7129_data
);

parameter                        CLK_FREQ  = 10.125;     //Mhz
parameter                        UART_BAUD = 115200; //Khz

localparam CHAR_CR = 8'h0d;
localparam CHAR_NEWLINE = 8'h0a;

wire clk;

Gowin_rPLL rpll_inst(
    .clkin(clk27), 
    .clkout(clk)
);

wire rst_n = ~rst;

reg [23:0] counter = 'd0;
assign led = counter[23];
assign led2 = rst_n;

always @(posedge clk) begin
    counter <= counter + 24'd1;
end

reg [4:0] silife_row_select;
reg silife_rst_n = 'b0;
reg silife_wr_en;
reg step;
reg demo_en;
wire silife_en = step | demo_en; 

reg [7:0] silife_data_in;
wire [7:0] silife_data_out;

wire max7219_en = ~dump_grid;
assign max7129_cs = silife_data_out[0];
assign max7129_clk = silife_data_out[1];
assign max7129_data = silife_data_out[2];

tt_um_urish_silife_max silife(
    .ui_in({silife_wr_en, silife_en, max7219_en, silife_row_select}),
    .uo_out(silife_data_out),
    .uio_in(silife_data_in),
    .uio_out(),
    .uio_oe(),
    .ena(1'b1),
    .clk(clk),
    .rst_n(silife_rst_n)
);

wire [7:0] rx_byte;
wire rx_byte_valid;

reg  [7:0] tx_byte;
reg  tx_valid = 'b0;
wire tx_ready;

reg  dump_grid;
reg  [3:0]dump_grid_col;
reg  [3:0]write_grid_col;

uart_rx #(
    .CLK_FRE(CLK_FREQ),
    .BAUD_RATE(UART_BAUD)
) uart_rx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .rx_pin(uart_rx),
    .rx_data(rx_byte),
    .rx_data_valid(rx_byte_valid),
    .rx_data_ready(1'b1)
);

assign uart_tx_2 = uart_tx;

uart_tx #(
	.CLK_FRE(CLK_FREQ),
	.BAUD_RATE(UART_BAUD)
) uart_tx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .tx_pin(uart_tx),
    .tx_data(tx_byte),
    .tx_data_valid(tx_valid),
    .tx_data_ready(tx_ready)
);

always @(posedge clk) begin
    if (rst) begin
        tx_byte <= "X";
        silife_row_select <= 'b0;
        step <= 'b0;
        silife_wr_en <= sw_demo;
        tx_valid <= 'b0;
        dump_grid <= 'b0;
        silife_rst_n <= 'b0;
        demo_en <= sw_demo;
    end else begin
        step <= 'b0;
        silife_wr_en <= 'b0;

        if (!silife_rst_n) begin
            silife_rst_n <= 'b1;
            silife_wr_en <= silife_wr_en;
        end

        if (silife_wr_en && silife_rst_n) begin
            // Advance to next row after writing 8 columns
            silife_row_select <= silife_row_select + 5'd1;
        end

        if (!tx_ready) begin
            tx_valid <= 'b0;
        end
        
        // Transmit next byte
        if (tx_ready && !$past(tx_ready)) begin
            // Auto send "\n" after "\r"
            if (tx_byte == CHAR_CR) begin
                tx_byte <= CHAR_NEWLINE;
                tx_valid <= 'b1;
            end else if (dump_grid) begin
                if (dump_grid_col == 8) begin
                    dump_grid_col <= 'b0;
                    tx_byte <= CHAR_CR;
                    tx_valid <= 'b1;
                    if (silife_row_select == 31) begin
                        dump_grid <= 'b0;
                    end else begin
                        silife_row_select <= silife_row_select + 5'd1;
                    end
                end else begin
                    tx_byte <= silife_data_out[3'd7 - dump_grid_col[2:0]] ? "#" : ".";
                    tx_valid <= 'b1;
                    dump_grid_col <= dump_grid_col + 4'd1;
                end
            end
        end

        // handle RX
        if (rx_byte_valid) begin
            case (rx_byte)
                "s",
                "S": begin // steps the simulation
                    tx_byte <= "S";
                    step <= 'b1;
                    tx_valid <= 'b1;
                end

                "r",
                "R": begin // dumps the current state of the grid
                    tx_byte <= CHAR_CR;
                    tx_valid <= 'b1;
                    dump_grid <= 'b1;
                    dump_grid_col <= 'd0;
                    silife_row_select <= 'd0;
                    step <= rx_byte == "R"; // "R" also steps the simulation
                end

                "w",
                "W": begin // sets the current state of the grid
                    tx_byte <= "W";
                    tx_valid <= 'b1;
                    silife_row_select <= 'd0;
                    write_grid_col <= 'd0;
                end

                ".",
                "#": begin // writes a single grid cell
                    tx_byte <= rx_byte;
                    tx_valid <= 'b1;
                    silife_data_in[3'd7 - write_grid_col[2:0]] <= rx_byte == "#";
                    write_grid_col <= write_grid_col + 4'd1;
                    if (write_grid_col == 7) begin
                        write_grid_col <= 'd0;
                        silife_wr_en <= 'b1;
                    end
                end


                "d",
                "D": begin // reset in demo mode
                    silife_rst_n <= 'b0;
                    silife_wr_en <= 'b1;
                    tx_byte <= "D";
                    tx_valid <= 'b1;
                    demo_en <= 'b1;
                    silife_row_select <= rx_byte == "D" ? 'd1 : 'd0;
                end

                "p",
                "P": begin // pause/resume demo mode
                    tx_byte <= "P";
                    tx_valid <= 'b1;
                    demo_en <= ~demo_en;
                end

                "z",
                "Z": begin // reset the module
                    silife_rst_n <= 'b0;
                    tx_byte <= "Z";
                    tx_valid <= 'b1;
                    demo_en <= 'b0;
                end
                
                default: begin
                    tx_byte <= "X";
                    tx_valid <= 'b1;
                end
            endcase
        end
    end
end

endmodule