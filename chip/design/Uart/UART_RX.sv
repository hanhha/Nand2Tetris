// HMTH (c)
// Simple UART

module UART_RX #(parameter CLK_PER_BAUD = 8, TW = 10)
(
  input logic clk,
  input logic rstn,

  output logic       vld,
  output logic [7:0] dat,

// To UART pin
  input  logic       uart_rx
);

localparam DW            = 8;

localparam BIT_PER_TRANS = DW + 2;
localparam EDW = BIT_PER_TRANS + 1;

localparam IDLE = 0;
localparam MON  = 1;
localparam SWT  = 2;
localparam BRK  = 3;

logic [1:0]     st, nxt_st;
logic [3:0]     bit_cnt, nxt_bit_cnt;
logic [TW-1:0]  cnt, nxt_cnt;
logic [EDW-1:0] shfdat, nxt_shfdat;
logic           bit_cnt_ovf, cnt_ovf;

logic rx_sync, mon_bitval, nxt_mon_bitval;
logic syncer;

`FF_MODULE #(.W(2), .I(2'h3)) sync_ff (`CLKRST, .d ({uart_rx, syncer}), .q({syncer, rx_sync}));

assign bit_cnt_ovf = bit_cnt == BIT_PER_TRANS - 1 ? 1'b1 : 1'b0;
assign cnt_ovf     = cnt     == CLK_PER_BAUD - 1 ? 1'b1 : 1'b0;

`FF_MODULE #(.W(2), .I(IDLE)) rx_sync_ff    (`CLKRST, .d (nxt_st),      .q(st));
`FF_MODULE #(.W(4))           bit_cnt_ff    (`CLKRST, .d (nxt_bit_cnt), .q(bit_cnt));
`FF_MODULE #(.W(TW))          cnt_ff        (`CLKRST, .d (nxt_cnt), .q(cnt));
`FF_MODULE #(.W(1), .I(1'b1)) mon_bitval_ff (`CLKRST, .d (nxt_mon_bitval), .q(mon_bitval));

`FF_MODULE #(.W(EDW), .I({1'b1, {BIT_PER_TRANS{1'b0}}}))  shfdat_ff  (`CLKRST, .d (nxt_shfdat), .q(shfdat));

assign dat = shfdat [2 +: DW]; 
assign vld = shfdat [0];

always @(*) begin
  nxt_shfdat     = shfdat;
  nxt_mon_bitval = mon_bitval;
  nxt_st         = st;

  case (st)
    IDLE: begin
            nxt_cnt        = {{(TW-1){1'b0}}, 1'b1};
            nxt_bit_cnt    = 4'd0;
            nxt_shfdat     = {1'b1, {(EDW-1){1'b0}}};
            if (rx_sync ^ mon_bitval) begin
              nxt_mon_bitval = rx_sync;
              nxt_st         = MON;
            end
          end
    MON:  begin
            if (rx_sync ^ mon_bitval) begin
              nxt_st = BRK;
              nxt_shfdat = {1'b1, {BIT_PER_TRANS{1'b0}}};
            end else if (cnt_ovf) begin
              nxt_cnt    = {TW{1'b0}};
              nxt_shfdat = {mon_bitval, shfdat [EDW-1:1]};
              if (bit_cnt_ovf) begin
                nxt_bit_cnt = 4'd0;
                nxt_mon_bitval = 1'b1;
                nxt_st      = IDLE;
              end else begin
                nxt_bit_cnt = bit_cnt + 1'b1;
                nxt_st      = SWT;
              end
            end else
              nxt_cnt = cnt + 1'b1;
          end
    SWT:  begin
            nxt_cnt        = cnt + 1'b1;
            if (bit_cnt_ovf & ~rx_sync) begin
              nxt_st = BRK;
              nxt_shfdat = {1'b1, {BIT_PER_TRANS{1'b0}}};
            end else begin
              nxt_st         = MON;
              nxt_mon_bitval = rx_sync;
            end
          end
    BRK : begin
            nxt_mon_bitval = 1'b1;
            if (~rx_sync) begin
              nxt_st = IDLE;
            end
          end
  endcase
end

`ifndef SYNTHESIS
  // Poor man's mplementation
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;

    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid; 

    always @(posedge clk) begin
      if (assert_en) begin
        if (vld) assert ((shfdat [1] == 1'b0) && (shfdat[EDW-1] == 1'b1)); // vld only if satisfy pattern of start and stop bits
        if (vld) assert ($past(vld) == 1'b0); // only vld in 1 cycle 
        if (vld) assert (st == IDLE); // vld in IDLE state only
      end
    end
  `endif
`endif

endmodule
// EOF
