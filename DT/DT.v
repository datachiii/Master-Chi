module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output	reg		sti_rd , 
	output	reg 	[9:0]	sti_addr , 
	input		[15:0]	sti_di, // databus for ROM to DT
	output	reg		res_wr , 
	output	reg		res_rd , 
	output	reg 	[13:0]	res_addr , 
	output	reg 	[7:0]	res_do, // databus for writing to RAM
	input		[7:0]	res_di // databus for reading RAM
	);

	reg [3:0] cs,ns,cnt;
	reg [7:0] min;
	
	parameter idle = 4'd0;
	parameter read = 4'd1; // read data from ROM
	parameter write = 4'd2; // save data to RAM
	parameter write_finish = 4'd3;
	parameter forward_read = 4'd4; // read data from RAM for forward
	parameter forward = 4'd5;
	parameter forward_write = 4'd6; // write data to RAM
	parameter forward_finish = 4'd7;
	parameter backward_read = 4'd8; // read data from RAM for backward
	parameter backward = 4'd9;
	parameter backward_write = 4'd10; // write data to RAM
	parameter finish = 4'd11;

	always @(posedge clk , negedge reset) begin
		if(!reset) cs <= idle;
		else cs <= ns;
	end

	always @(*) begin
		case(cs)

			idle: ns = read;

			read: ns = write;

			write: begin
				if(cnt == 15)
				begin
					if(res_addr == 14'd16383) ns = write_finish;
					else ns = read;
				end
				else ns = write;
			end

			write_finish: ns = forward_read;

			forward_read: begin
				if(res_di) ns = forward; // find the first one object
				else begin
					if(res_addr == 14'd16254) ns = forward_finish; // pass the outermost circle
					else ns = forward_read;
				end
			end

			forward: begin
				if(cnt == 5) ns = forward_write;
				else ns = forward;
			end

			forward_write: begin
				if(res_addr == 14'd16254) ns = forward_finish;
				else ns = forward_read;
			end

			forward_finish: ns = backward_read;

			backward_read: begin
				if(res_di) ns = backward;// find the first one object
				else begin
					if(res_addr == 14'd128) ns = finish; // pass the outermost circle
					else ns = backward_read;
				end
			end

			backward: begin
				if(cnt== 5) ns = backward_write;
				else ns = backward;
			end

			backward_write: begin
				if(res_addr == 14'd128) ns = finish;
				else ns = backward_read;
			end

			finish: ns = finish;

			default: ns = idle;

		endcase

	end

	always@(posedge clk or negedge reset)
	begin
		if(!reset) cnt <= 15;
		else if(ns == read) cnt <= 15;
		else if(ns == write || cs == write) cnt <= cnt - 1;
		else if(ns == forward || ns == backward) cnt <= cnt + 1;
		else if(ns == forward_write || ns == backward_write) cnt <= 0;
	end

	always @(*) begin // the signal of reading ROM 
		if (cs == read) sti_rd = 1;
		else sti_rd = 0;
	end

	always @(posedge clk , negedge reset) begin // ROM address
		if(!reset) sti_addr <= 0;
		else if (cs == read) sti_addr <= sti_addr + 1;
		else ;
	end

	always @(*) begin // the signal of writing to RAM
		if (cs == write || cs == forward_write || cs == backward_write) res_wr = 1;
		else res_wr = 0;
	end

	always @(*) begin // the signal of reading RAM
		if(cs == forward_read || cs == backward_read || cs == forward || cs == backward) res_rd = 1;
		else res_rd = 0;
	end

	always @(posedge clk , negedge reset) begin // RAM address
		if(!reset) res_addr <= 14'd16383; 
		else if (ns == write) res_addr <= res_addr + 1;
		else if (cs == write_finish) res_addr <= 128; // pass the outermost circle
		else if (cs == forward_finish) res_addr <= 14'd16255;
		else if (ns == forward || cs == forward) begin
			case(cnt)
			4'd0: res_addr <= res_addr - 129 ; // NW
			4'd1: res_addr <= res_addr + 1 ; // N
			4'd2: res_addr <= res_addr + 1; // NE
			4'd3: res_addr <= res_addr + 126; // W
			4'd4: res_addr <= res_addr + 1; // target
			endcase
		end

		else if (cs == forward_finish) res_addr <= 0;

		else if (ns == backward || cs == backward) begin
			case(cnt)
			4'd0: res_addr <= res_addr + 129; // SE
			4'd1: res_addr <= res_addr - 1 ; // S
			4'd2: res_addr <= res_addr - 1 ; // SW
			4'd3: res_addr <= res_addr - 126 ; // E
			4'd4: res_addr <= res_addr - 1; // target
			endcase
		end

		else if (cs == forward_read || cs == forward_write) res_addr <= res_addr + 1;
		else if (cs == backward_read || cs == backward_write) res_addr <= res_addr - 1;
	end 

	always @(posedge clk , negedge reset) begin // min function
		if(!reset) min <= 0;
		else if (cs == forward) begin
			if(cnt == 1) min <= res_di;
			else if(res_di < min) min <= res_di;
			else ;
		end
		else if (cs == backward_read) min <= res_di;
		else if (cs == backward) begin
			if(res_di + 1 < min) min <= res_di + 1;
			else;
		end
	end

	always @(posedge clk , negedge reset) begin // RAM
		if(!reset) res_do <= 0;
		else if (ns == write) res_do <= sti_di[cnt];
		else if (ns == forward_write) res_do <= min + 1;
		else if (ns == backward_write) res_do <= min;
	end

	always @(*) begin
		if (cs == finish) done = 1;
		else done = 0;
	end

endmodule
