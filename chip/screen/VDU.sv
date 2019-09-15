// Ha Minh Tran Hanh (c)
// Video Processing Unit
// Each bit in din corresponding to 1 pixel
// addr x D_WIDTH + bit index = row * col_n + col
// all are 0 base

module VPU #(parameter D_WIDTH   = 16,
             parameter A_WIDTH   = 4,
             parameter DAC_WIDTH = 2)
(
  input  logic               clk,
  input  logic               rstn,
  input  logic               cs,
  input  logic               we,
  input  logic [A_WIDTH-1:0] addr,
  input  logic [D_WIDTH-1:0] din,

  output logic               frame_done,

  output logic [DAC_WIDTH-1:0] dac_bin
);


endmodule
