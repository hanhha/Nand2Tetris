// HMTH (c)
// Branch and Status Controller

module BrSt #(parameter PC_W = 16, D_W = 16) (
  input  logic [D_W-1:0] a_dat,
  input  logic           a_vld,

  input  logic [D_W-1:0] a_dat,
  input  logic           a_vld,

  output logic [D_W-1:0] a,
  output logic [D_W-1:0] d,
  output logic me, // FUTURE for memory error
  output logic zr,
  output logic ng,
  output logic of,
  output logic [PC_W-1:0] pc,
  output logic [PC_W-1:0] f_pc
);
endmodule
// EOF
