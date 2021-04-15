// HMTH (c)
// Source select

module Ss #(parameter D_W = 16) (
  input clk,
  input rstn,

  input  logic [D_W-1:0] A,
  input  logic [D_W-1:0] D,
  input  logic [D_W-1:0] PC,

  input  logic [D_W-1:0] M,
  input  logic           M_vld,

  output logic           vld_m,
  input  logic           rdy_m
  output logic [D_W-1:0] x_m,
  output logic [D_W-1:0] y_m,

  output logic           zx_m, // zero-ize x
  output logic           nx_m, // negate x
  output logic           zy_m, // zero-ize y
  output logic           ny_m, // negate y
  output logic           f_m,  // function code: 1 == Add, 0 == And
  output logic           no_m, // negate output
);

  assign vld_m = 

endmodule
// EOF
