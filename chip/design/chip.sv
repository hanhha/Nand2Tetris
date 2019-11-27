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

//  .ce   (1'b0),
//  .we   (1'b0),
//  .din  (16'd0),
//  .addr (3'd0),
//  .dvld (),
//  .dout (),
//  .cack (),

/* verilator lint_off PINCONNECTEMPTY */
  .mem_ce (),
  .mem_addr (),
/* verilator lint_on PINCONNECTEMPTY */
  .mem_vld (1'b0),
  .mem_dat (16'd0),

  .dac_bin (dac_bin)
);

endmodule
