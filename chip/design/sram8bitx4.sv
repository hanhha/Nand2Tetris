// Ha Minh Tran Hanh (c)
// Mimic 4 chips of SRAM 512Kx8b

module sram8bitx4 (
  input logic [18:0] SRAM_Address,
  input logic        SRAM_OE_n,
  input logic        SRAM_CE_n,
  input logic [3:0]  SRAM_WE_n,
  inout logic [31:0] SRAM_DataIO
);
reg [7:0] mem [0:127];

initial $readmemh("ascii_show.txt", mem);

assign SRAM_DataIO = ~(|SRAM_WE_n) ? 32'bz : {SRAM_Address, 2'b00} < 19'd128 ? {mem[{SRAM_Address[4:0], 2'b00}],
                                                                                mem[{SRAM_Address[4:0], 2'b01}],
                                                                                mem[{SRAM_Address[4:0], 2'b10}],
                                                                                mem[{SRAM_Address[4:0], 2'b11}]}
                                                                             : 32'h20202020;

libSink sink_OE (.i(SRAM_OE_n));
libSink sink_CE (.i(SRAM_CE_n));
libSink #(14) sink_addr (.i(SRAM_Address[18:5]));

endmodule
//EOF
