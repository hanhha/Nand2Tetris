// Ha Minh Tran Hanh (c)
// NTSC Processing Unit

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN #(parameter DW = 16, MEM_AW=19, REG_AW=3, EXT_MEM_AW=1)
(
  input  logic clk,
  input  logic rstn,

// Access external memory for pixel information
  output logic                         mem_addr_vld,
  input  logic                         mem_addr_gnt,
  output logic [MEM_AW+EXT_MEM_AW-1:0] mem_addr,
  input  logic                         mem_dat_vld,
  output logic                         mem_dat_gnt,
  input  logic [DW-1:0]                mem_dat,

// To DAC
  output logic [7:0]        dac_bin
);

localparam MAX_SCREEN_ROW = 525;
localparam MAX_SCREEN_COL = 420;
localparam LOOP0_15US     = 5;

localparam MAX_PIX_ROW    = 456;
localparam MAX_PIX_COL    = 833;

logic                  interlace_mode;
logic [EXT_MEM_AW-1:0] mem_base;
logic                  text_mode_en;

SCREEN_REG #(.DW(DW), .AW(REG_AW))
      IREG (.clk(clk), .rstn(rstn),
            .interlace_mode (interlace_mode),
            .text_mode_en   (text_mode_en),
            .mem_base       (mem_base)
           );

logic [7:0]        pix_val;
logic [9:0]        pf_pix_row, pf_pix_col;
logic              hsync, vsync;

SCREEN_SCAN #(.MAX_ROW(MAX_SCREEN_ROW), .MAX_COL(MAX_SCREEN_COL),
              .UNIT(LOOP0_15US))
      ISCAN (.clk(clk), .rstn(rstn),
             .interlace_mode (interlace_mode),
             .pix_val        (pix_val),
             .hsync          (hsync),
             .vsync          (vsync),
             .pf_pix_row     (pf_pix_row),
             .pf_pix_col     (pf_pix_col),
             .dac_bin        (dac_bin)
            );

logic [MEM_AW-1:0]     mem_lcl_addr;

SCREEN_MEMPIX #(.MAX_COL(MAX_PIX_COL), .MAX_ROW(MAX_PIX_ROW),
                .AW(MEM_AW), .DW(DW))
      IMEMPIX (.clk(clk), .rstn(rstn),
               .hsync        (hsync),
               .vsync        (vsync),
               .pf_pix_row   (pf_pix_row),
               .pf_pix_col   (pf_pix_col),
               .text_mode_en (text_mode_en),
               .mem_addr_vld (mem_addr_vld),
               .mem_addr_gnt (mem_addr_gnt),
               .mem_addr     (mem_lcl_addr),
               .mem_dat_vld  (mem_dat_vld),
               .mem_dat_gnt  (mem_dat_gnt),
               .mem_dat      (mem_dat),
               .pix_val      (pix_val)
              );

assign mem_addr = {mem_base, mem_lcl_addr};

endmodule
`undef FF_MODULE
//EOF
