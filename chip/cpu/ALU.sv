module ALU #(parameter D_WIDTH = 16) (
  input logic [D_WIDTH-1:0] x,
  input logic [D_WIDTH-1:0] y,
  
  input logic               zx, // zero-ize x
  input logic               nx, // negative x
  input logic               zx, // zero-ize y
  input logic               nx, // negative y
  input logic               f,  // function code: 1 == Add, 0 == And
  input logic               no, // negative output
  
  output logic [D_WIDTH-1:0] out,
  output logic               zr, // out == 0
  output logic               ng, // out < 0
  output logic               of  // overflow
);

logic [D_WIDTH-1:0] modX1;
logic [D_WIDTH-1:0] modXf;
logic [D_WIDTH-1:0] modY1;
logic [D_WIDTH-1:0] modYf;

assign modX1 = zx ? {D_WIDTH{1'b0}} : x; 
assign modXf = nx ? ~modX1          : modX1; 
assign modY1 = zy ? {D_WIDTH{1'b0}} : y; 
assign modYf = ny ? ~modY1          : modY1; 

assign {of, out} = f ? modXf + modYf : {1'b0, modXf & modYf};
assign        zr = out == {D_WIDTH{1'b0}} ? 1'b1 : 1'b0;
assign        ng = out <  {D_WIDTH{1'b0}} ? 1'b1 : 1'b0;

endfunction: ALU
