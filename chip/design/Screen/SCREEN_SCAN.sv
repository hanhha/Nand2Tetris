// Ha Minh Tran Hanh (c)

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_SCAN #(parameter MAX_ROW = 525, MAX_COL = 420, UNIT = 5,
                               VOFFSET = 10'd44, HOFFSET = 10'd8)
(
  input  logic       clk,
  input  logic       rstn,
  input  logic       interlace_mode,
  input  logic [7:0] pix_val,

// To mempix
  output logic       hsync,
  output logic       vsync,
  output logic [9:0] pf_pix_row,
  output logic [9:0] pf_pix_col,

// To DAC
  output logic [7:0] dac_bin
);

// ==================================
// Set appropriate values after reset
// ==================================
localparam IDLE = 2'b00;
localparam SET  = 2'b01;
localparam WORK = 2'b10;

logic [1:0] cur_state;

`FF_MODULE #(.W(2)) init_state_ff (.clk(clk), .rstn(rstn),
                                   .d (cur_state == IDLE ? SET  :
                                       cur_state == SET  ? WORK :
                                                           WORK),
                                   .q(cur_state));

// ======================================
// Counters for scanning ROWs and COLUMNs
// base on counter of 1/2 line
// = HMAX = MAX_COL / 2                 =
// ======================================
localparam HMAX = MAX_COL >> 1;
localparam VMAX = MAX_ROW;

logic [9:0] vcount, hcount;
logic [5:0] pdcount;
logic       frame_end, half_2nd, nxt_half_2nd;
logic       vcount_ovf, hcount_ovf, pdcount_ovf;

libCOUNTER_max #(.DW(10)) vcount_counter (.clk(clk), .rstn(rstn),
    .we   (cur_state[0] | vcount_ovf),
    .ce   (hcount_ovf & pdcount_ovf),
    .din  (VMAX[9:0] - 1'b1),
    .of   (vcount_ovf),
    .dout (vcount));

libCOUNTER_max #(.DW(10)) hcount_counter (.clk(clk), .rstn(rstn),
    .we   (cur_state[0] | hcount_ovf),
    .ce   (pdcount_ovf),
    .din  (HMAX[9:0] - 1'b1),
    .of   (hcount_ovf),
    .dout (hcount));

libCOUNTER_max #(.DW(6))  period_counter (.clk(clk), .rstn(rstn),
    .we   (cur_state[0] | pdcount_ovf),
    .ce   (1'b1),
    .din  (UNIT[5:0] - 1'b1),
    .of   (pdcount_ovf),
    .dout (pdcount));

libSink #($bits(pdcount)) sink_pdcount (.i(pdcount));

assign nxt_half_2nd = cur_state [1] & hcount_ovf & pdcount_ovf ? (vcount_ovf ? 1'b0 : ~half_2nd) : half_2nd;
`FF_MODULE half_2nd_ff (.clk(clk), .rstn(rstn), .d(nxt_half_2nd), .q(half_2nd));

assign frame_end     = cur_state [1] & vcount_ovf & hcount_ovf & pdcount_ovf;

// =================================================
// Generating VSYNC, HSYNC and frame info (odd/even)
// =================================================
localparam FPORCH_PD = 10'd10;// 1.5 us (1pt = 0.15us)
localparam HSYNC_PD  = 10'd32;// 4.8 us 
localparam BPORCH_PD = 10'd30;// 4.5 us 
localparam SSYNC_PD  = 10'd16; // 2.4 us
localparam LSYNC_PD  = HMAX[9:0] - HSYNC_PD;

localparam E_FRM     = 1'b0; // Even frame
localparam O_FRM     = 1'b1; // Odd frame

logic lsync, ssync, vsync_sig;
logic hsync_sig, fporch_sig, bporch_sig;
logic h_invi_sig, v_invi_sig;
logic cur_frame;
logic h_visible;
logic v_visible;

assign lsync     = vcount > 10'd5 & vcount < 10'd12;
assign ssync     =  (vcount < 10'd6)                                                      // Pre-equalizing pulse
                  | (vcount > 10'd11 & vcount < (cur_frame == O_FRM ? 10'd18 : 10'd19));  // Pos-equalizing pulse
assign vsync_sig = lsync ? hcount < LSYNC_PD :
                   ssync ? hcount < SSYNC_PD :
                           1'b0;

assign hsync_sig  =  (cur_frame ^ half_2nd)
                   & (hcount > FPORCH_PD - 1'd1)
                   & (hcount < FPORCH_PD + HSYNC_PD);
assign fporch_sig =  (cur_frame ^ half_2nd)
                   & (hcount < FPORCH_PD); // Front porch
assign bporch_sig =   (cur_frame ^ half_2nd)
                   & (hcount > HSYNC_PD - 1'd1) & (hcount  < HSYNC_PD + BPORCH_PD); // Back porch after hsync

assign v_invi_sig = vcount < (cur_frame == O_FRM ? 10'd18 : 10'd19) + VOFFSET; // adjust to make pixel on line 0 visible
assign h_invi_sig = (cur_frame ^ half_2nd) ? hcount < (FPORCH_PD + HSYNC_PD + BPORCH_PD) + HOFFSET // adjust to make pixel on column 0 visible
                                           : 1'b0 ;//hcount > HMAX[9:0];

`FF_MODULE #(.W(1), .I(O_FRM)) frame_ff     (.clk(clk), .rstn(rstn), .d(interlace_mode & frame_end ? ~cur_frame : cur_frame), .q(cur_frame));
`FF_MODULE                     h_visible_ff (.clk(clk), .rstn(rstn), .d(~h_invi_sig),                                         .q(h_visible));
`FF_MODULE                     v_visible_ff (.clk(clk), .rstn(rstn), .d(~v_invi_sig),           .q(v_visible));
`FF_MODULE                     hsync_ff     (.clk(clk), .rstn(rstn), .d(hsync_sig | fporch_sig | bporch_sig), .q(hsync));
`FF_MODULE                     vsync_ff     (.clk(clk), .rstn(rstn), .d(lsync | ssync),         .q(vsync));

// =======================================
// Generating row and column of next pixel
// =======================================
logic [8:0]  row_cnt;
logic [10:0] col_cnt;

`FF_MODULE #(.W(9))  row_ff (.clk(clk), .rstn(rstn),
                             .d(v_invi_sig             ? 9'd0 :
                                v_visible & h_visible & h_invi_sig ? row_cnt + 1'b1 :
                                                         row_cnt),
                             .q(row_cnt));

`FF_MODULE #(.W(11)) col_ff (.clk(clk), .rstn(rstn),
                             .d(v_invi_sig ? 11'd0 :
                                h_invi_sig ? 11'd0 :
                                             col_cnt + 1'b1),
                             .q(col_cnt));

assign pf_pix_col = col_cnt [10:1];
assign pf_pix_row = {row_cnt, cur_frame};

// =========================
// Generating values to DAC
// =========================
localparam SYNC_LVL  = 8'd00;
localparam BLANK_LVL = 8'd25;

logic       sync_en;
logic [7:0] dac, nxt_dac;

assign sync_en = (lsync | ssync) ? vsync_sig : hsync_sig;
assign nxt_dac = sync_en                 ? SYNC_LVL  :
                 h_invi_sig | v_invi_sig ? BLANK_LVL :
                                           dac;

`FF_MODULE #(.W(8)) dac_ff   (.clk(clk), .rstn(rstn), .d(nxt_dac), .q(dac));

assign dac_bin   = h_visible & v_visible ? pix_val : dac;

endmodule
`undef FF_MODULE
//EOF
