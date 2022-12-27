module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;

reg [5:0] i_s, cnt_s, cnt_s_temp;
reg [4:0] i_p, cnt_p;
reg [3:0] cs,ns;
reg [7:0] reg_s [0:31];
reg [7:0] reg_p [0:8];

//debug 
wire [7:0] s_debug = reg_s[i_s];
wire [7:0] p_debug = reg_p[i_p];

//states
parameter idle = 4'd0;
parameter read_string = 4'd1; 
parameter read_pattern = 4'd2; 
parameter check = 4'd3;
parameter check_match = 4'd4;
parameter hit = 4'd5;
parameter unhit = 4'd6;
parameter finish = 4'd7;

//special pattern symbols
parameter dot = 8'd46; 
parameter dollar = 8'd36;
parameter caret = 8'd94; // ^
parameter space = 8'd32;

always@(posedge clk, posedge reset) begin
    if(reset) 
    cs <= idle;
    else cs <= ns;
end

always@(*) begin
    case(cs)
    idle: begin
        if(isstring == 1) ns = read_string;
        else if(ispattern == 1) ns = read_pattern;
        else ns = idle;
    end
    read_string: begin
        if(isstring == 1) ns = read_string;
        else ns = read_pattern;
    end
    read_pattern: begin
        if(ispattern == 1) ns = read_pattern;
        else ns = check;
    end
    check: begin
            if(i_p == cnt_p) ns = hit; // all match
            else if(i_s == cnt_s || i_p == cnt_p) ns = check_match;
            else ns = check;
    end 
    check_match: begin
            if(reg_p[cnt_p-1] == dollar) begin 
                if(i_p+1 == cnt_p) ns = hit;
                else ns = unhit;
            end
            else begin
                if(i_p == cnt_p) ns = hit;
                else ns = unhit;
            end
    end

    hit: begin
        ns = finish;
    end
    unhit: begin
        ns = finish;
    end

    finish: begin
        if(isstring) ns = read_string;
        else if(ispattern) ns = read_pattern;
        else ns = idle;
    end

    default: ns = idle;
    endcase 
end
//output state     
always@(posedge clk, posedge reset) begin
    if(reset) begin
        i_s <= 0;
        i_p <= 0;
        match_index <= 0;

    end
    else if(cs == finish) begin
        i_s <= 0;
        i_p <= 0;
        match_index <= 0;
    end
         
    else if(cs == check) begin
        if(reg_s[i_s] == reg_p[i_p] || reg_p[i_p] == dot) begin  //match
            i_p <= i_p + 1;
            i_s <= i_s + 1;
            if(i_p == 0) match_index <= i_s; //fist pattern match           
        end
        //caret  
        else if(reg_p[i_p] == caret)begin 
            // hit the first string character (first pattern character or next pattern character is dot)
            if(i_s == 0 && (reg_s[0] == reg_p[1] || reg_p[1] == dot) ) begin
                i_p <= i_p + 1;
                i_s <= i_s + 1; 
                match_index <= 0;
            end
            // string has space && (hit the next character or next pattern character has dot)
            else if(reg_s[i_s] == space && (reg_s[i_s+1] == reg_p[i_p+1] || reg_p[i_p+1] == dot) ) begin
                i_p <= i_p + 1;
                i_s <= i_s + 1;
                match_index <= i_s + 1;
            end
            else begin           
                i_p <= 0; 
                i_s <= i_s + 1;
            end
        end
        //$    
        else if(reg_p[i_p] == dollar && (i_s == cnt_s || reg_s[i_s] == space)) begin //special pattern $
            i_p <= i_p + 1; 
            i_s <= i_s + 1;
        end
                            
        else if(reg_s[i_s] != reg_p[i_p] && reg_p[i_p] != dot) begin
            i_p <= 0;//reset match
            if(i_p != 0) i_s <= match_index + 1;
            else i_s <= i_s + 1;
        end
        else;
    end
    else;
end
 
always@(*) begin
    if(cs == hit) begin
        if(check_length == 1)begin
            if(length_p > max_length) match = 0;
            else match = 1;
        end
        else match = 1;
    end
    else if(cs == unhit) match = 0;
    else;
end

always@(*) begin
    if(cs == finish) valid = 1;
    else valid = 0;
end

//string register 
integer  i;
always@(posedge clk or posedge reset) begin
    if(reset) begin
        for(i=0;i<32;i=i+1)  reg_s[i] <= 0;
    end
    else if(cs == finish && ns == read_string) begin 
        reg_s[0] <= chardata;
        for(i=1;i<32;i=i+1) reg_s[i] <= 0;
    end
    else if(isstring == 1) reg_s[cnt_s] <= chardata;    
end
//string counter
always@(*) begin
    if(cs == finish && ns == read_string) cnt_s = 0;
    else if(cs  == idle && ns == read_string) cnt_s = 0;
    else if(isstring == 1'd1) cnt_s = cnt_s_temp + 1;
    else cnt_s = cnt_s_temp;
end

always@(posedge clk or posedge reset) begin
    if(reset) cnt_s_temp <= 0;
    else if(isstring == 1'd1) cnt_s_temp <= cnt_s;
end
 
//pattern register
always@(posedge clk, posedge reset) begin
    if(reset) begin
        for(i=0;i<9;i=i+1) reg_p[i] <= 0;
    end
    else if(ispattern) reg_p[cnt_p] <= chardata;
    else if(ns == hit || ns == unhit) begin
        for(i=0;i<9;i=i+1) reg_p[i] <= 0;
    end
    else;
end
//pattern counter 
always@(posedge clk, posedge reset) begin
    if(reset) cnt_p <= 0;
    else if(ispattern) cnt_p <= cnt_p + 1;
    else if(ns == hit || ns == unhit) cnt_p <= 0;
    else;
end

reg [3:0] length_s;
reg [3:0] max_length;
//a counter for the length of word in string
always @(posedge clk, posedge reset) begin
    if(reset) length_s <= 0;
    else if(cs  == finish) length_s <= 0;
    else if(ns == read_string) begin
        if(reg_s[cnt_s_temp] == space) length_s <= 0;
        else if(reg_s[cnt_s_temp] == 0);
        else length_s <= length_s + 1;
    end
end
//recording the maximum of word length
always @(*) begin
    if(cs == finish && ns == read_string) max_length = 0;
    else if(cs == read_string) max_length = (length_s > max_length)? length_s : max_length;
    else;
end

reg [3:0] length_p;
//A counter for the length of word in pattern
always @(posedge clk, posedge reset) begin
    if(reset) length_p <= 0;
    else if(cs == read_pattern) begin
        if(reg_p[cnt_p-1] == caret);
        else if(reg_p[cnt_p-1] == dollar);
        else length_p <= length_p + 1;
    end
    else if(cs == finish) length_p <= 0;
    else;
end

reg check_length;
//A signal to confirm whether need to check the length of the word
always @(*) begin
    if(cs == check)begin
        if(reg_p[0] == caret && reg_p[cnt_p-1] == dollar) check_length = 1;
        else check_length = 0;
    end
    else if(cs == finish) check_length = 0;
    else;
end

endmodule