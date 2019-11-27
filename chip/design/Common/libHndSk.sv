// Ha Minh Tran Hanh (c)

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module libHndSk #(parameter D_WIDTH = 16)
(
  input  logic clk,
  input  logic rstn,

  input  logic vldi,
  input  logic rdyo,
  input  logic [D_WIDTH-1:0] datai,

  output logic vldo,
  output logic rdyi,
  output logic [D_WIDTH-1:0] datao
);

  localparam IDLE = 1'b1;
  localparam BUSY = 1'b0;

  logic state, nxt_state;
  logic nxt_vldo;
  logic [D_WIDTH-1:0] nxt_datao;

  assign nxt_state = !rdyo ? BUSY  : IDLE;
  assign nxt_vldo  = !rdyo ? 1'b1  : vldi;
  assign nxt_datao = !rdyo ? datao : datai;

  `FF_MODULE #(.W(1), .I(1'b1)) state_ff (.d(nxt_state), .q(state), .clk(clk), .rstn(rstn));
  `FF_MODULE #(.W(1))           vldo_ff  (.d(nxt_vldo),  .q(vldo),  .clk(clk), .rstn(rstn));
  `FF_MODULE #(.W(D_WIDTH))     datao_ff (.d(nxt_datao), .q(datao), .clk(clk), .rstn(rstn));

  assign rdyi = state;

endmodule
`undef FF_MODULE
//EOF
