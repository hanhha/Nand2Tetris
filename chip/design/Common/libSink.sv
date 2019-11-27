module libSink #(parameter W = 1)
(
  input logic [W-1:0] i
);

/* verilator lint_off UNUSED */
  logic [W-1:0] sink;
  assign sink = i;
/* verilator lint_on UNUSED*/

endmodule
