// Ha Minh Tran Hanh (c)
module MONO_PAL 
(
  input  logic clk,
  input  logic rstn,

  output logic [1:0] dac_bin,
  output logic [1:0] led // for debug in earlier stage
);

localparam SYNC  = 2'b00; // 0.0V
localparam BLACK = 2'b01; // 0.3V
localparam GRAY  = 2'b10; // 0.6V
localparam WHITE = 2'b11; // 1.0V

logic [24:0] counter;
logic [1:0] dac;

always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    counter <= 25'd0;
    dac     <= 2'b00;
  end else begin
    counter <= counter + 1'b1;
    dac     <= counter [23:0] == 24'd0 ? dac + 1'b1 : dac;
  end
end

assign dac_bin = dac;
assign led     = dac;

endmodule
