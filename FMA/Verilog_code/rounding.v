module rounding (m_in, m_out, exp);

    input [26:0] m_in;
    output [22:0] m_out;
    output exp;

    wire [24:0] tst;
    wire even;

    assign even = m_in[3];
    assign tst = (m_in[2:0] > 3'b100)? {1'b0, m_in[26:3]} + 1'b1 : (m_in[2:0] < 3'b100)? {1'b0, m_in[26:3]} : (m_in[2:0] == 3'b100 && even == 1'b1)? {1'b0, m_in[26:3]} + 1'b1 : {1'b0, m_in[26:3]};
    assign m_out = (tst[24])? tst[23:1] : tst[22:0];
    assign exp = (tst[24])? 1 : 0;

endmodule