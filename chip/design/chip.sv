module chip (
  input logic clk,
  input logic rstn,

  output logic [18:0] SRAM_Address,
  output logic        SRAM_OE_n,
  output logic        SRAM_CE_n,
  output logic [3:0]  SRAM_WE_n,
  inout  logic [31:0] SRAM_DataIO,

  output logic [7:0]  dac_bin);

logic clk33;

`ifdef SYNTHESIS
libPll33 clk_mul(.clock_in(clk), .clock_out (clk33), .locked ());
`else
assign clk33 = clk;
`endif

logic        imem_req_vld;
logic [18:0] imem_req_addr;
logic        imem_req_wr;
logic [3:0]  imem_req_dat_strb;
logic [31:0] imem_req_dat;
logic        imem_req_gnt;

logic        imem_rsp_gnt;
logic        imem_rsp_vld;
logic [31:0] imem_rsp_dat;

SCREEN ISCREEN (
  .clk  (clk33),
  .rstn (rstn),

  .mem_addr_vld (imem_req_vld),
  .mem_addr_gnt (imem_req_gnt),
  .mem_addr     (imem_req_addr [17:0]),
  .mem_dat_vld  (imem_rsp_vld),
  .mem_dat_gnt  (imem_rsp_gnt),
  .mem_dat      (imem_rsp_dat),

  .dac_bin      (dac_bin)
);

// TODO: add fabric here
assign imem_req_addr [18] = 1'b0;
assign imem_req_wr        = 1'b0;
assign imem_req_dat_strb  = 4'h0;
assign imem_req_dat       = 32'd0;

MEM #(.AW(19), .DW(8), .NUM_CHIP(4))
  IMEM (.clk (clk33), .rstn (rstn),
        .req_vld      (imem_req_vld),
        .req_addr     (imem_req_addr),
        .req_wr       (imem_req_wr),
        .req_dat_strb (imem_req_dat_strb),
        .req_dat      (imem_req_dat),
        .req_gnt      (imem_req_gnt),

        .rsp_gnt      (imem_rsp_gnt),
        .rsp_vld      (imem_rsp_vld),
        .rsp_dat      (imem_rsp_dat),

        .SRAM_Address (SRAM_Address),
        .SRAM_OE_n    (SRAM_OE_n),
        .SRAM_CE_n    (SRAM_CE_n),
        .SRAM_WE_n    (SRAM_WE_n),
        .SRAM_DataIO  (SRAM_DataIO)
);

endmodule
//EOF
