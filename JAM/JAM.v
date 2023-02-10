module JAM (
input CLK,
input RST,
output reg [2:0] W, //row
output reg [2:0] J, //column
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg compare1_done, exchange_done, cost_en;
reg [2:0] cnt , exchange_point2, a, b;
reg [3:0] cs, ns, i , k; 
reg [2:0] s [0:7]; //series
reg [2:0] r_s [0:7]; // series after reverse
reg [9:0] work_cost;
reg [9:0] temp; // save the previous MinCost
reg [15:0] combinations;

parameter idle = 4'd0;
parameter compute = 4'd1; // compute work cost
parameter compare1 = 4'd2; // find the exchange point
parameter compare2 = 4'd3; // find the mim num to the right side of exchange point
parameter exchange = 4'd4; // exchange num
parameter reverse = 4'd5; // reverse the series
parameter backup = 4'd6;
parameter done = 4'd7;

always @(posedge CLK)begin // current state
    if(RST) cs <= idle;
    else cs <= ns;
end

always @(*) begin // next state
    case(cs)
    idle: ns = compute;

    compute: begin
        if(cnt == 7) ns = compare1;
        else ns = compute;
    end

    compare1: begin
        if(compare1_done) ns = compare2;
        else if(combinations == 40320) ns = done;
        else ns = compare1;
    end

    compare2: ns = exchange;

    exchange: begin
        if(exchange_done) ns = reverse;
        else ns = exchange;
    end
    reverse: ns = backup;

    backup: ns = idle;

    done: ns = idle;

    default: ns = idle;

    endcase
end

always @(*) begin
    if(cs == compute) begin
        W = cnt;
        J = s[cnt];
    end

    else begin
        W = 0;
        J = 0;
    end
end

always @(posedge CLK) begin
    if(RST) work_cost <= 0;
    else if(cost_en) work_cost <= work_cost + Cost;
    else work_cost <= 0;
end

always@(*)begin
    if((combinations == 0) && (ns == compare2)) MinCost = work_cost;
	else if( cost_en == 0 && work_cost != 0)begin
        if(work_cost < MinCost) MinCost = work_cost;
        else;
	end
	else;	
end

always @(posedge CLK) begin
    if(ns == compute) temp <= MinCost;
    else;
end

always@(posedge CLK)begin
	if(RST) MatchCount <= 0;
	else if(cost_en == 0 && work_cost != 0)begin
		if(temp == work_cost) MatchCount <= MatchCount + 1;
		else if(temp > work_cost) MatchCount <= 1;
        else;
	end
	else;		
end

always @(posedge CLK) begin // "a" is the exchange point
    if(RST)begin
        a <= 6;
        b <= 7;
    end
    else if(cs == compute)begin // start from the right side
        a <= 6; 
        b <= 7; 
    end
    else if(cs == compare1)begin
        if(s[a] > s[b]) begin
            a <= a - 1;
            b <= b - 1;
        end
        else;
    end
    else;
end

always @(*) begin // the position which exchange with the exchange point
    if(cs == compare1) exchange_point2 = b;
    else if(cs == compare2)begin
        case(b)
        1:  for(i=1;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        2:  for(i=2;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        3:  for(i=3;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        4:  for(i=4;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        5:  for(i=5;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        6:  for(i=6;i<8;i=i+1)begin
                if((s[i] < s[exchange_point2] ) && (s[i] > s[a])) exchange_point2 = i;
                else;
            end

        7:  if((s[7] < s[exchange_point2] ) && (s[7] > s[a])) exchange_point2 = 7;
            else;
        default: ;
        endcase
    end
    else if(cs == reverse) exchange_point2 = 0;
    else;
end

always @(posedge CLK) begin
    if(RST) cnt <= 0;
    else if(cs == compute) cnt <= cnt + 1;
    else cnt <= 0;
end

always @(posedge CLK) begin
    if(RST) combinations <= 0;
    else if(cs == backup && ns == idle)begin
        if(combinations < 40320) combinations <= combinations + 1; // all combinations are 8! = 40320
        else combinations <= 0;
    end    
    else; 
end

always @(posedge CLK) begin
    if(RST) begin
        for(i=0;i<8;i=i+1) s[i] <= i; // first series [0,1,2,3,4,5,6,7]
    end
    else if(cs == exchange && ns == exchange)begin
        s[a] <= s[exchange_point2];
        s[exchange_point2] <= s[a];
    end
    else if(cs == backup) begin
        for(i=0;i<8;i=i+1) s[i] <= r_s[i];
    end
    else;
end

always @(*) begin 
    if(cs == reverse) begin
        case(a)
        1: r_s[0] = s[0];
        2: for(i=0;i<2;i=i+1) r_s[i] = s[i];
        3: for(i=0;i<3;i=i+1) r_s[i] = s[i];
        4: for(i=0;i<4;i=i+1) r_s[i] = s[i];
        5: for(i=0;i<5;i=i+1) r_s[i] = s[i];
        6: for(i=0;i<6;i=i+1) r_s[i] = s[i];
        default: ;
        endcase
        
        r_s[a] = s[a];

        case(b)
        1: for(k=1;k<8;k=k+1) r_s[k] = s[7+1-k];
        2: for(k=2;k<8;k=k+1) r_s[k] = s[7+2-k];
        3: for(k=3;k<8;k=k+1) r_s[k] = s[7+3-k];
        4: for(k=4;k<8;k=k+1) r_s[k] = s[7+4-k];
        5: for(k=5;k<8;k=k+1) r_s[k] = s[7+5-k];
        6: for(k=6;k<8;k=k+1) r_s[k] = s[7+6-k];
        7: r_s[7] = s[7];
        default: ;
        endcase        
    end
    else;
end

always@(posedge CLK)begin
    if(RST) compare1_done <= 0;

    else if(cs == compare1)begin
        if(s[b] > s[a]) compare1_done <= 1;
        else compare1_done <= 0;
    end

    else
        compare1_done <= 0;  
end

always @(posedge CLK) begin
    if(RST) exchange_done <= 0;
    else if(cs == exchange) exchange_done <= 1;
    else exchange_done <= 0;
end

always @(posedge CLK) begin
    if(RST) cost_en <= 0;
    else if(cs == compute) begin
        cost_en <= 1;
    end
    else cost_en <= 0;
end

always@(posedge CLK, posedge RST)begin
    if(RST) Valid <= 0;
    else if(cs == done) Valid <= 1;
    else Valid <= 0;
end
endmodule