`ifdef RTL
    `timescale 1ns/10ps
    `include "NN.v"  
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `timescale 1ns/10ps
    `include "NN_SYN.v"
    `define CYCLE_TIME 20.0
`endif

//synopsys translate_off
`include "DW_fp_sum4.v"
`include "DW_fp_sum3.v"
`include "DW_fp_cmp.v"
`include "DW_fp_mult.v"
`include "DW_fp_sub.v"
`include "DW_fp_addsub.v"
`include "DW_fp_ifp_conv.v"
`include "DW_ifp_fp_conv.v"
`include "DW_ifp_addsub.v"
//synopsys translate_on

module PATTERN(
    // Output signals
    clk,
    rst_n,
    in_valid_d,
    in_valid_t,
    in_valid_w1,
    in_valid_w2,
    data_point,
    target,
    weight1,
    weight2,
    // Input signals
    out_valid,
    out
);
//======================================
//      PARAMETERS & VARIABLES
//======================================
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;

//================================================================
//      I/O PORTS
//================================================================
output reg clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
output reg [inst_sig_width+inst_exp_width:0] data_point, target;
output reg [inst_sig_width+inst_exp_width:0] weight1, weight2;
input out_valid;
input [inst_sig_width+inst_exp_width:0] out;

//======================================
//      PARAMETERS & VARIABLES
//======================================
parameter PATNUM = 1;
parameter CYCLE  = `CYCLE_TIME;
parameter DELAY  = 300;
integer   SEED   = 1208;

integer file;
integer flag;

// PATTERN CONTROL
integer       i;
integer       j;
integer       k;
integer       m;

integer     pat;
integer   epoch;
integer     itr;

integer exe_lat;
integer out_lat;

// Store input
reg[31:0] data_in[0:99][0:3];
reg[31:0] weight_in1[0:11];
reg[31:0] weight_in2[0:2];
reg[31:0] target_in[0:99];

// Golden output
reg[31:0] target_gold;

//======================================
//              Clock
//======================================
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk;

//======================================
//              MAIN
//======================================
initial exe_task;

//======================================
//              TASKS
//======================================
task exe_task; begin
    reset_task;
    for(pat=0 ; pat<PATNUM ; pat=pat+1) begin
        for(epoch=0 ; epoch<25 ; epoch=epoch+1) begin
            for(itr=0 ; itr<100 ; itr=itr+1) begin
                input_task;
                nn_task;
                wait_task;
                check_task;
            end
        end
    end
    #(1000);
    $finish;
    //pass_task;
end endtask

task reset_task; begin

    file = $fopen("../00_TESTBED/input.txt", "r");

    force clk   = 0;
    rst_n       = 1;
    in_valid_d  = 0;
    in_valid_t  = 0;
    in_valid_w1 = 0;
    in_valid_w2 = 0;

    data_point = 'dx;
    target     = 'dx;
    weight1    = 'dx;
    weight2    = 'dx;

    #(CYCLE/2.0) rst_n = 0;
    #(CYCLE/2.0) rst_n = 1;
    if ( out_valid !== 0 || out !== 0 ) begin
        $display("                                           `:::::`                                                       ");
        $display("                                          .+-----++                                                      ");
        $display("                .--.`                    o:------/o                                                      ");
        $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
        $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
        $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
        $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
        $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
        $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
        $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
        $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
        $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
        $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
        $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
        $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
        $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
        $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
        $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
        $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
        $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
        $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
        $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
        $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
        $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
        $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
        $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.    Output signal should be 0         ");
        $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
        $display("                        :yysssssssssssssssssssssssssssssssssyhysh-     after the reset signal is asserted");
        $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
        $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:   at %4d ps                         ", $time*1000);
        $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
        $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
        $display("                       `s--------------------------::::::::-----:o                                       ");
        $display("                       +:----------------------------------------y`                                      ");
        repeat(5) #(CYCLE);
        $finish;
    end
    #(CYCLE/2.0) release clk;
end endtask

