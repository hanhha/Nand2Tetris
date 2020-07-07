// HMTH (c)
// Loopback testbench for UART

module UART_LB (
/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input logic		clk,			// To UART of UART.v
input logic		rstn,			// To UART of UART.v
input logic		uart_rx,		// To UART of UART.v
// End of automatics
/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output logic		uart_tx		// From UART of UART.v
// End of automatics
);


  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [7:0]		rd_dat;			// From UART of UART.v
  logic			rd_rgnt;		// From UART of UART.v
  logic			rd_rvld;		// From UART of UART.v
  // End of automatics

/* UART AUTO_TEMPLATE (
  .wr_vld  (rd_rvld),
  .wr_wait (1'b1),
  .wr_dat  (rd_dat),
  .wr_gnt  (rd_rgnt),
  .rd_vld  (1'b1),
  .rd_wait (1'b1),
  .rd_gnt  (),
  .rd_err  (),
  .wr_err  (),
  .wr_rvld (),
  .wr_rgnt (1'b1),
  .rxq_full_n (),
); */
UART #(.CLK_PER_BAUD (8), .TW(10), .DEPTH(4))
  UART (/*AUTOINST*/
	// Outputs
	.uart_tx			(uart_tx),
	.rd_dat				(rd_dat[7:0]),
	.rd_err				(),			 // Templated
	.rd_gnt				(),			 // Templated
	.rd_rvld			(rd_rvld),
	.rxq_full_n			(),			 // Templated
	.wr_err				(),			 // Templated
	.wr_gnt				(rd_rgnt),		 // Templated
	.wr_rvld			(),			 // Templated
	// Inputs
	.clk				(clk),
	.rstn				(rstn),
	.uart_rx			(uart_rx),
	.rd_rgnt			(rd_rgnt),
	.rd_vld				(1'b1),			 // Templated
	.rd_wait			(1'b1),			 // Templated
	.wr_dat				(rd_dat),		 // Templated
	.wr_rgnt			(1'b1),			 // Templated
	.wr_vld				(rd_rvld),		 // Templated
	.wr_wait			(1'b1));			 // Templated

endmodule

// Local Variables:
// verilog-library-flags:("-y .")
// verilog-auto-wire-type:"logic"
// verilog-auto-declare-nettype:"logic"
// verilog-auto-inst-param-value:t
// End:

// EOF
