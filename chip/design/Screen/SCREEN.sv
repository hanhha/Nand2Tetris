// Ha Minh Tran Hanh (c)
// NTSC Processing Unit

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN #(parameter DW = 16, MEM_AW=15, REG_AW=3)
(
  input  logic clk,
  input  logic rstn,

// Access external memory for pixel information
  output logic              mem_ce,
  output logic [MEM_AW-1:0] mem_addr,
  input  logic              mem_vld,
  input  logic [DW-1:0]     mem_dat,

// To DAC
  output logic [7:0]        dac_bin
);

localparam MAX_SCREEN_ROW = 525;
localparam MAX_SCREEN_COL = 420;
localparam LOOP0_15US     = 5;

localparam MAX_PIX_ROW    = 456;
localparam MAX_PIX_COL    = 833;

logic       interlace_mode;
logic [7:0] pix_val;
logic [9:0] pf_pix_row, pf_pix_col;
logic       hsync, vsync;

SCREEN_REG #(.DW(DW), .AW(REG_AW)) IREG (.clk(clk), .rstn(rstn),
                                     .interlace_mode (interlace_mode)
                                    );

SCREEN_SCAN #(.MAX_ROW(MAX_SCREEN_ROW), .MAX_COL(MAX_SCREEN_COL), .UNIT(LOOP0_15US)) ISCAN (.clk(clk), .rstn(rstn),
                        .interlace_mode (interlace_mode),
                        .pix_val        (pix_val),
                        .hsync          (hsync),
                        .vsync          (vsync),
                        .pf_pix_row     (pf_pix_row),
                        .pf_pix_col     (pf_pix_col),
                        .dac_bin        (dac_bin)
                      );

SCREEN_MEMPIX #(.MAX_COL(MAX_PIX_COL), .MAX_ROW(MAX_PIX_ROW)) IMEMPIX (.clk(clk), .rstn(rstn),
                        .hsync      (hsync),
                        .vsync      (vsync),
                        .pf_pix_row (pf_pix_row),
                        .pf_pix_col (pf_pix_col),
                        .pix_val    (pix_val)
                      );

assign {mem_ce, mem_addr} = {1'b0, {MEM_AW{1'b0}}};

libSink #(.W(DW)) sink_mem_dat       (.i(mem_dat));
libSink           sink_mem_vld       (.i(mem_vld));

endmodule
`undef FF_MODULE
//EOF
