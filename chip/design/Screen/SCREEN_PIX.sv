// Ha Minh Tran Hanh (c)

module SCREEN_PIX #(parameter MAX_COL = 833, MAX_ROW = 454,
                                 AW = 19)
(
  input  logic          clk,
  input  logic          rstn,

  input  logic [9:0]    pf_pix_row,
  input  logic [9:0]    pf_pix_col,

  input  logic          text_mode_en,
  input  logic          bw_mode_en,

  output logic [AW-1:0] pf_addr,
  input  logic [7:0]    pf_dat,

  output logic [7:0]    pix_val
);

localparam BLACK_LVL  = 8'd50;
localparam WHITE_LVL  = 8'd255;

// The char on screen was too small so that 4 square pixels are used for 1 pixel in font
// = 28 rows x 52 cols 
localparam TEXT_ROWS = 28;
localparam TEXT_COLS = 52;
localparam MAX_CHARS = TEXT_ROWS * TEXT_COLS;

logic  [5:0] text_col;
logic  [4:0] text_row;
logic [10:0] pf_textmem_loc;

logic [2:0] pf_chr_row, pf_chr_col;
logic text_pix_on, grph_pix_on;

SCREEN_CHAR_ROM CHAR_ROM (`CLKRST,
                          .chr_code (pf_dat),
                          .row      (pf_chr_row),
                          .col      (pf_chr_col),
                          .pix_on   (text_pix_on)
                        );

assign pf_chr_row = pf_pix_row [3:1];
assign pf_chr_col = pf_pix_col [3:1];

assign text_row       = pf_pix_row [8:4]; // Bit [9] should always be 0
assign text_col       = pf_pix_col [9:4];
/* verilator lint_off WIDTH */
assign pf_textmem_loc = text_row * 52 + text_col;
/* verilator lint_on WIDTH */

// Graphic mode
libSink sink_col (.i(pf_pix_col[0])); // TODO
libSink #(2) sink_row (.i({pf_pix_row[9], pf_pix_row[0]})); // TODO

assign grph_pix_on = 1'b0;

assign pf_addr = text_mode_en ? {{(AW-11){1'b0}}, pf_textmem_loc}
                              : bw_mode_en ? 0   // TODO
                                           : 0 ; // TODO
assign pix_val     = text_mode_en ? (text_pix_on ? WHITE_LVL : BLACK_LVL)
                                  : bw_mode_en ? (grph_pix_on ? WHITE_LVL : BLACK_LVL)
                                               : pf_dat;

endmodule
//EOF
