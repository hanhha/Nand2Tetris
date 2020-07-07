// HMTH (c)
// Simple protocol to write/read from data queues
// This features read queue and write queue that commmunicate to system via simple handshake protocol

module QIf #(parameter DW = 8, TX_DEPTH = 8, RX_DEPTH = 8) (
  input logic clk,
  input logic rstn,

  input  logic          wr_vld,
  output logic          wr_gnt,
  input  logic          wr_wait,
  input  logic [DW-1:0] wr_dat,
  output logic          wr_err,
  output logic          wr_rvld,
  input  logic          wr_rgnt,

  input  logic          rd_vld,
  output logic          rd_gnt,
  input  logic          rd_wait,
  output logic [DW-1:0] rd_dat,
  output logic          rd_err,
  output logic          rd_rvld,
  input  logic          rd_rgnt,

  output logic          txq_empty_n,
  output logic [DW-1:0] txq_dat,
  input  logic          txq_re,

  output logic          rxq_full_n,
  input  logic          rxq_we,
  input  logic [DW-1:0] rxq_dat
);

logic tx_we, tx_full_n, rx_re, rx_empty_n;
logic [DW-1:0] tx_dat;

XFifo #(.DW (DW), .DEPTH (TX_DEPTH)) txq (`CLKRST,
  .we (tx_we),  .din  (tx_dat),  .full_n (tx_full_n),
  .re (txq_re), .dout (txq_dat), .empty_n (txq_empty_n));

XFifo #(.DW (DW), .DEPTH (RX_DEPTH)) rxq (`CLKRST,
  .we (rxq_we), .din (rxq_dat), .full_n (rxq_full_n),
  .re (rx_re),  .dout (rd_dat), .empty_n (rx_empty_n));

localparam RST  = 3'b000;
localparam IDLE = 3'b001;
localparam WAIT = 3'b010;
localparam RSP  = 3'b100;

logic [2:0] wr_st, nxt_wr_st, rd_st, nxt_rd_st;
logic wr_ok, rd_ok, wr_nok, rd_nok;

assign wr_ok  = wr_vld & tx_full_n;
assign wr_nok = wr_vld & ~tx_full_n;
assign rd_ok  = rd_vld & rx_empty_n;
assign rd_nok = rd_vld & ~rx_empty_n;

always @(*) begin
  case (rd_st)
    RST  : nxt_rd_st = IDLE;
    IDLE : nxt_rd_st = {rd_vld & (~rd_wait | rd_ok),
                        rd_vld & rd_nok & rd_wait,
                       ~rd_vld};
    WAIT : nxt_rd_st     = rd_st [1] & rx_empty_n ? RSP : rd_st;
    RSP  : nxt_rd_st     = rd_rgnt ? IDLE : rd_st;
    default  : nxt_rd_st = RST;
  endcase
end

logic nxt_rd_err;
assign nxt_rd_err = rd_st [0] & nxt_rd_st [2] ? (rd_nok ? 1'b1 : 1'b0)
                                              : (rd_st [1] & nxt_rd_st [2] ? 1'b0 : rd_err);

`FF_MODULE #(.W(3), .I(RST)) rd_st_ff (`CLKRST, .d (nxt_rd_st), .q(rd_st));
`FF_MODULE rd_err_ff (`CLKRST, .d (nxt_rd_err), .q(rd_err));

assign rd_gnt   =  rd_st [0];
assign rd_rvld  =  rd_st [2];

always @(*) begin
  case (wr_st)
    RST  : nxt_wr_st = IDLE;
    IDLE : nxt_wr_st = {wr_vld & (~wr_wait | wr_ok),
                        wr_vld & wr_nok & wr_wait,
                       ~wr_vld};
    WAIT : nxt_wr_st     = wr_st [1] & tx_full_n ? RSP : wr_st;
    RSP  : nxt_wr_st     = wr_rgnt ? IDLE : wr_st;
    default  : nxt_wr_st = RST;
  endcase
end

logic nxt_wr_err;
assign nxt_wr_err = wr_st [0] & nxt_wr_st [2] ? (wr_nok ? 1'b1 : 1'b0)
                                              : (wr_st [1] & nxt_wr_st [2] ? 1'b0 : wr_err);

`FF_MODULE #(.W(3), .I(RST)) wr_st_ff (`CLKRST, .d (nxt_wr_st), .q(wr_st));
`FF_MODULE wr_err_ff (`CLKRST, .d (nxt_wr_err), .q(wr_err));

assign wr_gnt   =  wr_st [0];
assign wr_rvld  =  wr_st [2];


logic nxt_rx_re;
assign nxt_rx_re = nxt_rd_st [2] & (rd_st [1] | (rd_st [0] & rd_ok)) ? 1'b1 : 1'b0;
`FF_MODULE rx_re_ff (`CLKRST, .d (nxt_rx_re), .q(rx_re));

logic nxt_tx_we;
assign nxt_tx_we = nxt_wr_st [2] & (wr_st [1] | (wr_st [0] & wr_ok)) ? 1'b1 : 1'b0;
`FF_MODULE tx_we_ff (`CLKRST, .d (nxt_tx_we), .q(tx_we));

logic [DW-1:0] nxt_tx_dat;
assign nxt_tx_dat = wr_st [0] & wr_vld ? wr_dat : tx_dat;
`FF_MODULE #(.W(DW)) tx_dat_ff (`CLKRST, .d (nxt_tx_dat), .q(tx_dat));

`ifdef FORMAL
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;

    initial assume (!rstn);

    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid;

    always @(posedge clk) begin
      if (assert_en) begin
        if (wr_vld & wr_gnt & ~wr_wait) begin
          if (tx_full_n) begin
            @(posedge clk); assert (wr_rvld && ~wr_err);
          end else begin
            @(posedge clk); assert (wr_rvld && wr_err);
          end
        end else if ($past(wr_vld & wr_gnt & wr_wait) begin
          wait (tx_full_n); assert (wr_rvld && ~wr_err);
        end
      end
    end

    always @(posedge clk) begin
      if (assert_en) begin
        if (rd_vld & rd_gnt & ~rd_wait) begin
          if (rx_empty_n) begin
            @(posedge clk); assert (rd_rvld && ~rd_err);
          end else begin
            @(posedge clk); assert (rd_rvld && rd_err);
          end
        end else if ($past(rd_vld & rd_gnt & rd_wait) begin
          wait (rx_empty_n); assert (rd_rvld && ~rd_err);
        end
      end
    end
    // assert: tx_we and rx_re are asserted only in 1 cycle
    always @(posedge clk) begin
      if (assert_en) begin
        if (tx_we) assert ($past(tx_we) == 1'b0);
        if (rx_re) assert ($past(rx_re) == 1'b0);
      end
    end
  `endif
`endif
endmodule
//EOF
