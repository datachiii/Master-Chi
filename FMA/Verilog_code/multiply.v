module multiply (m_A, m_B, m_P);

    input [24:0] m_A, m_B;
    output [49:0] m_P;

    assign m_P = m_A * m_B;

endmodule