task input_task; begin
    repeat(2) @(negedge clk);
    if(epoch == 0 && itr == 0) begin
        for(i=0 ; i<12 ; i=i+1)
            flag = $fscanf(file, "%h", weight_in1[i]);

        for(i=0 ; i<3 ; i=i+1)
            flag = $fscanf(file, "%h", weight_in2[i]);

        for(i=0 ; i<100 ; i=i+1)
            for(j=0 ; j<4 ; j=j+1)
                flag = $fscanf(file, "%h", data_in[i][j]);

        for(i=0 ; i<100 ; i=i+1)
            flag = $fscanf(file, "%h", target_in[i]);

        //==================
        // Weight
        //==================
        for(i=0 ; i<12 ; i=i+1) begin
            in_valid_w1 = 1;
            weight1     = weight_in1[i];
            if(i<3) begin
                in_valid_w2 = 1;
                weight2     = weight_in2[i];
            end
            else begin
                in_valid_w2 = 0;
                weight2     = 'dx;
            end
            @(negedge clk);
        end
        in_valid_w1 = 0;
        in_valid_w2 = 0;
        weight1     = 'dx;
        weight2     = 'dx;

        repeat(2) @(negedge clk);

        //==================
        // Data and target
        //==================
        for(i=0 ; i<4 ; i=i+1) begin
            in_valid_d = 1;
            data_point = data_in[itr][i];
            if(i<1) begin
                in_valid_t = 1;
                target     = target_in[itr];
            end
            else begin
                in_valid_t = 0;
                target     = 'dx;
            end
            @(negedge clk);
        end
    end
    else begin
        //==================
        // Data and target
        //==================
        for(i=0 ; i<4 ; i=i+1) begin
            in_valid_d = 1;
            data_point = data_in[itr][i];
            if(i<1) begin
                in_valid_t = 1;
                target     = target_in[itr];
            end
            else begin
                in_valid_t = 0;
                target     = 'dx;
            end
            @(negedge clk);
        end
    end
    in_valid_d  = 0;
    in_valid_t  = 0;
    in_valid_w1 = 0;
    in_valid_w2 = 0;
    data_point = 'dx;
    target     = 'dx;
    weight1    = 'dx;
    weight2    = 'dx;

end endtask

task wait_task; begin
    exe_lat = -1;
    while ( out_valid!==1 ) begin
        if ( out !== 0 ) begin
            $display("                                           `:::::`                                                       ");
            $display("                                          .+-----++                                                      ");
            $display("                .--.`                    o:------/o                                                      ");
            $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
            $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
            $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
            $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
            $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
            $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
            $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
            $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
            $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
            $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
            $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
            $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
            $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
            $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
            $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
            $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
            $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
            $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
            $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
            $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
            $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
            $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
            $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.    Output signal should be 0         ");
            $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
            $display("                        :yysssssssssssssssssssssssssssssssssyhysh-     when the out_valid is pulled down ");
            $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
            $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:   at %4d ps                         ", $time*1000);
            $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
            $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
            $display("                       `s--------------------------::::::::-----:o                                       ");
            $display("                       +:----------------------------------------y`                                      ");
            repeat(5) #(CYCLE);
            $finish;
        end
        if (exe_lat == DELAY) begin
            $display("                                   ..--.                                ");
            $display("                                `:/:-:::/-                              ");
            $display("                                `/:-------o                             ");
            $display("                                /-------:o:                             "); 
            $display("                                +-:////+s/::--..                        ");
            $display("    The execution latency      .o+/:::::----::::/:-.       at %-12d ps  ", $time*1000);
            $display("    is over 300 cycles        `:::--:/++:----------::/:.                ");
            $display("                            -+:--:++////-------------::/-               ");
            $display("                            .+---------------------------:/--::::::.`   ");
            $display("                          `.+-----------------------------:o/------::.  ");
            $display("                       .-::-----------------------------:--:o:-------:  ");
            $display("                     -:::--------:/yy------------------/y/--/o------/-  ");
            $display("                    /:-----------:+y+:://:--------------+y--:o//:://-   ");
            $display("                   //--------------:-:+ssoo+/------------s--/. ````     ");
            $display("                   o---------:/:------dNNNmds+:----------/-//           ");
            $display("                   s--------/o+:------yNNNNNd/+--+y:------/+            ");
            $display("                 .-y---------o:-------:+sso+/-:-:yy:------o`            ");
            $display("              `:oosh/--------++-----------------:--:------/.            ");
            $display("              +ssssyy--------:y:---------------------------/            ");
            $display("              +ssssyd/--------/s/-------------++-----------/`           ");
            $display("              `/yyssyso/:------:+o/::----:::/+//:----------+`           ");
            $display("             ./osyyyysssso/------:/++o+++///:-------------/:            ");
            $display("           -osssssssssssssso/---------------------------:/.             ");
            $display("         `/sssshyssssssssssss+:---------------------:/+ss               ");
            $display("        ./ssssyysssssssssssssso:--------------:::/+syyys+               ");
            $display("     `-+sssssyssssssssssssssssso-----::/++ooooossyyssyy:                ");
            $display("     -syssssyssssssssssssssssssso::+ossssssssssssyyyyyss+`              ");
            $display("     .hsyssyssssssssssssssssssssyssssssssssyhhhdhhsssyssso`             ");
            $display("     +/yyshsssssssssssssssssssysssssssssyhhyyyyssssshysssso             ");
            $display("    ./-:+hsssssssssssssssssssssyyyyyssssssssssssssssshsssss:`           ");
            $display("    /---:hsyysyssssssssssssssssssssssssssssssssssssssshssssy+           ");
            $display("    o----oyy:-:/+oyysssssssssssssssssssssssssssssssssshssssy+-          ");
            $display("    s-----++-------/+sysssssssssssssssssssssssssssssyssssyo:-:-         ");
            $display("    o/----s-----------:+syyssssssssssssssssssssssyso:--os:----/.        ");
            $display("    `o/--:o---------------:+ossyysssssssssssyyso+:------o:-----:        ");
            $display("      /+:/+---------------------:/++ooooo++/:------------s:---::        ");
            $display("       `/o+----------------------------------------------:o---+`        ");
            $display("         `+-----------------------------------------------o::+.         ");
            $display("          +-----------------------------------------------/o/`          ");
            $display("          ::----------------------------------------------:-            ");
            repeat(5) @(negedge clk);
            $finish; 
        end
        exe_lat = exe_lat + 1;
        @(negedge clk);
    end
