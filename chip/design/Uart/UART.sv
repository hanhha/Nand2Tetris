// HMTH (c)
// Simple handshake protocol to UART

module UART #(parameter CLK_PER_BAUD = 8, TW = 10, DEPTH = 4) (
  input logic clk,
  input logic rstn,

  input  logic uart_rx,
  output logic uart_tx,

  /*AUTOINPUT*/
  // Beginning of automatic inputs (from unused autoinst inputs)
  input logic		rd_rgnt,		// To QIf of QIf.v
  input logic		rd_vld,			// To QIf of QIf.v
  input logic		rd_wait,		// To QIf of QIf.v
  input logic [7:0]	wr_dat,			// To QIf of QIf.v
  input logic		wr_rgnt,		// To QIf of QIf.v
  input logic		wr_vld,			// To QIf of QIf.v
  input logic		wr_wait,		// To QIf of QIf.v
  // End of automatics

  /*AUTOOUTPUT*/
  // Beginning of automatic outputs (from unused autoinst outputs)
  output logic [7:0]	rd_dat,			// From QIf of QIf.v
  output logic		rd_err,			// From QIf of QIf.v
  output logic		rd_gnt,			// From QIf of QIf.v
  output logic		rd_rvld,		// From QIf of QIf.v
  output logic		rxq_full_n,		// From QIf of QIf.v
  output logic		wr_err,			// From QIf of QIf.v
  output logic		wr_gnt,			// From QIf of QIf.v
  output logic		wr_rvld		// From QIf of QIf.v
  // End of automatics

  /*AUTOINOUT*/
);

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [7:0]		rxq_dat;		// From RX of UART_RX.v
  logic			rxq_we;			// From RX of UART_RX.v
  logic [7:0]		txq_dat;		// From QIf of QIf.v
  logic			txq_empty_n;		// From QIf of QIf.v
  logic			txq_re;			// From TX of UART_TX.v
  // End of automatics

/* UART_RX AUTO_TEMPLATE (
  .vld (rxq_we),
  .dat (rxq_dat[]),
); */
UART_RX #(.CLK_PER_BAUD (CLK_PER_BAUD), .TW (TW))
  RX (/*AUTOINST*/
      // Outputs
      .vld				(rxq_we),		 // Templated
      .dat				(rxq_dat[7:0]),		 // Templated
      // Inputs
      .clk				(clk),
      .rstn				(rstn),
      .uart_rx				(uart_rx));

/* UART_TX AUTO_TEMPLATE (
  .vld (txq_empty_n),
  .gnt (txq_re),
  .dat (txq_dat),
); */
UART_TX #(.CLK_PER_BAUD (CLK_PER_BAUD), .TW (TW))
  TX (/*AUTOINST*/
      // Outputs
      .gnt				(txq_re),		 // Templated
      .uart_tx				(uart_tx),
      // Inputs
      .clk				(clk),
      .rstn				(rstn),
      .vld				(txq_empty_n),		 // Templated
      .dat				(txq_dat));		 // Templated

QIf #(.DW (8), .TX_DEPTH (DEPTH), .RX_DEPTH (DEPTH))
  QIf (/*AUTOINST*/
       // Outputs
       .wr_gnt				(wr_gnt),
       .wr_err				(wr_err),
       .wr_rvld				(wr_rvld),
       .rd_gnt				(rd_gnt),
       .rd_dat				(rd_dat[7:0]),
       .rd_err				(rd_err),
       .rd_rvld				(rd_rvld),
       .txq_empty_n			(txq_empty_n),
       .txq_dat				(txq_dat[7:0]),
       .rxq_full_n			(rxq_full_n),
       // Inputs
       .clk				(clk),
       .rstn				(rstn),
       .wr_vld				(wr_vld),
       .wr_wait				(wr_wait),
       .wr_dat				(wr_dat[7:0]),
       .wr_rgnt				(wr_rgnt),
       .rd_vld				(rd_vld),
       .rd_wait				(rd_wait),
       .rd_rgnt				(rd_rgnt),
       .txq_re				(txq_re),
       .rxq_we				(rxq_we),
       .rxq_dat				(rxq_dat[7:0]));

endmodule

// Local Variables:
// verilog-library-flags:("-y . -v ../QIf/QIf.sv")
// verilog-auto-wire-type:"logic"
// verilog-auto-declare-nettype:"logic"
// verilog-auto-inst-param-value:t
// End:

// EOF
