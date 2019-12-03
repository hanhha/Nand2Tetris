// Ha Minh Tran Hanh (c)

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_PIX #(parameter MAX_COL = 833, MAX_ROW = 454,
                                 AW = 19)
(
  input  logic          clk,
  input  logic          rstn,

  input  logic          hsync,
  input  logic          vsync,
  input  logic [9:0]    pf_pix_row,
  input  logic [9:0]    pf_pix_col,

  input  logic          text_mode_en,
  input  logic          bw_mode_en,

  output logic [AW-1:0] pf_addr,
  input  logic [7:0]    pf_dat,

  output logic [7:0]    pix_val
);

localparam BLACK_LVL  = 8'd50;
localparam WHITE_LVL  = 8'd255;

logic [7:0] mem_val;

// The char on screen was too small so that 4 square pixels are used for 1 pixel in font
// = 28 rows x 52 cols 
localparam TEXT_ROWS = 28;
localparam TEXT_COLS = 52;
localparam MAX_CHARS = TEXT_ROWS * TEXT_COLS;

logic  [5:0] text_col;
logic  [4:0] text_row;
logic [10:0] pf_textmem_loc;

logic [2:0] pf_chr_row, pf_chr_col;
logic text_pix_on, grph_pix_on;

SCREEN_CHAR_ROM CHAR_ROM (.clk(clk), .rstn(rstn),
                          .chr_code (pf_dat),
                          .row      (pf_chr_row),
                          .col      (pf_chr_col),
                          .pix_on   (text_pix_on)
                        );

assign pf_chr_row = pf_pix_row [3:1];
assign pf_chr_col = pf_pix_col [3:1];

assign text_row = pf_pix_row >> 4;
assign text_col = pf_pix_col >> 4;
//assign pf_textmem_loc = (((text_row << 3) + (text_row << 2) + text_row) << 2) + text_col; // actually it is equal to text_row * 52 + text_col
assign pf_textmem_loc = text_row * 52 + text_col;

// Graphic mode
logic [7:0] pf_pix_val;
assign grph_pix_on = 1'b0;

assign pf_addr = text_mode_en ? {{(AW-11){1'b0}}, pf_textmem_loc}
                              : bw_mode_en ? 0   // TODO
                                           : 0 ; // TODO
assign pix_val     = text_mode_en ? (text_pix_on ? WHITE_LVL : BLACK_LVL)
                                  : bw_mode_en ? (grph_pix_on ? WHITE_LVL : BLACK_LVL)
                                               : pf_pix_val; // TODO: use pf_dat;

// Test pixel mode
logic vsync_pulse, vsync_pre;
`FF_MODULE vsync_pulse_ff (.clk (clk), .rstn (rstn), .d (vsync), .q (vsync_pre));
assign vsync_pulse = ~vsync_pre & vsync;

logic [9:0] nxt_ball_t, nxt_ball_l, ball_t, ball_l;
logic nxt_ball_l_s, nxt_ball_t_s, ball_l_s, ball_t_s; // 0 = +1; 1 = -1
logic [7:0] nxt_pix_val;

always @(*) begin
  nxt_ball_t = ball_t;
  nxt_ball_l = ball_l;
  nxt_ball_l_s = ball_l_s;
  nxt_ball_t_s = ball_t_s;

  if (vsync_pulse) begin
    nxt_ball_t = ball_t_s ? ball_t - 1'b1 : ball_t + 1'b1;
    nxt_ball_l = ball_l_s ? ball_l - 1'b1 : ball_l + 1'b1;
    if (ball_l == 10'd1) begin
      nxt_ball_l_s = 1'b0;
      nxt_ball_l = ball_l + 1'b1;
    end
    if (ball_t == 10'd1) begin
      nxt_ball_t_s = 1'b0;
      nxt_ball_t = ball_t + 1'b1;
    end
    if (ball_t + 10'd128 == MAX_ROW[9:0]-1'b1) begin
      nxt_ball_t_s = 1'b1;
      nxt_ball_t = ball_t - 1'b1;
    end
    if (ball_l + 10'd128 == MAX_COL[9:0]-1'b1) begin
      nxt_ball_l_s = 1'b1;
      nxt_ball_l = ball_l - 1'b1;
    end
  end
end

`FF_MODULE           ball_t_s_ff (.clk(clk), .rstn(rstn), .d(nxt_ball_t_s), .q(ball_t_s));
`FF_MODULE           ball_l_s_ff (.clk(clk), .rstn(rstn), .d(nxt_ball_l_s), .q(ball_l_s));
`FF_MODULE #(.W(10))  ball_t_ff   (.clk(clk), .rstn(rstn), .d(nxt_ball_t), .q(ball_t));
`FF_MODULE #(.W(10))  ball_l_ff   (.clk(clk), .rstn(rstn), .d(nxt_ball_l), .q(ball_l));

logic border;
assign border = pf_pix_row == 10'd0 || pf_pix_row == MAX_ROW-1 || pf_pix_col == 0 || pf_pix_col == MAX_COL - 1;

assign nxt_pix_val = border ? WHITE_LVL //: BLACK_LVL;
                        : (pf_pix_row >= ball_t & pf_pix_row < ball_t + 10'd128) & (pf_pix_col >= ball_l & pf_pix_col < ball_l + 10'd128) ? 8'd128 : BLACK_LVL;

`FF_MODULE #(.W(8)) pix_val_ff (.clk(clk), .rstn(rstn), .d(nxt_pix_val), .q(pf_pix_val));

libSink sink_hsync (.i(hsync));

endmodule
`undef FF_MODULE
//EOF
