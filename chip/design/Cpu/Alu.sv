// HMTH (c)
// ALU 

module Alu #(parameter D_W = 16) (
  input clk,
  input rstn,

  input  logic           vld_s,
  output logic           rdy_s
  input  logic [D_W-1:0] x_s,
  input  logic [D_W-1:0] y_s,

  input  logic           zx_s, // zero-ize x
  input  logic           nx_s, // negate x
  input  logic           zy_s, // zero-ize y
  input  logic           ny_s, // negate y
  input  logic           f_s,  // function code: 1 == Add, 0 == And
  input  logic           no_s, // negate output

  output logic           vld_m,
  input  logic           rdy_m,
  output logic [D_W-1:0] out_m,
  output logic           zr_m, // out == 0
  output logic           ng_m, // out < 0
  output logic           of_m  // overflow
);

  logic [D_W-1:0] modX1;
  logic [D_W-1:0] modXf;
  logic [D_W-1:0] modY1;
  logic [D_W-1:0] modYf;

  logic [D_WIDTH-1:0] calc_out;

  assign modX1 = zx ? {D_W{1'b0}} : x;
  assign modXf = nx ? ~modX1          : modX1;
  assign modY1 = zy ? {D_W{1'b0}} : y;
  assign modYf = ny ? ~modY1          : modY1;

  assign {of, calc_out} = f ? modXf + modYf : {1'b0, modXf & modYf};
  assign out = no ? ~calc_out : calc_out; 
  assign zr  = out == {D_W{1'b0}} ? 1'b1 : 1'b0;
  assign ng  = out [D_W-1];

  assign vld_m = vld_s;
  assign rdy_s = rdy_m;

endmodule
// EOF
