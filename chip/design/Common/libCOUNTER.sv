// Ha Minh Tran Hanh (c)
// Counter which supports counted-from value and enable
// we ce {of, dout} (next cycle)
// 0  0  {of, dout}
// 0  1  dout + 1
// 1  0  {0, din}
// 1  1  {0, din}

module libCOUNTER #(parameter DW= 16)
(
  input  logic clk,
  input  logic rstn,
  input  logic we, // write enable - to present din at next cycle
  input  logic ce, // count enable

  input  logic [DW-1:0] din,
  output logic          of,
  output logic [DW-1:0] dout
);

logic nxt_of;
logic [DW-1:0] nxt_dout;

`FF_MODULE #(.W(DW+1)) counter_ff (.clk (clk), .rstn (rstn),
                                   .d ({nxt_of, nxt_dout}),
                                   .q ({of,     dout}));

//always_comb begin
always @(*) begin
  case ({we, ce})
    2'b00: {nxt_of, nxt_dout} = {of, dout};
    2'b01: {nxt_of, nxt_dout} = dout + 1'b1;
    2'b10,
    2'b11: {nxt_of, nxt_dout} = {1'b0, din};
    default: {nxt_of, nxt_dout} = {(DW+1){1'bX}}; // debug - should be ignored when synthesis
  endcase
end

`ifdef FORMAL
  `ifndef RICHMAN
    bit f_past_valid = 1'b0;
    logic assert_en;

    always @(posedge clk) f_past_valid <= rstn;
    assign assert_en = rstn & f_past_valid & ce; 

    always @(posedge clk) begin
      if (assert_en) begin
        if ($past(we)) assert ({of, dout} == {1'b0, $past(din)});
        if ( $past(ce) & ~$past(we)) assert ({of, dout} == $past(dout) + 1'b1);
        if (~$past(ce) & ~$past(we)) assert ({of, dout} == {$past(of), $past(dout)});
      end
    end
  `else
    assert property (@(posedge clk) disable iff (~rstn) !ce &  we |=> {of, dout} == {1'b0, $past(din)});
    assert property (@(posedge clk) disable iff (~rstn)  ce & !we |=> {of, dout} == $past(dout) + 1'b1);
    assert property (@(posedge clk) disable iff (~rstn) !ce & !we |=> {of, dout} == {$past(of), $past(din)});
    assert property (@(posedge clk) disable iff (~rstn)  ce &  we |=> {of, dout} == $past(din) + 1'b1);
  `endif
`endif
endmodule
//EOF
