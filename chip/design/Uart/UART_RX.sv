// HMTH (c)
// Simple UART

module UART_RX #(parameter CLK_PER_BAUD = 8, TW = 10)
(
  input logic clk,
  input logic rstn,

  output logic       vld,
  output logic [7:0] dat,

// To UART pin
  input  logic       uart_rx
);

//FIXME: implement if needed
assign vld = 1'b0;
assign dat = 8'd0;

`ifndef SYNTHESIS
  // Poor man's mplementation
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;
  			
    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid; 
    
    // TODO: add assertions to prove design here
  `endif
`endif

endmodule
// EOF
