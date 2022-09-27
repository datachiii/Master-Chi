module normalize (m_in, m_out, zero_cnt, en_out,clk);
    
    input [49:0] m_in;
    output [26:0] m_out;
    output [5:0] zero_cnt;
    output en_out;
    input clk;

    wire [49:0] tmp;
    wire s_bit, en;

    assign en_out = en;

    LOD lod (.m_in(m_in), .zero_cnt(zero_cnt), .en(en));

    assign tmp =  (en)? m_in >> zero_cnt : m_in << zero_cnt;
    assign s_bit = |tmp[19:0];
    assign m_out = {tmp[46:21], s_bit};


endmodule



module LOD (m_in, zero_cnt, en);

    input [49:0] m_in;
    output reg en;
    output reg [5:0] zero_cnt;
    integer i;

    reg continue ;
    always@(*) begin
       continue = 1'b1 ;
        for(i=49;(i>0) && continue ;i=i-1)begin
            if (m_in[i] == 1) begin
                if(i>45)begin
                zero_cnt = i- 6'd46 ;
                end
                else begin
                zero_cnt = 6'd46 - i ;
                end
            end
            en = (i>6'd45) ? 1'd1 : 1'd0;
            continue = m_in[i] ? 0 : 1; 
        end
    end  
endmodule