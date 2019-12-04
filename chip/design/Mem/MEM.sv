// Ha Minh Tran Hanh (c)
// Simple SRAM memory controller
// No optimization for latencies, etc ...
// The SRAM latency is 55ns while the clk is 33MHz so that it needs to wait

module MEM #(parameter AW = 21, DW = 8, NUM_CHIP = 4)
(
  input logic clk,
  input logic rstn,

  input  logic                     req_vld,
  input  logic [AW-1:0]            req_addr,
  input  logic                     req_wr,
  input  logic [NUM_CHIP-1:0]      req_dat_strb,
  input  logic [DW*NUM_CHIP - 1:0] req_dat,
  output logic                     req_gnt,

  input  logic                     rsp_gnt,
  output logic                     rsp_vld,
  output logic [DW*NUM_CHIP - 1:0] rsp_dat,

  output logic [AW-$clog2(NUM_CHIP)-1:0] SRAM_Address,
  output logic                           SRAM_OE_n,
  output logic                           SRAM_CE_n,
  output logic [NUM_CHIP-1:0]            SRAM_WE_n,
  inout  logic [DW*NUM_CHIP - 1:0]       SRAM_DataIO
);

localparam SRAM_CHP_AW = $clog2(NUM_CHIP);
localparam SRAM_AW     = AW - SRAM_CHP_AW;

localparam MEM_IDLE = 3'b000;
localparam MEM_RDY  = 3'b011;
localparam MEM_WAIT = 3'b010;
localparam MEM_RSP  = 3'b100;

logic [2:0]             cur_st, nxt_st;
logic [DW*NUM_CHIP-1:0] SRAM_DataO, l_SRAM_DataO;
logic [NUM_CHIP-1:0]    wr_strb, l_wr_strb;
logic                   wr_req, l_wr_req;
logic [SRAM_AW-1:0]     l_SRAM_Address;

assign SRAM_DataIO = ~(|SRAM_WE_n) ? SRAM_DataO : {(DW*NUM_CHIP){1'bz}};

always @(*) begin
  case (cur_st)
    MEM_IDLE : nxt_st = req_vld ? MEM_RDY  : cur_st;
    MEM_RDY  : nxt_st = req_vld ? MEM_WAIT : cur_st;
    MEM_WAIT : nxt_st = MEM_RSP;
    MEM_RSP  : nxt_st = rsp_gnt ? MEM_RDY : cur_st;
    default  : nxt_st = MEM_IDLE;
  endcase
end

`FF_MODULE #(.W(3)) cur_st_ff (`CLKRST, .d (nxt_st), .q(cur_st));

assign req_gnt   =  cur_st [0];
assign rsp_vld   =  cur_st [2];
assign SRAM_CE_n = ~cur_st [1];
assign SRAM_OE_n =  cur_st [1] & wr_req;
assign SRAM_WE_n = ~{{NUM_CHIP{cur_st [1] & wr_req}} & wr_strb};

`FF_MODULE #(.W(SRAM_AW))     ADDR_ff (`CLKRST, .d (SRAM_Address),  .q (l_SRAM_Address));
`FF_MODULE #(.W(DW*NUM_CHIP)) DATA_ff (`CLKRST, .d (SRAM_DataO),    .q (l_SRAM_DataO));
`FF_MODULE #(.W(NUM_CHIP))    wstb_ff (`CLKRST, .d (wr_strb),       .q (l_wr_strb));
`FF_MODULE                    wreq_ff (`CLKRST, .d (wr_req),        .q (l_wr_req));

`FF_MODULE #(.W(DW*NUM_CHIP)) data_ff (`CLKRST, .d (cur_st != MEM_RSP && nxt_st == MEM_RSP ? SRAM_DataIO : rsp_dat), .q (rsp_dat));

assign SRAM_Address = req_vld & req_gnt ? req_addr [AW-1:SRAM_CHP_AW] : l_SRAM_Address;
assign SRAM_DataO   = req_vld & req_gnt ? req_dat : l_SRAM_DataO;
assign wr_strb      = req_vld & req_gnt ? req_dat_strb : l_wr_strb;
assign wr_req       = req_vld & req_gnt ? req_wr : l_wr_req;

libSink #(2) sink_addr (.i(req_addr[1:0]));

endmodule
// EOF
