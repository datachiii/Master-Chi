module Top (A, B, C, D);

    input [31:0] A, B, C;
    output [31:0] D;

    wire sign_A, sign_B, sign_C, sign_P, Cout, LOD_en, round_exp, sign_out;
    wire [7:0] exp_A, exp_B, exp_C, exp_P, mux_out, sub_out,exp_out;
    wire [24:0] m_A, m_B;
    wire [49:0] m_C, m_P, sel_C, sel_P, ali_C, ali_P, add_out;
    wire [1:0] sub_en, two_en;
    wire [26:0] norm_out;
    wire [5:0] zero_cnt;
    wire [22:0] m_out;




    unpack unpack (.data_A(A), .data_B(B), .data_C(C), .sign_A(sign_A), .sign_B(sign_B), .sign_C(sign_C), .exp_A(exp_A), .exp_B(exp_B), .exp_C(exp_C), .m_A(m_A), .m_B(m_B), .m_C(m_C));
    xor1 xor1 (.sign_A(sign_A), .sign_B(sign_B), .sign_P(sign_P));
    exp_add expadd (.exp_A(exp_A), .exp_B(exp_B), .exp_P(exp_P));
    multiply mul (.m_A(m_A), .m_B(m_B), .m_P(m_P));
    sub sub (.exp_P(exp_P), .exp_C(exp_C), .sub_out(sub_out), .sub_en(sub_en));
    mux mux (.exp_P(exp_P), .exp_C(exp_C), .sub_en(sub_en), .exp_out(mux_out));
    Two two (.sign_P(sign_P), .sign_C(sign_C), .two_en(two_en));
    complement selc (.in_P(m_P), .in_C(m_C), .out_P(sel_P), .out_C(sel_C), .two_en(two_en));
    alignment align (.m_P_in(sel_P), .m_C_in(sel_C), .m_P_out(ali_P), .m_C_out(ali_C), .sub_out(sub_out), .sub_en(sub_en));
    m_add sigadd (.m_P(ali_P), .m_C(ali_C), .m_out(add_out), .Cout(Cout));
    normalize normal (.m_in(add_out), .m_out(norm_out), .zero_cnt(zero_cnt), .en_out(LOD_en));
    rounding round (.m_in(norm_out), .m_out(m_out), .exp(round_exp));
    controller ctrl (.Cout(Cout), .adjust_exp1(zero_cnt), .adjust_exp2(round_exp), .en(LOD_en), .sign_out(sign_out), .exp_out(exp_out), .sub_en(sub_en), .exp_in(mux_out));

    assign D = {sign_out, exp_out, m_out};



endmodule