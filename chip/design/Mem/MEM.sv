// Ha Minh Tran Hanh (c)
// Simple SRAM memory controller
// No optimization for latencies, etc ...
// The SRAM latency is 55ns while the clk is 33MHz so that it needs to wait

module MEM #(parameter AW = 19, DW = 8, NUM_CHIP = 4)
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

  output logic [AW-1:0]            SRAM_Address,
  output logic                     SRAM_OE_n,
  output logic                     SRAM_CE_n,
  output logic [NUM_CHIP-1:0]      SRAM_WE_n,
  inout  logic [DW*NUM_CHIP - 1:0] SRAM_DataIO
);

localparam MEM_IDLE = 3'b000;
localparam MEM_RDY  = 3'b011;
localparam MEM_WAIT = 3'b010;
localparam MEM_RSP  = 3'b100;

logic [DW*NUM_CHIP-1:0] SRAM_DataO;
logic [2:0]             cur_st, nxt_st;
logic [NUM_CHIP-1:0]    wr_strb;
logic                   wr_req;

assign SRAM_DataIO = ~(|SRAM_WE_n) ? SRAM_DataO : {(DW*NUM_CHIP){1'bz}};

always @(*) begin
  case (cur_st)
    MEM_IDLE : nxt_st = req_vld ? MEM_RDY : cur_st;
    MEM_RDY  : nxt_st = MEM_WAIT;
    MEM_WAIT : nxt_st = MEM_RSP;
    MEM_RSP  : nxt_st = rsp_gnt ? (req_vld ? MEM_RDY : MEM_IDLE) : cur_st;
    default  : nxt_st = MEM_IDLE;
  endcase
end

assign req_gnt   =  cur_st [0];
assign rsp_vld   =  cur_st [2];
assign SRAM_CE_n = ~cur_st [1];
assign SRAM_OE_n =  cur_st [1] & wr_req;
assign SRAM_WE_n = ~{{NUM_CHIP{cur_st [1] & wr_req}} & wr_strb};

`FF_MODULE #(.W(AW))          ADDR_ff (`CLKRST, .d (cur_st != MEM_RDY && nxt_st == MEM_RDY ? req_addr : SRAM_Address),  .q (SRAM_Address));
`FF_MODULE #(.W(DW*NUM_CHIP)) DATA_ff (`CLKRST, .d (cur_st != MEM_RDY && nxt_st == MEM_RDY ? req_dat : SRAM_DataO),     .q (SRAM_DataO));
`FF_MODULE #(.W(DW*NUM_CHIP)) data_ff (`CLKRST, .d (cur_st != MEM_RSP && nxt_st == MEM_RSP ? SRAM_DataIO : rsp_dat),    .q (rsp_dat));
`FF_MODULE #(.W(NUM_CHIP))    wstb_ff (`CLKRST, .d (cur_st != MEM_RDY && nxt_st == MEM_RDY ? req_dat_strb : wr_strb), .q (wr_strb));
`FF_MODULE                    wreq_ff (`CLKRST, .d (cur_st != MEM_RDY && nxt_st == MEM_RDY ? req_wr : wr_req),          .q (wr_req));

endmodule
// EOF
