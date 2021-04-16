// HMTH (c)
// Instruction decode

module Id
  import CpuPkg::*;
(
  input logic clk,
  input logic rstn,

  input  fetch_st fetched_info,
  input  logic    fetched_vld,
  output logic    fetched_gnt,
  
  output decode_st decoded_info,
  output logic     decoded_vld,
  input  logic     decoded_gnt,

  input  logic     invalidate, 
);

  logic [3:0]  opc;
  logic [5:0]  comp;
  logic [2:0]  dest;
  logic [2:0]  jump;

  decode_st nxt_decoded_info;

  assign {opc, comp, dest, jump} = fetched_info.inst;

  always_comb begin
    if (invalidate) fetched_gnt = 1'b0;
    else fetched_gnt = decoded_vld ? decoded_gnt : 1'b1;
  end

  always_ff @(posedge clk) begin
    if (~rstn) begin
      decoded_info <= '0;
      decoded_vld  <= 1'b0;
    end else begin
      if (invalidate) begin
        decoded_info <= '0; 
        decoded_vld  <= 1'b0;
      end else begin
        decoded_info <= decoded_gnt ? nxt_decoded_info : decoded_info;
        decoded_vld  <= decoded_gnt ? fetched_vld : decoded_vld;
      end
    end
  end

  always_comb begin
    nxt_decoded_info.pc    = fetched_info.pc;
    nxt_decoded_info.src   = 2'b00;
    nxt_decoded_info.x_src = 2'b00;
    nxt_decoded_info.y_src = 2'b00;
    {nxt_decoded_info.x_op, nxt_decoded_info.y_op, nxt_decoded_info.o_op}  = comp;
    nxt_decoded_info.imm   = 14'b0;
    nxt_decoded_info.err   = 1'b1;
    nxt_decoded_info.o_dst = 3'b0;
    nxt_decoded_info.jcond = 3'b0;
    nxt_decoded_info.dst   = 2'b00; // FUTURE

    if (opc[3] == 1'b0) begin // A-Instruction => A = X (imm) & Y (all 1)
      nxt_decoded_info.dst   = 2'b10; // FUTURE
      nxt_decoded_info.o_dst = 3'b100;
      nxt_decoded_info.src   = 2'b00;
      nxt_decoded_info.x_src = 2'b10;
      nxt_decoded_info.imm   = inst [14:0];
      {nxt_decoded_info.x_op, nxt_decoded_info.y_op, nxt_decoded_info.o_op}  = 6'b00_11_00;
      nxt_decoded_info.err   = 1'b0;
      nxt_decoded_info.jcond = 3'b000;
    end else begin // C-Instruction
      nxt_decoded_info.dst   = {|dest[2:1], dest [0]}; // FUTURE
      nxt_decoded_info.o_dst = dest;
      nxt_decoded_info.jcond = jump;
      case (comp)
        6'b00_11_00,
        6'b00_11_01,
        6'b00_11_10,
        6'b00_11_11,
        6'b01_11_11: begin
                       nxt_decoded_info.err = opc [0] ? 1'b1 : 1'b0; // field "a" is only 0
                       nxt_decoded_info.src = 2'b10;   // need internal source only - FUTURE
                       nxt_decoded_info.x_src = 2'b01; // X is D
                     end
        6'b10_10_10,
        6'b11_10_10,
        6'b11_11_11: begin
                       nxt_decoded_info.err = opc [0] ? 1'b1 : 1'b0; // field "a" is only 0
                       nxt_decoded_info.src = 2'b10;   // need internal source only - FUTURE
                     end
        6'b00_00_00,
        6'b00_00_10,
        6'b00_01_11,
        6'b01_00_11,
        6'b01_01_01: begin
                       nxt_decoded_info.err = 1'b0;
                       nxt_decoded_info.src = {1'b1, opc [0]}; // need either both internal source or 1 external source and 1 internal source - FUTURE
                       nxt_decoded_info.x_src = 2'b01; // X is D
                       nxt_decoded_info.y_src = opc [0] ? 2'b10 : 2'b01;
                     end
        6'b11_00_00,
        6'b11_00_01,
        6'b11_00_10,
        6'b11_00_11,
        6'b11_01_11: begin
                       nxt_decoded_info.err = 1'b0;
                       nxt_decoded_info.src = {1'b1, opc [0]}; // need either both internal source or 1 external source and 1 internal source - FUTURE
                       nxt_decoded_info.y_src = opc [0] ? 2'b10 : 2'b01;
                     end
        
      endcase
    end
  end

endmodule
// EOF
