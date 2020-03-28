// HMTH (c)
// Simple protocol to write/read from data queues
// This features read queue and write queue that commmunicate to system via simple handshake protocol

module QIf #(parameter DW = 8, TX_DEPTH = 8, RX_DEPTH = 8) (
  input logic clk,
  input logic rstn,

  input  logic          req_vld,
  output logic          req_gnt,
  input  logic          req_wr,
  input  logic          req_wait,
  input  logic [DW-1:0] req_dat,

  output logic          rsp_vld,
  input  logic          rsp_gnt,
  output logic          rsp_err,
  output logic [DW-1:0] rsp_dat,

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
  .re (rx_re),  .dout (rsp_dat), .empty_n (rx_empty_n));

localparam IDLE = 4'b0001;
localparam WRIT = 4'b0010;
localparam READ = 4'b0100;
localparam RSP  = 4'b1000;

logic [3:0] cur_st, nxt_st;
logic wr_ok, rd_ok, wr_nok, rd_nok;

assign wr_ok  = req_wr & tx_full_n;
assign wr_nok = req_wr & ~tx_full_n;
assign rd_ok  = ~req_wr & rx_empty_n;
assign rd_nok = ~req_wr & ~rx_empty_n;

always @(*) begin
  case (cur_st)
    IDLE : nxt_st = {req_vld & (~req_wait | wr_ok | rd_ok),
                     req_vld & rd_nok & req_wait,
                     req_vld & wr_nok & req_wait,
                     ~req_vld};
    WRIT,
    READ : nxt_st = cur_st [1] & tx_full_n | cur_st [2] & rx_empty_n ? RSP : cur_st;
    RSP  : nxt_st = rsp_gnt ? IDLE : cur_st;
    default  : nxt_st = IDLE;
  endcase
end

`FF_MODULE #(.W(4), .I(IDLE)) cur_st_ff (`CLKRST, .d (nxt_st), .q(cur_st));

assign req_gnt   =  cur_st [0];
assign rsp_vld   =  cur_st [3];

logic nxt_rsp_err;
assign nxt_rsp_err = cur_st [0] & nxt_st [3] ? ((wr_nok | rd_nok) ? 1'b1
                                                                  : 1'b0)
                                             : (cur_st [1] | cur_st [2]) & nxt_st [3] ? 1'b0
                                                                                      : rsp_err;
`FF_MODULE rsp_err_ff (`CLKRST, .d (nxt_rsp_err), .q(rsp_err));

logic nxt_rx_re;
assign nxt_rx_re = nxt_st [3] & (cur_st [2] | (cur_st [0] & rd_ok)) ? 1'b1 : 1'b0;
`FF_MODULE rx_re_ff (`CLKRST, .d (nxt_rx_re), .q(rx_re));

logic nxt_tx_we;
assign nxt_tx_we = nxt_st [3] & (cur_st [1] | (cur_st [0] & wr_ok)) ? 1'b1 : 1'b0;
`FF_MODULE tx_we_ff (`CLKRST, .d (nxt_tx_we), .q(tx_we));

logic [DW-1:0] nxt_tx_dat;
assign nxt_tx_dat = cur_st [0] & req_wr ? req_dat : tx_dat;
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
      // assert: only 4 defined onehot states
        assert (cur_st == IDLE || cur_st == WRIT || cur_st == READ || cur_st == RSP);
      // assert : valid change state: IDLE -> [WRIT, READ, RSP]
      //                              WRIT -> RSP -> IDLE
      //                              READ -> RSP -> IDLE
      //                              RSP -> IDLE
        if (cur_st == IDLE) assert ($past(cur_st) == IDLE || $past(cur_st) == RSP);
        if (cur_st == WRIT) assert ($past(cur_st) == WRIT || $past(cur_st) == IDLE);
        if (cur_st == READ) assert ($past(cur_st) == READ || $past(cur_st) == IDLE);
        if (cur_st == RSP)  assert ($past(cur_st) == RSP  || $past(cur_st) == IDLE || $past(cur_st) == READ || $past(cur_st) == WRIT);
      end
    end
    // assert: tx_we and rx_re are asserted only in 1 cycle
    always @(posedge clk) begin
      if (assert_en) begin
        if (tx_we) assert ($past(tx_we) == 1'b0);
        if (rx_re) assert ($past(rx_re) == 1'b0);
      end
    end
  `else
    //TODO: use concurrent assertion and SVA sequences for above assertions
  `endif
`endif
endmodule
//EOF
