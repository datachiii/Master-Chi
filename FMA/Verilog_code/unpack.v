module unpack (data_A, data_B, data_C, sign_A, sign_B, sign_C, exp_A, exp_B, exp_C, m_A, m_B, m_C);
    
//parameter N = 32;
input [31:0] data_A, data_B, data_C;
output sign_A, sign_B, sign_C;
output [7:0] exp_A, exp_B, exp_C;
output [24:0] m_A, m_B;
output [49:0] m_C;


assign sign_A = data_A[31];
assign sign_B = data_B[31];
assign sign_C = data_C[31];
assign exp_A = data_A[30:23];
assign exp_B = data_B[30:23];
assign exp_C = data_C[30:23];
assign m_A = {2'b01, data_A[22:0]};  //Q2.23
assign m_B = {2'b01, data_B[22:0]};

assign m_C = {4'b0001, data_C[22:0], 23'b0};   //Q4.46


endmodule