package CpuPkg;

  typedef struct packed {
    logic [16:0] pc;
    // Sources or Destination
    // [1:0] = {Internal (D,A,PC), External (M)}
    // X or Y sources
    // [4:0] = {imm, A, D, M, PC}
    logic [1:0]  src;
    logic [1:0]  dst;
    logic [1:0]  x_src;      // {imm, D}
    logic [1:0]  y_src;      // {M, A}
    logic [2:0]  o_dst;      // {A, M, D}
    logic [1:0]  x_op, y_op; // {zero-ize, negate}
    logic [1:0]  o_op;       // {add/and, negate} - 2'b00 == AND only
    logic [14:0] imm;
    logic [2:0]  jcond;
    logic        err;
  } decode_st;

  typedef struct packed {
    logic [15:0] pc;
    logic [15:0] inst;
  } fetch_st;

  typedef struct packed {
    logic cs;
    logic wr;
    logic [15:0] adr;
    logic [15:0] wdat;
    logic [1:0]  wstrb;
  } mem_req_st;

  typedef struct packed {
    logic rdy;
    logic [15:0] rdat;
    logic err;
  } mem_rsp_st;

endpackage
// EOF
