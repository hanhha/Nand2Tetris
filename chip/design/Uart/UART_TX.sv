// HMTH (c)
// Simple UART

module UART_TX #(parameter CLK_PER_BAUD = 8, TW = 10)
(
  input logic clk,
  input logic rstn,

  input  logic       vld,
  input  logic [7:0] dat,
  output logic       gnt,

// To UART pin
  output logic       uart_tx
);

localparam DW = 8;
localparam BITS_PER_TRANS = DW + 2;

localparam IDLE = 0;
localparam BUSY = 1;

logic       st, nxt_st;
logic       nxt_gnt;
logic [BITS_PER_TRANS-1:0] cur_dat, nxt_dat;
logic       is_stop;

logic [3:0]    bit_cnt, nxt_bit_cnt;
logic [TW-1:0] cnt, nxt_cnt;

logic baudrate_ovf, baudrate_early_ovf, nxt_baudrate_early_ovf;

`FF_MODULE #(.W(1))              st_ff  (`CLKRST, .d (nxt_st),  .q(st));
`FF_MODULE #(.W(1), .I(1'b1))    gnt_ff (`CLKRST, .d (nxt_gnt), .q(gnt));

`FF_MODULE #(.W(BITS_PER_TRANS), .I({{(BITS_PER_TRANS-1){1'b1}}, 1'b1})) dat_ff (`CLKRST, .d (nxt_dat), .q(cur_dat));

assign nxt_dat = vld & gnt ? {1'b1, dat, 1'b0} :
                             baudrate_ovf ? {1'b1, cur_dat [BITS_PER_TRANS-1:1]} : cur_dat; 

assign is_stop = bit_cnt == BITS_PER_TRANS - 1 ? 1'b1 : 1'b0;

always @(*) begin
  case (st)
    IDLE: begin
            nxt_gnt = ~vld;
            nxt_st  = vld ? BUSY : st; 
            
            nxt_baudrate_early_ovf = 1'b0;
            nxt_cnt                = vld ? {TW{1'b0}} : cnt;
            nxt_bit_cnt            = vld ? 4'd0 : bit_cnt;
          end
    BUSY: begin
            nxt_gnt = is_stop ? baudrate_early_ovf ? 1'b1
                                                   : baudrate_ovf ? ~vld
                                                                  : gnt
                              : gnt;
            nxt_st  = is_stop & baudrate_ovf & ~vld ? IDLE : st;   

            nxt_cnt                = cnt        == CLK_PER_BAUD - 1 ? {TW{1'b0}} : cnt + 1'b1;
            nxt_baudrate_early_ovf = cnt + 1'b1 == CLK_PER_BAUD - 2 ? 1'b1    : 1'b0;
            nxt_bit_cnt            = baudrate_ovf ? is_stop ? 4'd0 : bit_cnt + 1'b1
                                                  : bit_cnt; 
          end
  endcase
end

`FF_MODULE #(.W(1), .I(1'b1)) tx_ff        (`CLKRST, .d (cur_dat [0]),            .q (uart_tx));
`FF_MODULE #(.W(1))           early_ovf_ff (`CLKRST, .d (nxt_baudrate_early_ovf), .q (baudrate_early_ovf));
`FF_MODULE #(.W(1))           ovf_ff       (`CLKRST, .d (baudrate_early_ovf),     .q (baudrate_ovf));
`FF_MODULE #(.W(TW))          cnt_ff       (`CLKRST, .d (nxt_cnt),                .q (cnt));
`FF_MODULE #(.W(4))           bit_ff       (`CLKRST, .d (nxt_bit_cnt),            .q (bit_cnt));

`ifndef SYNTHESIS
  // Poor man's mplementation
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;
  			
    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid; 
    
    always @(posedge clk) begin
      if (assert_en) begin
        if (gnt) assert ((is_stop & baudrate_ovf) || (st == IDLE)); // gnt only if finish transfering last bit or in IDLE state
      end
    end
  `endif
`endif

endmodule
// EOF
