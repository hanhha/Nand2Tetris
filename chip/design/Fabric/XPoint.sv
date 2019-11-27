module XPoint #(parameter DW=9) (
    input  logic  X_EN

  , input  logic [DW-1 : 0] I0
  , input  logic [DW-1 : 0] I1

  , output logic [DW-1 : 0] O0
  , output logic [DW-1 : 0] O1
);

  assign O0 = X_EN ? I1 : I0;
  assign O1 = X_EN ? I0 : I1;

endmodule
