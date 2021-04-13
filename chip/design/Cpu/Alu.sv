// HMTH (c)
// ALU 

module Alu #(parameter D_W = 16) (
  input clk,
  input rstn,

  input logic [D_W-1:0]  x,
  input logic [D_W-1:0]  y,

  input logic            zx, // zero-ize x
  input logic            nx, // negate x
  input logic            zy, // zero-ize y
  input logic            ny, // negate y
  input logic            f,  // function code: 1 == Add, 0 == And
  input logic            no, // negate output

  output logic [D_W-1:0] out,
  output logic           zr, // out == 0
  output logic           ng, // out < 0
  output logic           of  // overflow
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
  assign out = no ? ~calc_out : out; 
  assign zr  = out == {D_W{1'b0}} ? 1'b1 : 1'b0;
  assign ng  = out [D_W-1];

endmodule
// EOF
