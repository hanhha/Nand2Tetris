module CountOnes #(parameter DW=3) (
  input logic [DW-1:0] Vec,
  output logic [$clog2(DW):0] Ones
);

always @(Vec) begin
  Ones = 2'd0;
  for (int i = 0; i < DW; i++)
    Ones = Ones + Vec[i]; 
end

endmodule
