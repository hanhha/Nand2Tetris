module XMatrixReqCtrl (
  input  logic [2:0] ReqVec,
  input  logic [2:0] RcvVec,
  input  logic [2:0] RcvRdyVec,

  output logic [2:0] ReqGntVec,
  output logic [1:0] X_EN
);

localparam [1:0][3:0] X_EN_CAND = {2'b00, 2'b01, 2'b10, 2'b11};

logic [2:0][3:0] RcvVecSmpl;
logic [3:0] RcvVecSmplVld;

XMatrixReq #(.DW(1)) XMatrixReqSmpl0 (.X_EN(X_EN_CAND[0]), .T0(ReqVec[0]), .T1(ReqVec[1]), .T2(ReqVec[2]), .S0(RcvVecSmpl[0][0]), .S1(RcvVecSmpl[0][1]), .S2(RcvVecSmpl[0][2]));
XMatrixReq #(.DW(1)) XMatrixReqSmpl1 (.X_EN(X_EN_CAND[1]), .T0(ReqVec[0]), .T1(ReqVec[1]), .T2(ReqVec[2]), .S0(RcvVecSmpl[1][0]), .S1(RcvVecSmpl[1][1]), .S2(RcvVecSmpl[1][2]));
XMatrixReq #(.DW(1)) XMatrixReqSmpl2 (.X_EN(X_EN_CAND[2]), .T0(ReqVec[0]), .T1(ReqVec[1]), .T2(ReqVec[2]), .S0(RcvVecSmpl[2][0]), .S1(RcvVecSmpl[2][1]), .S2(RcvVecSmpl[2][2]));
XMatrixReq #(.DW(1)) XMatrixReqSmpl3 (.X_EN(X_EN_CAND[3]), .T0(ReqVec[0]), .T1(ReqVec[1]), .T2(ReqVec[2]), .S0(RcvVecSmpl[3][0]), .S1(RcvVecSmpl[3][1]), .S2(RcvVecSmpl[3][2]));

assign RcvVecSmplVld [0] = RcvVecSmpl [0] == RcvVec;
assign RcvVecSmplVld [1] = RcvVecSmpl [1] == RcvVec;
assign RcvVecSmplVld [2] = RcvVecSmpl [2] == RcvVec;
assign RcvVecSmplVld [3] = RcvVecSmpl [3] == RcvVec;

always @(*) begin
  X_EN = 2'b00;
  if (|RcvVecSmplVld)
    for (int i = 0; i < 3; i++0 
      X_EN |= {2'b00, 
               , {3{RcvVecSmplVld[0]}} & X_EN_CAND[0]
               , {3{RcvVecSmplVld[1]}} & X_EN_CAND[1]
               , {3{RcvVecSmplVld[2]}} & X_EN_CAND[2]
               , {3{RcvVecSmplVld[3]}} & X_EN_CAND[3]
              };
  else if (|RcvVecSmpl[0])
    X_EN = X_EN_CAND [0];
  else if (|RcvVecSmpl[1])
    X_EN = X_EN_CAND [1];
  else if (|RcvVecSmpl[0])
    X_EN = X_EN_CAND [0];
  else if (|RcvVecSmpl[0])
    X_EN = X_EN_CAND [0];
      
end

endmodule

module XMatrixReq #(parameter DW = 9) (
    input logic [1 : 0]    X_EN

  , input  logic [DW-1 : 0] T0
  , input  logic [DW-1 : 0] T1
  , input  logic [DW-1 : 0] T2

  , output logic [DW-1 : 0] S0
  , output logic [DW-1 : 0] S1
  , output logic [DW-1 : 0] S2
);

logic [DW-1 : 0] C_0_1;

// = XPoint =
//     I1
//  I0 + O0
//     O1
// ==========

// = XMatrix =
//    T1 T2
// T0  0  1 S0
//    S2 S1
// ===========

XPoint #(DW) XP0 (.X_EN (X_EN[0]), .I0 (T0),    .I1 (T1), .O0 (C_0_1), .O1 (S2));
XPoint #(DW) XP1 (.X_EN (X_EN[1]), .I0 (C_0_1), .I1 (T2), .O0 (S0),    .O1 (S3));

endmodule
//EOF
