// Ha Minh Tran Hanh (c)

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_PF_MEM #(parameter AW = 19, DW = 16)
(
  input  logic          clk,
  input  logic          rstn,

  input  logic [AW-1:0] pf_addr,
  output logic [7:0]    pf_dat,

  output logic          mem_addr_vld,
  input  logic          mem_addr_gnt,
  output logic [AW-1:0] mem_addr,
  input  logic          mem_dat_vld,
  output logic          mem_dat_gnt,
  input  logic [DW-1:0] mem_dat
);

// TODO: full operation 
// Text mode test
assign pf_dat = pf_addr < 95 ? pf_addr + 32 : 32;

assign {mem_addr_vld, mem_addr, mem_dat_gnt} = {1'b0, {AW{1'b0}}, 1'b1};

libSink #(.W(DW)) sink_mem_dat       (.i(mem_dat));
libSink           sink_mem_vld       (.i(mem_dat_vld));
libSink           sink_mem_gnt       (.i(mem_addr_gnt));

endmodule
`undef FF_MODULE
//EOF
