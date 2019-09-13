module GENERIC_REG #(parameter D_WIDTH = 16,
             parameter REG_NO  = 16,
             parameter A_WIDTH = 4)
(
  input  logic               clk,
  input  logic               rstn,
  input  logic               cs,
  input  logic               we,

  input  logic [A_WIDTH-1:0] addr,
  input  logic [D_WIDTH-1:0] din,

  output logic [D_WIDTH-1:0] dout
);

logic [D_WIDTH-1:0] regmem [0:REG_NO-1];
integer i;

always_ff @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    for ( i = 0; i < REG_NO; i++ ) begin
      regmem [i] <= {D_WIDTH{1'b0}};
    end
  end else begin
    if (cs) begin
      if (we) regmem [addr] <= din;
      dout <= we ? din : regmem [addr];
    end
  end
end

`ifdef FORMAL
  // Poor man's implementation
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;

    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid; 

    always @(posedge clk) begin
      if (assert_en) begin
        if ($past(cs) && !$past(we)) assert (dout == regmem [$past(addr)]);
        if ($past(cs) && $past(we)) assert (dout == $past(din));
      end
    end
  `else
    assert property ( @(posedge clk) disable iff (~rstn) cs & !we |=> dout == regmem [$past(addr)]); 
    assert property ( @(posedge clk) disable iff (~rstn) cs & we |=> dout == $past(din)); 
  `endif
`endif

endmodule
