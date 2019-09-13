module ALU #(parameter D_WIDTH = 16) (
  input clk,
  input rstn,

  input logic [D_WIDTH-1:0] x,
  input logic [D_WIDTH-1:0] y,
  input logic               vldi,
  input logic               rdyo,

  input logic               zx, // zero-ize x
  input logic               nx, // negate x
  input logic               zy, // zero-ize y
  input logic               ny, // negate y
  input logic               f,  // function code: 1 == Add, 0 == And
  input logic               no, // negate output

  output logic               vldo,
  output logic               rdyi,
  output logic [D_WIDTH-1:0] out,
  output logic               zr, // out == 0
  output logic               ng, // out < 0
  output logic               of  // overflow
);

  logic [D_WIDTH-1:0] modX1;
  logic [D_WIDTH-1:0] modXf;
  logic [D_WIDTH-1:0] modY1;
  logic [D_WIDTH-1:0] modYf;

  logic [D_WIDTH-1:0] nxt_out, calc_out;
  logic               nxt_zr; // out == 0
  logic               nxt_ng; // out < 0
  logic               nxt_of; // overflow

  assign modX1 = zx ? {D_WIDTH{1'b0}} : x;
  assign modXf = nx ? ~modX1          : modX1;
  assign modY1 = zy ? {D_WIDTH{1'b0}} : y;
  assign modYf = ny ? ~modY1          : modY1;

  assign {nxt_of, calc_out} = f ? modXf + modYf : {1'b0, modXf & modYf};
  assign            nxt_out = no ? ~calc_out : out; 
  assign             nxt_zr = nxt_out == {D_WIDTH{1'b0}} ? 1'b1 : 1'b0;
  assign             nxt_ng = nxt_out [D_WIDTH-1];

libHndSk #(.D_WIDTH(D_WIDTH+3)) out_hs (.datai({nxt_out, nxt_of, nxt_zr, nxt_ng}), .datao({out, of, zr, ng}),
                                        .vldi(vldi), .vldo(vldo), .rdyi(rdyi), .rdyo(rdyo),
                                        .clk(clk), .rstn(rstn));

endmodule
