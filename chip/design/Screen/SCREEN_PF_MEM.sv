// Ha Minh Tran Hanh (c)

module SCREEN_PF_MEM #(parameter AW = 19)
(
  input  logic          clk,
  input  logic          rstn,

  input  logic [AW-1:0] pf_addr,
  output logic [7:0]    pf_dat,

  input  logic          vsync,
  input  logic          hsync,
  input  logic          vsync_pulse,
  input  logic          hsync_pulse,

  output logic          mem_addr_vld,
  input  logic          mem_addr_gnt,
  output logic [AW-1:0] mem_addr,
  input  logic          mem_dat_vld,
  output logic          mem_dat_gnt,
  input  logic [31:0]   mem_dat
);

reg   [31:0]     cache_data [0:3]; // always prefetch 16 bytes 
reg   [AW-2-1:0] cache_tags [0:3];
logic [3:0]      cache_vld;
logic [AW-2-1:0] pf_tag;
logic [1:0]      replaced_frame, nxt_replaced_frame;

// This internal cache is expected to be always hit
logic [7:0] hit_line_data [0:3];
logic [3:0] tag_hit;

`FF_MODULE cache_vld0_ff (`CLKRST, .d (mem_dat_vld & mem_dat_gnt & replaced_frame == 2'd0 ? 1'b1 : cache_vld [0]), .q (cache_vld  [0]));
`FF_MODULE cache_vld1_ff (`CLKRST, .d (mem_dat_vld & mem_dat_gnt & replaced_frame == 2'd1 ? 1'b1 : cache_vld [1]), .q (cache_vld  [1]));
`FF_MODULE cache_vld2_ff (`CLKRST, .d (mem_dat_vld & mem_dat_gnt & replaced_frame == 2'd2 ? 1'b1 : cache_vld [2]), .q (cache_vld  [2]));
`FF_MODULE cache_vld3_ff (`CLKRST, .d (mem_dat_vld & mem_dat_gnt & replaced_frame == 2'd3 ? 1'b1 : cache_vld [3]), .q (cache_vld  [3]));

assign pf_tag        = pf_addr [AW-1:2];
assign tag_hit       = {cache_vld [3] & (pf_tag == cache_tags[3]), cache_vld [2] & (pf_tag == cache_tags[2]),
                        cache_vld [1] & (pf_tag == cache_tags[1]), cache_vld [0] & (pf_tag == cache_tags[0])};
assign {hit_line_data [0], hit_line_data [1], hit_line_data [2], hit_line_data [3]} = {32{tag_hit [0]}} & cache_data [0]
                                                                                    | {32{tag_hit [1]}} & cache_data [1]
                                                                                    | {32{tag_hit [2]}} & cache_data [2]
                                                                                    | {32{tag_hit [3]}} & cache_data [3];

assign pf_dat = hit_line_data [pf_addr[1:0]];
// Text mode test
//assign pf_dat = pf_addr < 95 ? pf_addr + 32 : 32;

logic [AW-1:0]   next_pf_mem_addr;
logic [AW-2-1:0] next_pf_tag;
logic [3:0]      next_tag_hit;

assign next_pf_mem_addr = ( (pf_addr >> 2) + 1'b1) << 2;
assign next_pf_tag      = next_pf_mem_addr [AW-1:2];
assign next_tag_hit       = {cache_vld [3] & (next_pf_tag == cache_tags[3]), cache_vld [2] & (next_pf_tag == cache_tags[2]),
                             cache_vld [1] & (next_pf_tag == cache_tags[1]), cache_vld [0] & (next_pf_tag == cache_tags[0])};

localparam MEM_IDLE = 2'b00;
localparam MEM_READ = 2'b01;
localparam MEM_DATA = 2'b10;

logic [1:0] mem_st, nxt_mem_st;

always @(*) begin
  case (mem_st)
    MEM_IDLE: nxt_mem_st = ~(|tag_hit) | ~(|next_tag_hit) ? MEM_READ : mem_st;
    MEM_READ: nxt_mem_st =                   mem_addr_gnt ? MEM_DATA : mem_st;
    MEM_DATA: nxt_mem_st =                   mem_dat_vld  ? MEM_IDLE : mem_st;
    default : nxt_mem_st =                   MEM_IDLE;
  endcase
end

assign mem_addr_vld = mem_st [0];
assign mem_dat_gnt  = mem_st [1];

// frame (way) is selected in turn to replace with new data
assign nxt_replaced_frame [0] = mem_dat_vld & mem_dat_gnt ? ~replaced_frame [0] : replaced_frame [0];
assign nxt_replaced_frame [1] = mem_dat_vld & mem_dat_gnt & replaced_frame [0] ? ~replaced_frame [1] : replaced_frame [1];

`FF_MODULE #(.W(2))  mem_st_ff         (`CLKRST, .d(nxt_mem_st), .q(mem_st));
`FF_MODULE #(.W(AW)) mem_addr_ff       (`CLKRST, .d(mem_st == MEM_IDLE ? (~(|tag_hit) ? pf_addr : next_pf_mem_addr) : mem_addr), .q(mem_addr));
`FF_MODULE #(.W(2))  replaced_frame_ff (`CLKRST, .d(nxt_replaced_frame), .q(replaced_frame));

always @(posedge clk) begin
  if (mem_dat_vld & mem_dat_gnt) begin
    cache_data [replaced_frame] <= mem_dat;
    cache_tags [replaced_frame] <= mem_addr [AW-1:2];
  end
end


libSink sink_vsync       (.i(vsync));
libSink sink_hsync       (.i(hsync));
libSink sink_vsync_pulse (.i(vsync_pulse));
libSink sink_hsync_pulse (.i(hsync_pulse));

endmodule
//EOF
