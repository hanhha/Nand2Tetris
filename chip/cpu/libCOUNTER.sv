module libCOUNTER #(parameter D_WIDTH= 16)
(
  input  logic clk,
  input  logic rstn,
  input  logic we,

  input  logic [D_WIDTH-1:0] din,
  output logic               of,
  output logic [D_WIDTH-1:0] dout
);

always_ff @(posedge clk or negedge rstn) begin
  if (~rstn) dout <= {D_WIDTH{1'b0}};
  else begin
    {of, dout} <= we == 1'b1 ? {1'b0, din} : dout + 1'b1;
  end
end

endmodule
