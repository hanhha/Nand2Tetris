// HMTH (c)

module libDummy #(parameter AW = 24, DW = 16, DMMY_AW = 2) (
  input  logic clk,
  input  logic rstn,

  input  logic              req_vld,
  output logic              req_gnt,
  input  logic              req_wr,
  input  logic [(DW/8)-1:0] req_strb,
  input  logic [AW-1:0]     req_adr,
  input  logic [DW-1:0]     req_dat,

  output logic              rsp_vld,
  input  logic              rsp_gnt,
  output logic [DW-1:0]     rsp_dat
);

logic [DW-1:0] mem [0:$clog2(DMMY_AW)-1];
logic state;

logic [DMMY_AW-1:0] cur_adr;

assign rsp_dat = mem [cur_adr];

`ifndef SELECT_SRSTn
always @(posedge clk, negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (~rstn) begin
    state   <= 1'b0;

    req_gnt <= 1'b1;
    rsp_vld <= 1'b0;

    cur_adr <= {DMMY_AW{1'b0}};
  end else begin
    state <= req_vld & req_gnt ? 1'b1 : state;

    case (state)
      1'b0 : begin
              req_gnt  <= req_vld ? 1'b0 : req_gnt;
              rsp_vld  <= req_vld ? 1'b1 : rsp_vld;
                
              cur_adr <= req_vld ? req_adr [DMMY_AW-1:0] : cur_adr; 
             end
      1'b1 : begin
              req_gnt <= rsp_gnt ? 1'b1 : req_gnt;
              rsp_vld <= rsp_gnt ? 1'b0 : rsp_vld;
             end
    endcase
  end
end

integer i;
always @(posedge clk)
  if (req_vld & req_gnt & req_wr)
    for (i = 0; i < DW/8; i++) begin
      if (req_strb [i])
        mem [req_adr[DMMY_AW-1:0]][(i*8)+:8] <= req_dat [(i*8)+:8];  
    end

endmodule
//EOF
