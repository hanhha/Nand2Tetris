// Ha Minh Tran Hanh (c)
// Counter from 0 which supports overflow value and enable
//  ce {of, dout} (next cycle)
//   0  {of, dout}
//   1  dout + 1
// ovf will assert at same cycle of dout == din

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module libCOUNTER_max #(parameter DW= 16)
(
  input  logic clk,
  input  logic rstn,
  input  logic we, // write enable - to present din at next cycle
  input  logic ce, // count enable

  input  logic [DW-1:0] din,
  output logic          of,
  output logic [DW-1:0] dout
);

logic nxt_of;
logic [DW-1:0] nxt_dout;
logic [DW-1:0] ovf_val;

`FF_MODULE #(.W(DW)) ovf_ff (.clk (clk), .rstn (rstn), .d ({we ? din : ovf_val}), .q (ovf_val));

`FF_MODULE #(.W(DW+1)) counter_ff (.clk (clk), .rstn (rstn),
                                   .d ({nxt_of, nxt_dout}),
                                   .q ({of,     dout}));

assign {nxt_of, nxt_dout} = ce ? of ? {(DW+1){1'b0}}
                                    : dout + 1'b1 == {1'b0, ovf_val} ? {1'b1, ovf_val}
                                                                     : dout + 1'b1
                               : {of, dout};

endmodule
`undef FF_MODULE
//EOF
