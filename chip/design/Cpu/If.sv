// HMTH (c)
// Instruction fetch 

module Id (
  input logic clk,
  input logic rstn,

  input  logic [15:0] pc,
  
  output fetch_st  fetched_info,
  output logic     fetched_vld,
  input  logic     fetched_gnt,

  output mem_req_st mem_req,
  input  mem_rsp_st mem_rsp
);

  logic [15:0] pf_pc;

  assign fetched_info = stored ? stored_info : {fetched_pc};
  assign fetched_vld  = stored ? 1'b1 : mem_rsp.rdy;

  always_ff @(posedge clk) begin
    if (~rstn) stored <= 1'b0;
    else stored <= fetched_gnt 
  end

endmodule
// EOF