end endtask

//==================================
// Neural Network Combinational
//==================================
reg[31:0] d_in[0:3];
reg[31:0] w_in1[0:11];
reg[31:0] w_in2[0:2];
reg[31:0] t_in;

wire[31:0] t_out;
wire[31:0] w_out1[0:11];
wire[31:0] w_out2[0:2];

wire[31:0] lr_rate;
assign lr_rate =((epoch/4) == 0) ? 32'h358637BD :
                ((epoch/4) == 1) ? 32'h350637BD :
                ((epoch/4) == 2) ? 32'h348637BD :
                ((epoch/4) == 3) ? 32'h340637BD :
                ((epoch/4) == 4) ? 32'h338637BD :
                ((epoch/4) == 5) ? 32'h330637BD : 32'h328637BD;

//=================
// Froward layer1
//=================
wire[31:0] dw_1[0:11];
wire[31:0] h1[0:2];

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_0  ( .a(d_in[0] ), .b(w_in1[0] ), .rnd(3'b000), .z(dw_1[0] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_1  ( .a(d_in[1] ), .b(w_in1[1] ), .rnd(3'b000), .z(dw_1[1] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_2  ( .a(d_in[2] ), .b(w_in1[2] ), .rnd(3'b000), .z(dw_1[2] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_3  ( .a(d_in[3] ), .b(w_in1[3] ), .rnd(3'b000), .z(dw_1[3] ) );

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_4  ( .a(d_in[0] ), .b(w_in1[4] ), .rnd(3'b000), .z(dw_1[4] ) ); 
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_5  ( .a(d_in[1] ), .b(w_in1[5] ), .rnd(3'b000), .z(dw_1[5] ) ); 
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_6  ( .a(d_in[2] ), .b(w_in1[6] ), .rnd(3'b000), .z(dw_1[6] ) ); 
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_7  ( .a(d_in[3] ), .b(w_in1[7] ), .rnd(3'b000), .z(dw_1[7] ) ); 

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_8  ( .a(d_in[0]), .b(w_in1[8] ), .rnd(3'b000), .z(dw_1[8] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_9  ( .a(d_in[1]), .b(w_in1[9] ), .rnd(3'b000), .z(dw_1[9] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_10 ( .a(d_in[2]), .b(w_in1[10]), .rnd(3'b000), .z(dw_1[10]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF1_11 ( .a(d_in[3]), .b(w_in1[11]), .rnd(3'b000), .z(dw_1[11]) );
//---------------------------------------------------------------------------------------------------------------------------
DW_fp_sum4 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch) AF1_0 ( .a(dw_1[0]), .b(dw_1[1]), .c(dw_1[2] ), .d(dw_1[3] ), .rnd(3'b000), .z(h1[0]) );
DW_fp_sum4 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch) AF1_1 ( .a(dw_1[4]), .b(dw_1[5]), .c(dw_1[6] ), .d(dw_1[7] ), .rnd(3'b000), .z(h1[1]) );
DW_fp_sum4 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch) AF1_2 ( .a(dw_1[8]), .b(dw_1[9]), .c(dw_1[10]), .d(dw_1[11]), .rnd(3'b000), .z(h1[2]) );

//=================
// Froward layer2
//=================
wire[31:0] y1[0:2];
assign y1[0] = (h1[0][31] == 1'b0) ? h1[0] : 0;
assign y1[1] = (h1[1][31] == 1'b0) ? h1[1] : 0;
assign y1[2] = (h1[2][31] == 1'b0) ? h1[2] : 0;

wire[31:0] dw_2[0:2];

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF2_0 ( .a(y1[0]), .b(w_in2[0]), .rnd(3'b000), .z(dw_2[0]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF2_1 ( .a(y1[1]), .b(w_in2[1]), .rnd(3'b000), .z(dw_2[1]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MF2_2 ( .a(y1[2]), .b(w_in2[2]), .rnd(3'b000), .z(dw_2[2]) );
//-----------------------------------------------------------------------------------------------------------------------------
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch) AF2_0 ( .a(dw_2[0]), .b(dw_2[1]), .c(dw_2[2]), .rnd(3'b000), .z(t_out) );

//=================
// Backward layer2
//=================
wire[31:0] delta2;
DW_fp_sub  #(inst_sig_width,inst_exp_width,inst_ieee_compliance) SB2_0 ( .a(t_out), .b(t_in), .rnd(3'b000), .z(delta2) );

//=================
// Backward layer1
//=================
wire[31:0] g_prim[0:2];
assign g_prim[0] = (h1[0][31] == 1'b0) ? w_in2[0] : 0;
assign g_prim[1] = (h1[1][31] == 1'b0) ? w_in2[1] : 0;
assign g_prim[2] = (h1[2][31] == 1'b0) ? w_in2[2] : 0;

wire[31:0] delta1[0:2];

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MB1_0 ( .a(g_prim[0]), .b(delta2), .rnd(3'b000), .z(delta1[0]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MB1_1 ( .a(g_prim[1]), .b(delta2), .rnd(3'b000), .z(delta1[1]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MB1_2 ( .a(g_prim[2]), .b(delta2), .rnd(3'b000), .z(delta1[2]) );


//=================
// Update layer2
//=================
wire[31:0] lr_delta2;
wire[31:0] w2_step[0:2];

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU2_0 ( .a(lr_rate),   .b(delta2),     .rnd(3'b000), .z(lr_delta2)  );

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU2_1 ( .a(lr_delta2), .b(y1[0]),      .rnd(3'b000), .z(w2_step[0]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU2_2 ( .a(lr_delta2), .b(y1[1]),      .rnd(3'b000), .z(w2_step[1]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU2_3 ( .a(lr_delta2), .b(y1[2]),      .rnd(3'b000), .z(w2_step[2]) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU2_0 ( .a(w_in2[0]),  .b(w2_step[0]), .rnd(3'b000), .z(w_out2[0])  );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU2_1 ( .a(w_in2[1]),  .b(w2_step[1]), .rnd(3'b000), .z(w_out2[1])  );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU2_2 ( .a(w_in2[2]),  .b(w2_step[2]), .rnd(3'b000), .z(w_out2[2])  );


//=================
// Update layer1
//=================
wire[31:0] lr_delta1[0:2];
wire[31:0] w1_step[0:11];

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_0  ( .a(lr_rate),      .b(delta1[0]), .rnd(3'b000), .z(lr_delta1[0]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_1  ( .a(lr_rate),      .b(delta1[1]), .rnd(3'b000), .z(lr_delta1[1]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_2  ( .a(lr_rate),      .b(delta1[2]), .rnd(3'b000), .z(lr_delta1[2]) );

DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_3  ( .a(lr_delta1[0]), .b(d_in[0]),   .rnd(3'b000), .z(w1_step[0] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_4  ( .a(lr_delta1[0]), .b(d_in[1]),   .rnd(3'b000), .z(w1_step[1] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_5  ( .a(lr_delta1[0]), .b(d_in[2]),   .rnd(3'b000), .z(w1_step[2] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_6  ( .a(lr_delta1[0]), .b(d_in[3]),   .rnd(3'b000), .z(w1_step[3] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_7  ( .a(lr_delta1[1]), .b(d_in[0]),   .rnd(3'b000), .z(w1_step[4] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_8  ( .a(lr_delta1[1]), .b(d_in[1]),   .rnd(3'b000), .z(w1_step[5] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_9  ( .a(lr_delta1[1]), .b(d_in[2]),   .rnd(3'b000), .z(w1_step[6] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_10 ( .a(lr_delta1[1]), .b(d_in[3]),   .rnd(3'b000), .z(w1_step[7] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_11 ( .a(lr_delta1[2]), .b(d_in[0]),   .rnd(3'b000), .z(w1_step[8] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_12 ( .a(lr_delta1[2]), .b(d_in[1]),   .rnd(3'b000), .z(w1_step[9] ) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_13 ( .a(lr_delta1[2]), .b(d_in[2]),   .rnd(3'b000), .z(w1_step[10]) );
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) MU1_14 ( .a(lr_delta1[2]), .b(d_in[3]),   .rnd(3'b000), .z(w1_step[11]) );

DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_0  ( .a(w_in1[0] ), .b(w1_step[0] ), .rnd(3'b000), .z(w_out1[0] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_1  ( .a(w_in1[1] ), .b(w1_step[1] ), .rnd(3'b000), .z(w_out1[1] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_2  ( .a(w_in1[2] ), .b(w1_step[2] ), .rnd(3'b000), .z(w_out1[2] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_3  ( .a(w_in1[3] ), .b(w1_step[3] ), .rnd(3'b000), .z(w_out1[3] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_4  ( .a(w_in1[4] ), .b(w1_step[4] ), .rnd(3'b000), .z(w_out1[4] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_5  ( .a(w_in1[5] ), .b(w1_step[5] ), .rnd(3'b000), .z(w_out1[5] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_6  ( .a(w_in1[6] ), .b(w1_step[6] ), .rnd(3'b000), .z(w_out1[6] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_7  ( .a(w_in1[7] ), .b(w1_step[7] ), .rnd(3'b000), .z(w_out1[7] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_8  ( .a(w_in1[8] ), .b(w1_step[8] ), .rnd(3'b000), .z(w_out1[8] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_9  ( .a(w_in1[9] ), .b(w1_step[9] ), .rnd(3'b000), .z(w_out1[9] ) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_10 ( .a(w_in1[10]), .b(w1_step[10]), .rnd(3'b000), .z(w_out1[10]) );
DW_fp_sub # (inst_sig_width,inst_exp_width,inst_ieee_compliance) SU1_11 ( .a(w_in1[11]), .b(w1_step[11]), .rnd(3'b000), .z(w_out1[11]) );


//=================
// Check error
//=================
wire[31:0] err = 32'h38d1b717;
wire[31:0] diff;
wire err_flag;
DW_fp_sub #(inst_sig_width,inst_exp_width,inst_ieee_compliance) SE ( .a(target_gold), .b(out), .rnd(3'b000),    .z(diff) );
DW_fp_cmp #(inst_sig_width,inst_exp_width,inst_ieee_compliance) CE ( .a(diff),        .b(err), .agtb(err_flag), .zctr(1'd0));  

task nn_task; begin
    // Give input to the Neural Network
    for(i=0 ; i<4 ; i=i+1)
        d_in[i] = data_in[itr][i];

    for(i=0 ; i<12 ; i=i+1)
        w_in1[i] = weight_in1[i];

    for(i=0 ; i<3 ; i=i+1)
        w_in2[i] = weight_in2[i];
    
    t_in = target_in[itr];

    // Updata the weight
    for(i=0 ; i<12 ; i=i+1)
        weight_in1[i] = w_out1[i];

    for(i=0 ; i<3 ; i=i+1)
        weight_in2[i] = w_out2[i];   

end endtask

task check_task; begin
    out_lat = 0;
    target_gold = t_out;
    while (out_valid === 1) begin
        if(out_lat == 1) begin
            $display("                                                                                ");   
            $display("                                                   ./+oo+/.                     ");   
            $display("    Out cycles is more than 1                     /s:-----+s`     at %-12d ps   ",$time*1000);   
            $display("                                                  y/-------:y                   ");   
            $display("                                             `.-:/od+/------y`                  ");   
            $display("                               `:///+++ooooooo+//::::-----:/y+:`                ");   
            $display("                              -m+:::::::---------------------::o+.              ");   
            $display("                             `hod-------------------------------:o+             ");   
            $display("                       ./++/:s/-o/--------------------------------/s///::.      ");   
            $display("                      /s::-://--:--------------------------------:oo/::::o+     ");   
            $display("                    -+ho++++//hh:-------------------------------:s:-------+/    ");   
            $display("                  -s+shdh+::+hm+--------------------------------+/--------:s    ");   
            $display("                 -s:hMMMMNy---+y/-------------------------------:---------//    ");   
            $display("                 y:/NMMMMMN:---:s-/o:-------------------------------------+`    ");   
            $display("                 h--sdmmdy/-------:hyssoo++:----------------------------:/`     ");   
            $display("                 h---::::----------+oo+/::/+o:---------------------:+++s-`      ");   
            $display("                 s:----------------/s+///------------------------------o`       ");   
            $display("           ``..../s------------------::--------------------------------o        ");   
            $display("       -/oyhyyyyyym:----------------://////:--------------------------:/        ");   
            $display("      /dyssyyyssssyh:-------------/o+/::::/+o/------------------------+`        ");   
            $display("    -+o/---:/oyyssshd/-----------+o:--------:oo---------------------:/.         ");   
            $display("  `++--------:/sysssddy+:-------/+------------s/------------------://`          ");   
            $display(" .s:---------:+ooyysyyddoo++os-:s-------------/y----------------:++.            ");   
            $display(" s:------------/yyhssyshy:---/:o:-------------:dsoo++//:::::-::+syh`            ");   
            $display("`h--------------shyssssyyms+oyo:--------------/hyyyyyyyyyyyysyhyyyy`            ");   
            $display("`h--------------:yyssssyyhhyy+----------------+dyyyysssssssyyyhs+/.             ");   
            $display(" s:--------------/yysssssyhy:-----------------shyyyyyhyyssssyyh.                ");   
            $display(" .s---------------+sooosyyo------------------/yssssssyyyyssssyo                 ");   
            $display("  /+-------------------:++------------------:ysssssssssssssssy-                 ");   
            $display("  `s+--------------------------------------:syssssssssssssssyo                  ");   
            $display("`+yhdo--------------------:/--------------:syssssssssssssssyy.                  ");   
            $display("+yysyhh:-------------------+o------------/ysyssssssssssssssy/                   ");   
            $display(" /hhysyds:------------------y-----------/+yyssssssssssssssyh`                   ");   
            $display(" .h-+yysyds:---------------:s----------:--/yssssssssssssssym:                   ");   
            $display(" y/---oyyyyhyo:-----------:o:-------------:ysssssssssyyyssyyd-                  ");   
            $display("`h------+syyyyhhsoo+///+osh---------------:ysssyysyyyyysssssyd:                 ");   
            $display("/s--------:+syyyyyyyyyyyyyyhso/:-------::+oyyyyhyyyysssssssyy+-                 ");   
            $display("+s-----------:/osyyysssssssyyyyhyyyyyyyydhyyyyyyssssssssyys/`                   ");   
            $display("+s---------------:/osyyyysssssssssssssssyyhyyssssssyyyyso/y`                    ");   
            $display("/s--------------------:/+ossyyyyyyssssssssyyyyyyysso+:----:+                    ");   
            $display(".h--------------------------:::/++oooooooo+++/:::----------o`                   "); 
            repeat(5) @(negedge clk);
            $finish;
        end

        if(err_flag != 1) begin
            $display("                                                                                ");
            $display("                                                   ./+oo+/.                     ");
            $display("    The target output is not correct!!!           /s:-----+s`     at %-12d ps   ",$time*1000);
            $display("                                                  y/-------:y                   ");
            $display("                                             `.-:/od+/------y`                  ");
            $display("                               `:///+++ooooooo+//::::-----:/y+:`                ");
            $display("                              -m+:::::::---------------------::o+.              ");
            $display("                             `hod-------------------------------:o+             ");
            $display("                       ./++/:s/-o/--------------------------------/s///::.      ");
            $display("                      /s::-://--:--------------------------------:oo/::::o+     ");
            $display("                    -+ho++++//hh:-------------------------------:s:-------+/    ");
            $display("                  -s+shdh+::+hm+--------------------------------+/--------:s    ");
            $display("                 -s:hMMMMNy---+y/-------------------------------:---------//    ");
            $display("                 y:/NMMMMMN:---:s-/o:-------------------------------------+`    ");
            $display("                 h--sdmmdy/-------:hyssoo++:----------------------------:/`     ");
            $display("                 h---::::----------+oo+/::/+o:---------------------:+++s-`      ");
            $display("                 s:----------------/s+///------------------------------o`       ");
            $display("           ``..../s------------------::--------------------------------o        ");
            $display("       -/oyhyyyyyym:----------------://////:--------------------------:/        ");
            $display("      /dyssyyyssssyh:-------------/o+/::::/+o/------------------------+`        ");
            $display("    -+o/---:/oyyssshd/-----------+o:--------:oo---------------------:/.         ");
            $display("  `++--------:/sysssddy+:-------/+------------s/------------------://`          ");
            $display(" .s:---------:+ooyysyyddoo++os-:s-------------/y----------------:++.            ");
            $display(" s:------------/yyhssyshy:---/:o:-------------:dsoo++//:::::-::+syh`            ");
            $display("`h--------------shyssssyyms+oyo:--------------/hyyyyyyyyyyyysyhyyyy`            ");
            $display("`h--------------:yyssssyyhhyy+----------------+dyyyysssssssyyyhs+/.             ");
            $display(" s:--------------/yysssssyhy:-----------------shyyyyyhyyssssyyh.                ");
            $display(" .s---------------+sooosyyo------------------/yssssssyyyyssssyo                 ");
            $display("  /+-------------------:++------------------:ysssssssssssssssy-                 ");
            $display("  `s+--------------------------------------:syssssssssssssssyo                  ");
            $display("`+yhdo--------------------:/--------------:syssssssssssssssyy.                  ");
            $display("+yysyhh:-------------------+o------------/ysyssssssssssssssy/                   ");
            $display(" /hhysyds:------------------y-----------/+yyssssssssssssssyh`                   ");
            $display(" .h-+yysyds:---------------:s----------:--/yssssssssssssssym:                   ");
            $display(" y/---oyyyyhyo:-----------:o:-------------:ysssssssssyyyssyyd-                  ");
            $display("`h------+syyyyhhsoo+///+osh---------------:ysssyysyyyyysssssyd:                 ");
            $display("/s--------:+syyyyyyyyyyyyyyhso/:-------::+oyyyyhyyyysssssssyy+-                 ");
            $display("+s-----------:/osyyysssssssyyyyhyyyyyyyydhyyyyyyssssssssyys/`                   ");
            $display("+s---------------:/osyyyysssssssssssssssyyhyyssssssyyyyso/y`                    ");
            $display("/s--------------------:/+ossyyyyyyssssssssyyyyyyysso+:----:+                    ");
            $display(".h--------------------------:::/++oooooooo+++/:::----------o`                   ");
            //$display("================================================================================");
            repeat(5) @(negedge clk);
            $finish;
        end

        out_lat = out_lat + 1;
        @(negedge clk);
    end
end endtask

task pass_task; begin
    $display("\033[1;33m                `oo+oy+`                            \033[1;35m Congratulation!!! \033[1;0m                                   ");
    $display("\033[1;33m               /h/----+y        `+++++:             \033[1;35m PASS This Lab........Maybe \033[1;0m                          ");
    $display("\033[1;33m             .y------:m/+ydoo+:y:---:+o                                                                                      ");
    $display("\033[1;33m              o+------/y--::::::+oso+:/y                                                                                     ");
    $display("\033[1;33m              s/-----:/:----------:+ooy+-                                                                                    ");
    $display("\033[1;33m             /o----------------/yhyo/::/o+/:-.`                                                                              ");
    $display("\033[1;33m            `ys----------------:::--------:::+yyo+                                                                           ");
    $display("\033[1;33m            .d/:-------------------:--------/--/hos/                                                                         ");
    $display("\033[1;33m            y/-------------------::ds------:s:/-:sy-                                                                         ");
    $display("\033[1;33m           +y--------------------::os:-----:ssm/o+`                                                                          ");
    $display("\033[1;33m          `d:-----------------------:-----/+o++yNNmms                                                                        ");
    $display("\033[1;33m           /y-----------------------------------hMMMMN.                                                                      ");
    $display("\033[1;33m           o+---------------------://:----------:odmdy/+.                                                                    ");
    $display("\033[1;33m           o+---------------------::y:------------::+o-/h                                                                    ");
    $display("\033[1;33m           :y-----------------------+s:------------/h:-:d                                                                    ");
    $display("\033[1;33m           `m/-----------------------+y/---------:oy:--/y                                                                    ");
    $display("\033[1;33m            /h------------------------:os++/:::/+o/:--:h-                                                                    ");
    $display("\033[1;33m         `:+ym--------------------------://++++o/:---:h/                                                                     ");
    $display("\033[1;31m        `hhhhhoooo++oo+/:\033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
    $display("\033[1;31m         shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                              ");
    $display("\033[1;31m         .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
    $display("\033[1;31m        `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
    $display("\033[1;31m        -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
    $display("\033[1;31m         hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
    $display("\033[1;31m         `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                            ");
    $display("\033[1;31m          dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                         ");
    $display("\033[1;31m         :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                       ");
    $display("\033[1;31m        /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                      ");
    $display("\033[1;31m      +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                      ");
    $display("\033[1;31m      -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo              `-++o+:.`             ");
    $display("\033[1;31m       `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/            -o/://:/+s             ");
    $display("\033[1;31m         os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os            ");
    $display("\033[1;33m         h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
    $display("\033[1;33m         m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
    $display("\033[1;33m        `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
    $display("\033[1;33m        .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
    $display("\033[1;33m        +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
    $display("\033[1;33m        h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
    $display("\033[1;33m       `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
    $display("\033[1;33m    `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
    $display("\033[1;33m   -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
    $display("\033[1;33m   s/------------/y`           `/oo:--------:y/-------------:/oo+:------:/s:                                                 ");
    $display("\033[1;33m   o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
    $display("\033[1;33m    :+o++///+oo/.                   .+o+::--os-------------------:oy+oo:`/o+++++o-                                           ");
    $display("\033[1;33m       .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
    $display("\033[1;33m                                          `:+omy/---------------------+h:----:y+//so                                         ");
    $display("\033[1;33m                                              `-ys:-------------------+s-----+s///om                                         ");
    $display("\033[1;33m                                                 -os+::---------------/y-----ho///om                                         ");
    $display("\033[1;33m                                                    -+oo//:-----------:h-----h+///+d                                         ");
    $display("\033[1;33m                                                       `-oyy+:---------s:----s/////y                                         ");
    $display("\033[1;33m                                                           `-/o+::-----:+----oo///+s                                         ");
    $display("\033[1;33m                                                               ./+o+::-------:y///s:                                         ");
    $display("\033[1;33m                                                                   ./+oo/-----oo/+h                                          ");
    $display("\033[1;33m                                                                       `://++++syo`                                          ");
    $display("\033[1;0m"); 
    repeat(5) @(negedge clk);
    $finish;
end endtask

endmodule
