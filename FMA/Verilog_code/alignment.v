module alignment (m_P_in, m_C_in, m_P_out, m_C_out, sub_out, sub_en);

    input signed [49:0] m_P_in, m_C_in;
    input [7:0] sub_out;
    input [1:0] sub_en; 
    output [49:0] m_P_out, m_C_out;

    assign m_P_out = (sub_en == 2'b00)? m_P_in : (sub_en == 2'b01)? m_P_in >>> sub_out : m_P_in;
    assign m_C_out = (sub_en == 2'b00)? m_C_in >>> sub_out : (sub_en == 2'b01)? m_C_in : m_C_in;





endmodule