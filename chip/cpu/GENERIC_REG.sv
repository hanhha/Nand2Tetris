module GENERIC_REG #(parameter D_WIDTH = 16,
             parameter REG_NO  = 16,
             parameter A_WIDTH = 4)
(
  input  logic               clk,
  input  logic               rstn,
  input  logic               we,

  input  logic [A_WIDTH-1:0] addr,
  input  logic [D_WIDTH-1:0] din,

  output logic [D_WIDTH-1:0] dout
);

logic [D_WIDTH-1:0] regmem [0:A_WIDTH-1];

always_ff @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    for (int i = 0; i < REG_NO; i++ ) begin
      regmem [i] <= {D_WIDTH{1'b0}};
    end
  end else begin
    dout <= regmem [addr];
    if (we) regmem [addr] <= din;
  end
end
 
endmodule: GENERIC_REG
