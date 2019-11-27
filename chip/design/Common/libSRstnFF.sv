module libSRstnFF #(parameter W = 1,
                    parameter I = 0) 
(
  input  logic clk,
  input  logic rstn,
  input  logic [W-1:0] d,
  output logic [W-1:0] q
);

always @(posedge clk) begin
  if (~rstn) q <= I [W-1:0];
  else       q <= d;
end

endmodule
