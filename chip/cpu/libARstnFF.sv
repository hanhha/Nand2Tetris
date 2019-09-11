module libARstnFF #(parameter               D_WIDTH = 1,
                    parameter [D_WIDTH-1:0] D_INIT = 0) 
(
  input logic clk,
  input logic rstn,
  input logic [D_WIDTH-1:0] d,
  input logic [D_WIDTH-1:0] q
);

always_ff @(posedge clk or negedge rstn) begin
  if (~rstn) q <= D_INIT;
  else       q <= d;
end

endmodule: libARstnFF
