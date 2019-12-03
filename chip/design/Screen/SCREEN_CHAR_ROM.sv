// Ha Minh Tran Hanh (c)
// 8x8 font

`ifndef SELECT_SRSTn
  `define FF_MODULE libARstnFF
`else
  `define FF_MODULE libSRstnFF
`endif

module SCREEN_CHAR_ROM (
  input  clk,
  input  rstn,

  input  logic [7:0] chr_code, // from 32 to 126
  input  logic [2:0] row,
  input  logic [2:0] col,

  output logic       pix_on
);

logic       valid;
logic [6:0] font_addr;
logic [9:0] font_addr_full;
reg   [7:0] font_rom [0:759];
logic [0:7] row_val;

initial begin
  $readmemb ("font.txt", font_rom);
end

assign valid     = ~chr_code [7] & (chr_code [6:5] != 2'b00);
assign font_addr = {chr_code [6] & chr_code [5], chr_code [6] & ~chr_code [5], chr_code [4:0]};

assign row_val = font_rom [font_addr_full];

`FF_MODULE #(.W(10)) font_ff (.clk (clk), .rstn (rstn), .d (valid ? {font_addr, row} : 10'd0), .q (font_addr_full));

assign pix_on = row_val [col];

endmodule
`undef FF_MODULE
//EOF
