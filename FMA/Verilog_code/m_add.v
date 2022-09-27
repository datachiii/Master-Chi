module m_add (m_P, m_C, m_out, Cout);
    
    input [49:0] m_P, m_C;
    output [49:0] m_out;
    output Cout;

    wire [49:0] mantissa;

    assign  mantissa = m_P + m_C;
    assign Cout = mantissa[49];
    assign m_out = (mantissa[49] == 1)? ~mantissa + 1'b1 : mantissa;


endmodule