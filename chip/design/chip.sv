module chip (
  input logic clk,
  input logic rstn,
  output logic [7:0] dac_bin);

logic clk33;

`ifdef SYNTHESIS
libPll33 clk_mul(.clock_in(clk), .clock_out (clk33), .locked ());
`else
assign clk33 = clk;
`endif

SCREEN ISCREEN (
  .clk  (clk33),
  .rstn (rstn),

/* verilator lint_off PINCONNECTEMPTY */
  .mem_addr_vld (),
  .mem_addr_gnt (1'b0),
  .mem_addr     (),
  .mem_dat_vld  (1'b0),
  .mem_dat_gnt  (),
  .mem_dat      (16'd0),
/* verilator lint_on PINCONNECTEMPTY */

  .dac_bin (dac_bin)
);

endmodule
