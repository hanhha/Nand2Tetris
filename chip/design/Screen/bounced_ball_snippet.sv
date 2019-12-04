// Test pixel mode
logic vsync_pulse, vsync_pre;
`FF_MODULE vsync_pulse_ff (`CLKRST, .d (vsync), .q (vsync_pre));
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

`FF_MODULE           ball_t_s_ff (`CLKRST, .d(nxt_ball_t_s), .q(ball_t_s));
`FF_MODULE           ball_l_s_ff (`CLKRST, .d(nxt_ball_l_s), .q(ball_l_s));
`FF_MODULE #(.W(10))  ball_t_ff   (`CLKRST, .d(nxt_ball_t), .q(ball_t));
`FF_MODULE #(.W(10))  ball_l_ff   (`CLKRST, .d(nxt_ball_l), .q(ball_l));

logic border;
assign border = pf_pix_row == 10'd0 || pf_pix_row == MAX_ROW-1 || pf_pix_col == 0 || pf_pix_col == MAX_COL - 1;

assign nxt_pix_val = border ? WHITE_LVL //: BLACK_LVL;
                        : (pf_pix_row >= ball_t & pf_pix_row < ball_t + 10'd128) & (pf_pix_col >= ball_l & pf_pix_col < ball_l + 10'd128) ? 8'd128 : BLACK_LVL;

`FF_MODULE #(.W(8)) pix_val_ff (`CLKRST, .d(nxt_pix_val), .q(pf_pix_val));

libSink sink_hsync (.i(hsync));

