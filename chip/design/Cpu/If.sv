// HMTH (c)
// Instruction fetch 

module If
  import CpuPkg::*;
(
  input logic clk,
  input logic rstn,

  input  logic [15:0] pc,
  input  logic        reload, // pulse signal
  
  output fetch_st  fetched_info,
  output logic     fetched_vld,
  input  logic     fetched_gnt,

  output mem_req_st   mem_req,
  output logic [15:0] fpc,
  input  mem_rsp_st   mem_rsp
);

  localparam IDLE = 2'b00;
  localparam KEEP = 2'b10;
  localparam NEXT = 2'b11;

  logic [1:0]  mem_st;
  logic        store_st, out_st; // 0 - IDLE ; 1 - KEEP

  logic [15:0] pfpc;

  fetch_st fetched_reg, store_info;

  assign mem_req.cs    = reload || store_st || (mem_st == NEXT && out_st) ? 1'b0 : 1'b1;
  assign mem_req.wr    = 1'b0;
  assign mem_req.wdat  = '0;
  assign mem_req.wstrb = '0;
  assign mem_req.adr   = pfpc;

  always_ff @(posedge clk) begin
    if (~rstn) begin
      mem_st <= IDLE;
      pfpc   <= '0;
    end else begin
      if (mem_req.cs) begin
        mem_st <= mem_rsp.rdy ? NEXT : KEEP;
        pfpc   <= mem_rsp.rdy ? (reload ? pc : pfpc + 2'd2) : pfpc;
      end else begin
        mem_st <= IDLE;
        pfpc   <= reload ? pc : pfpc + 2'd2;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (~rstn) fpc <= '0;
    end else fpc <= mem_req.cs & mem_rsp.rdy ? mem_req.adr : fpc;
  end

  // There must be no situation in that mem_st == NEXT while store_st == 1'b1
  always_ff @(posedge clk) begin
    if (~rstn) begin
      store_st   <= 1'b0;
      store_info <= '0;
    end else begin
      if (reload) store_st = 1'b0;
      else begin
        if (out_st == 1'b0) begin
          if (store_st == 1'b1) store_st <= 1'b0;
        end else begin
          if (mem_st == NEXT) begin
            store_st   <= 1'b1;
            store_info <= {fpc, mem_rsp.rdat};
          end
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (~rstn) begin
      out_st      <= 1'b0;
      fetched_reg <= '0;
    end else begin
      if (reload) out_st <= 1'b0;
      else begin
        if (fetched_vld) out_st <= fetched_gnt ? 1'b0 : 1'b1;
        else out_st <= 1'b0;
        if (fetched_vld & ~fetched_gnt) fetched_reg <= fetched_info;
      end
    end
  end

  assign fetched_vld = out_st == 1'b1 ? 1'b1
                                      : (store_st == 1'b1 ? 1'b1
                                                          : (mem_st == NEXT ? ~reload : 1'b0));
  assign fetched_info = out_st == 1'b1 ? fetched_reg 
                                       : (store_st == 1'b1 ? store_info
                                                           : (mem_st == NEXT ? {fpc, mem_rsp.rdat}));

endmodule
// EOF
