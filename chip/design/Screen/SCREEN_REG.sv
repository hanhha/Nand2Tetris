`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_REG #(parameter DW = 16, AW = 3)
( input  logic clk,
  input  logic rstn,

  output logic          interlace_mode
);

assign interlace_mode = 1'b1;

libSink sink_clk(.i(clk));
libSink sink_rst(.i(rstn));

endmodule
`undef FF_MODULE
//EOF
