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

localparam IDLE = 0;
localparam BUSY = 1;

logic       st, nxt_st;
logic       nxt_gnt;
logic [9:0] cur_dat, nxt_dat;
logic       is_stop;

`FF_MODULE #(.W(1))            st_ff  (`CLKRST, .d (nxt_st),  .q(st));
`FF_MODULE #(.W(1), .I(1'b1))  gnt_ff (`CLKRST, .d (nxt_gnt), .q(gnt));
`FF_MODULE #(.W(10))           dat_ff (`CLKRST, .d (nxt_dat), .q(cur_dat));

always @(*) begin
  nxt_dat = vld & gnt ? {1'b1, dat, 1'b0} :
                        baudrate_ovf ? {1'b1, cur_dat [7:1]} : cur_dat; 
end

assign is_stop = bit_cnt == 4'd9 ? 1'b1 : 1'b0;

always @(*) begin
  case (st)
    IDLE: begin
            nxt_gnt = ~vld;
            nxt_st  = vld ? BUSY : st; 
            
            nxt_baudrate_early_ovf = 1'b0;
            nxt_cnt                = vld ? (TW)'d0 : cnt;
            nxt_bit_cnt            = vld ? 4'd0 : bit_cnt;
          end
    BUSY: begin
            nxt_gnt = is_stop ? baudrate_early_ovf ? 1'b1
                                                   : baudrate_ovf ? ~vld
                                                                  : gnt
                              : gnt;
            nxt_st  = is_stop & baudrate_ovf & ~vld ? IDLE : st;   

            nxt_cnt                = cnt        == CLK_PER_BAUD - (TW)'d1 ? (TW)'b0 : cnt + 1'b1;
            nxt_baudrate_early_ovf = cnt + 1'b1 == CLK_PER_BAUD - (TW)'d2 ? 1'b1    : 1'b0;
            nxt_bit_cnt            = baudrate_ovf ? bit_cnt == 4'd9 ? 4'd0 : bit_cnt + 1'b1
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
    
    // TODO: add assertions to prove design here
  `endif
`endif

endmodule
// EOF
