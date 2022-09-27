`timescale 10ns/1ps
module Tb_F_Fuse_ramdom;

reg clk, rst;
reg [31:0] dataA, dataB, dataC;
wire [31:0] dataOut;
reg  [31:0] dataA_in [99:0];
reg  [31:0] dataB_in [99:0];
reg  [31:0] dataC_in [99:0];
reg  [31:0] dataOut_out [99:0];
integer fp_r,fp_w, zzz;
integer i, j;
real float_temp;
parameter t  = 10;
parameter th = t*0.5;

always #th clk =  ~clk;

Top top (.A(dataA), .B(dataB), .C(dataC), .D(dataOut));

initial 
begin
    fp_r = $fopen("D:/random_num.txt", "r");       //read file
    fp_w = $fopen("D:/random_num_answer.txt", "w");     //write file
    for( i = 0 ; i < 100 ; i = i + 1)     //read data
        zzz = $fscanf(fp_r, "%x %x %x\n", dataC_in[i], dataB_in[i], dataA_in[i]);

    clk = 1; rst = 0; j = 0;        //preset
    #t rst = 1;     //set
    #t rst = 0;     //start

       for(i = 0; i < 100; i = i+1)
        begin
            dataC <=  dataC_in[i];
            dataB <=  dataB_in[i];
            dataA <=  dataA_in[i];

            #th;
            dataOut_out[i] <= dataOut;



        #t;
        end
         //dataOut_out[100] <= dataOut;
        // #t  dataOut_out[98] <= dataOut;
        // #t  dataOut_out[99] <= dataOut;
        // #t;
    
    for(i = 0; i < 100; i = i + 1) $fwrite(fp_w, "%h\n",dataOut_out[i]);
    
    $fclose(fp_r);
    $fclose(fp_w);
    $stop;
end

initial begin
    $monitor ("dataA = %h, dataB = %h, dataC = %h, dataOut = %h", dataA, dataB, dataC, dataOut);
end

// initial begin
//     $sdf_annotate("design_syn.sdf", top);
// end



endmodule