module LBP ( clk, reset, gray_addr, gray_req, gray_data, lbp_addr, lbp_write, lbp_data, finish);
input    clk;
input    reset;
output reg  [5:0]  gray_addr;
output reg          gray_req;
input   [7:0]  gray_data;
output reg  [5:0]  lbp_addr;
output reg  lbp_write;
output reg [7:0]  lbp_data;
output reg  finish;

parameter idle = 3'd0;
parameter read = 3'd1;
parameter compute = 3'd2;
parameter store = 3'd3;
parameter done = 3'd4;

reg [2:0] cs,ns;
reg [7:0] box [8:0]; // LBP bounding box
reg [1:0] cnt_box;
reg [2:0] cnt_mem;
reg [3:0] i;
reg [5:0] cnt_corner; // counter for the corner of box
reg [1:0] th0,th1,th2,th3,th5,th6,th7,th8; // threshold

always @(posedge clk , posedge reset) begin  // current state
    if(reset) cs <= idle;
    else cs <= ns ;
end

always @(*) begin // next state
    case (cs)
        idle:begin
            if(!reset) ns = read;
            else ns = idle;
        end

        read:begin
            if(i == 4'd8) ns = compute; // read 9 pixels
            else ns = read;
        end

        compute: ns = store;

        store: begin
            if(lbp_addr < 6'd54) ns = read;
            else ns = done;
        end

        done: ns = idle;
        
        default;
        
    endcase
end

always @(*) begin // output state
    case (cs)       
        idle: begin
            gray_req = 0;
            lbp_write = 0;
            finish = 0;
        end

        read: begin
            gray_req = 1;
            lbp_write = 0;
            box[i] = gray_data;
        end

        compute: begin
            gray_req = 0;
            th0 = (box[0] >= box[4])?1:0;
            th1 = (box[1] >= box[4])?1:0;
            th2 = (box[2] >= box[4])?1:0;
            th3 = (box[3] >= box[4])?1:0;
            th5 = (box[5] >= box[4])?1:0;
            th6 = (box[6] >= box[4])?1:0;
            th7 = (box[7] >= box[4])?1:0;
            th8 = (box[8] >= box[4])?1:0;
        end

        store: begin
            lbp_write = 1;
            lbp_data = th0 + (th1 << 1) + (th2 << 2)+ (th3 << 3)+ (th5 << 4)+ (th6 << 5)+ (th7 << 6)+ (th8 << 7);
        end

        done: finish = 1;

        default: begin
            gray_req = 1'b0;
            lbp_write = 1'b0;  
        end
  
        
    endcase
    
end

always @(posedge clk , posedge reset) begin
    if(reset) i <= 0;
    else if (cs == read) i <= i + 1;
    else i <= 0;
end

always @(posedge clk , posedge reset ) begin 
    if(reset) cnt_box <= 0;
    else if (cs == read && cnt_box < 2) cnt_box <= cnt_box +1; // counting for a index of rows in the box
    else cnt_box <= 0;
end

always @(posedge clk , posedge reset) begin
    if(reset) cnt_corner <= 0;
    else if (cs == compute)begin // counting for a index of the upper left corner of the box;
        if(cnt_mem < 5) cnt_corner <= cnt_corner + 1;
        else cnt_corner <= cnt_corner + 3;
    end
    else ;
end

always @(posedge clk , posedge reset) begin
    if(reset) gray_addr <= 0;
    else if (cs == read) begin
        if(cnt_box == 2) gray_addr <= gray_addr + 6; // go to next row in the box
        else gray_addr <= gray_addr + 1; 
    end
    else gray_addr <= cnt_corner; // next start point
end

always @(posedge clk , posedge reset) begin
    if(reset) cnt_mem <= 0;
    else if (cs == compute) cnt_mem <= cnt_mem + 1; // counting for a index of rows in the memory
    else if (cnt_mem == 6) cnt_mem <= 0; // ignoring the outermost ring
    else ;
end

always @(posedge clk , posedge reset) begin 
    if(reset) lbp_addr <= 9;
    else if (cs == store)begin
        if(cnt_mem == 6) lbp_addr <= lbp_addr + 3; // go to next row in the lbp memory
        else lbp_addr <= lbp_addr + 1;
    end
    else ;
    
end

endmodule