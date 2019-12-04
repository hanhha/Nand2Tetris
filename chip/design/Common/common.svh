`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

`define CLKRST .clk(clk), .rstn(rstn)
