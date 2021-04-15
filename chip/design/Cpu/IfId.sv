// HMTH (c)
// Instruction decode

module Id (
  
);
  logic [15:0] inst;

  // Sources or Destination
  // [1:0] = {Internal (D,A,PC), External (M)}
  // X or Y sources
  // [4:0] = {imm, A, D, M, PC}
  logic [1:0]  src, dst;
  logic [1:0]  x_src;      // {imm, D}
  logic [1:0]  y_src;      // {M, A}
  logic [2:0]  o_dst;      // {A, D, M}
  logic [1:0]  x_op, y_op; // {zero-ize, negate}
  logic [1:0]  o_op;       // {add/and, negate} - 2'b00 == AND only
  logic [14:0] imm;
  logic        err;

  logic [3:0]  opc;
  logic [5:0]  comp;
  logic [2:0]  dest;
  logic [2:0]  jump;

  assign {opc, comp, dest, jump} = inst;

  always_comb begin
      src   = 2'b00;
      dst   = 2'b00;
      x_src = 2'b00;
      y_src = 2'b00;
      o_dst = 3'b000;
      {x_op, y_op, o_op}  = comp;
      imm   = 14'b0;
      err   = 1'b1;
    if (opc[3] == 1'b0) begin // A-Instruction => A = X (imm) & Y (all 1)
      src   = 2'b00;
      dst   = 2'b10;
      x_src = 2'b10;
      o_dst = 3'b100;
      imm   = inst [14:0];
      {x_op, y_op, o_op}  = 6'b00_11_00;
      err   = 1'b0;
    end else begin // C-Instruction
      case (comp)
      endcase

      case (dest)
      endcase

      case (jump)
      endcase
    end
  end

endmodule
// EOF
