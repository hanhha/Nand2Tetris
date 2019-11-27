// Ha Minh Tran Hanh (c)

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_MEMPIX #(parameter MAX_COL = 834, MAX_ROW = 456,
                                 AW = 19, DW = 16)
(
  input  logic          clk,
  input  logic          rstn,

  input  logic          hsync,
  input  logic          vsync,
  input  logic [9:0]    pf_pix_row,
  input  logic [9:0]    pf_pix_col,

  input  logic          text_mode_en,

  output logic          mem_addr_vld,
  input  logic          mem_addr_gnt,
  output logic [AW-1:0] mem_addr,

  input  logic          mem_dat_vld,
  output logic          mem_dat_gnt,
  input  logic [DW-1:0] mem_dat,

  output logic [7:0]    pix_val
);

logic vsync_pulse, vsync_pre;
`FF_MODULE vsync_pulse_ff (.clk (clk), .rstn (rstn), .d (vsync), .q (vsync_pre));
assign vsync_pulse = ~vsync_pre & vsync;

//TODO:
// Get pixel data from mem
localparam BLACK_LVL  = 8'd50;
localparam WHITE_LVL  = 8'd255;

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

`FF_MODULE #(.W(8)) pix_val_ff (.clk(clk), .rstn(rstn), .d(nxt_pix_val), .q(pix_val));

libSink sink_hsync (.i(hsync));

assign {mem_addr_vld, mem_addr, mem_dat_gnt} = {1'b0, {AW{1'b0}}, 1'b1};

libSink #(.W(DW)) sink_mem_dat       (.i(mem_dat));
libSink           sink_mem_vld       (.i(mem_dat_vld));
libSink           sink_mem_gnt       (.i(mem_addr_gnt));

endmodule
`undef FF_MODULE
//EOF
