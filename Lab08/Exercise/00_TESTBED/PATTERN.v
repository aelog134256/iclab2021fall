//=======================================//
//                                       //
// PATTERN : without clock gating enable //
//                                       //
//=======================================//

`define CYCLE_TIME 12

module PATTERN(
    // Output signals
    clk,
    rst_n,
    cg_en,
    in_valid,
    in_data,
    in_mode,
    // Input signals
    out_valid,
    out_data
);
//================================================================
//      I/O PORTS
//================================================================
output reg               clk;
output reg             rst_n;
output reg             cg_en;
output reg          in_valid;
output reg [8:0]     in_data;
output reg [2:0]     in_mode;

input              out_valid;
input signed [9:0]  out_data;

//================================================================
//      PARAMETERS & VARIABLES
//================================================================
real CYCLE = `CYCLE_TIME;
parameter OUT_NUM   =    3;
parameter DATA_NUM  =    9;
parameter DELAY     = 1000;
parameter PATNUM    = 5000;
parameter PATNUM_D  = 1000; // Total : 512 ^ 2
parameter PATNUM_XS = 1000; // Total : 2*10*10 ^ 2
integer   SEED      = 1208;

integer       i;
integer       j;
integer       m;
integer       n;

integer     pat;
integer    size;

integer exe_lat;
integer out_lat;

//================================================================
//      CACULATION REGISTER AND INTEGER
//================================================================
reg[2:0]     mode;

integer data_show[0:8];

integer                   max;
integer                   min;
integer                   sum;
integer      gold[0: OUT_NUM];
integer      your[0: OUT_NUM];
integer orig_data[0:DATA_NUM];
integer proc_data[0:DATA_NUM];
integer stg1_data[0:DATA_NUM];
integer stg2_data[0:DATA_NUM];


reg signed[8:0] temp;

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
    for ( pat=0 ; pat<PATNUM ; pat=pat+1 ) begin
        input_task;
        cal_task;
        wait_task;
        check_task;
    end
    pass_task;
    $finish;

end endtask

task reset_task; begin
    force clk = 0;
    rst_n     = 1;
    in_valid  = 0;
    in_data   = 'dx;
    in_mode   = 'dx;

    #(CYCLE/2.0) rst_n = 0;
    #(CYCLE/2.0) rst_n = 1;
    if ( out_valid !== 0 || out_data !== 0 ) begin       
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
    for ( i=0 ; i<DATA_NUM ; i=i+1 ) begin
        in_valid = 1;
        if( out_valid===1 ) begin
            $display("                                                                 ``...`                                ");
            $display("     Out_valid can't overlap in_valid!!!                      `.-:::///:-::`                           "); 
            $display("                                                            .::-----------/s.                          "); 
            $display("                                                          `/+-----------.--+s.`                        "); 
            $display("                                                         .+y---------------/m///:-.                    "); 
            $display("                         ``.--------.-..``            `:+/mo----------:/+::ys----/++-`                 "); 
            $display("                     `.:::-:----------:::://-``     `/+:--yy----/:/oyo+/:+o/-------:+o:-:/++//::.`     "); 
            $display("                  `-//::-------------------:/++:.` .+/----/ho:--:/+/:--//:-----------:sd/------://:`   "); 
            $display("                .:+/----------------------:+ooshdyss:-------::-------------------------od:--------::   ");
            $display("              ./+:--------------------:+ssosssyyymh-------------------------------------+h/---------   ");
            $display("             :s/-------------------:osso+osyssssdd:--------------------------------------+myoos+/:--   ");
            $display("           `++-------------------:oso+++os++osshm:----------------------------------------ss--/:---/   ");
            $display("          .s/-------------------sho+++++++ohyyodo-----------------------------------------:ds+//+/:.   "); 
            $display("         .y/------------------/ys+++++++++sdsdym:------------------------------------------/y---.`     "); 
            $display("        .d/------------------oy+++++++++++omyhNd--------------------------------------------+:         "); 
            $display("       `yy------------------+h++++++++++++ydhohy---------------------------------------------+.        "); 
            $display("       -m/-----------------:ho++++++++++++odyhoho--------------------/++:---------------------:        "); 
            $display("       +y------------------ss+++++++++++ossyoshod+-----------------+ss++y:--------------------+`       "); 
            $display("       y+-//::------------:ho++++++++++osyhddyyoom/---------------::------------------/syh+--+/        "); 
            $display("      `hy:::::////:-/:----+d+++++++++++++++++oshhhd--------------------------------------/m+++`        "); 
            $display("      `hs--------/oo//+---/d++++++++++++++++++++sdN+-------------------------------:------:so`         "); 
            $display("       :s----------:+y++:-/d++++++++++++++++++++++sh+--------------:+-----+--------s--::---os          "); 
            $display("       .h------------:ssy-:mo++++++++++++++++++++++om+---------------+s++ys----::-:s/+so---/+/.        "); 
            $display("    `:::yy-------------/do-hy+++++o+++++++++++++++++oyyo--------------::::--:///++++o+/:------y.       "); 
            $display("  `:/:---ho-------------:yoom+++++hsh++++++++++++ossyyhNs---------------------+hmNmdys:-------h.       "); 
            $display(" `/:-----:y+------------.-sshy++++ohNy++++++++sso+/:---sy--------------------/NMMMMMNhs-----+s/        "); 
            $display(" +:-------:ho-------------:homo+++++hmo+++++oho:--------ss///////:------------yNMMMNdoy//+shd/`        "); 
            $display(" y---------:hs/------------+yod++++++hdo+++odo------------::::://+oo+o/--------/oso+oo::/sy+:o/        "); 
            $display(" y----/+:---::so:----------/m-sdo+oyo+ydo+ody------------------------/oo/------:/+oo/-----::--h.       "); 
            $display(" oo---/ss+:----:/----------+y--+hyooysoydshh----------------------------ohosshhs++:----------:y`       "); 
            $display(" `/oo++oosyo/:------------:yy++//sdysyhhydNdo:---------------------------shdNN+-------------+y-        "); 
            $display("    ``...``.-:/+////::-::/:.`.-::---::+oosyhdhs+/:-----------------------/s//oy:---------:os+.         "); 
            $display("               `.-:://---.                 ````.:+o/::-----------------:/o`  `-://::://:---`           "); 
            $display("                                                  `.-//+o////::/::///++:.`           ``                "); 
            $display("                                                        ``..-----....`                                 ");
            $display("\033[1;0m");
            repeat(5) @(negedge clk);
            $finish;
        end
        
        // Mode
        if ( i==0 ) begin
            in_mode = 7;//{$random(SEED)}%8;
            mode = in_mode;
        end 
        else begin
            in_mode = 'dx;
        end       

        // Input data
        if ( mode[0]==1 ) begin
            in_data[3:0] = {$random(SEED)}%10 + 2'd3;
            in_data[7:4] = {$random(SEED)}%10 + 2'd3;
            in_data[8]   = {$random(SEED)}%2;
            data_show[i] = in_data;
            temp         = in_data - 'h33;
            orig_data[i] = in_data[8] ? (0-10*temp[7:4]) - temp[3:0] : 10*temp[7:4] + temp[3:0];
        end
        else begin
            in_data      = -256 + {$random(SEED)}%512;
            temp         = in_data;
            data_show[i] = temp;
            orig_data[i] = temp;
        end

        @(negedge clk);
    end
    in_valid = 0;
    in_mode  = 'dx;
    in_data  = 'dx;
end endtask

task cal_task; begin

    // Find the MAX value and MIN value
    max = orig_data[0];
    min = orig_data[0];
    for ( i=1 ; i<DATA_NUM ; i=i+1 ) begin
        if ( orig_data[i]>max ) max = orig_data[i];
        if ( orig_data[i]<min ) min = orig_data[i]; 
    end

    for ( i=0 ; i<DATA_NUM ; i=i+1 ) begin
        proc_data[i] = orig_data[i];
    end   

    // MODE 1 subtract the half of range
    if ( mode[1]==1 ) begin
        for ( i=0 ; i<DATA_NUM ; i=i+1 ) begin
            proc_data[i] = proc_data[i] - (max+min)/2;
            stg1_data[i] = proc_data[i];
        end
    end
    
    // MODE 2 moving average
    if ( mode[2]==1 ) begin
        for ( i=0 ; i<DATA_NUM ; i=i+1 ) begin
            if( i==0 ) proc_data[i] = proc_data[i];
            else begin
                proc_data[i] = (proc_data[i-1]*2 + proc_data[i])/3;
            end
            stg2_data[i] = proc_data[i];
        end
    end

    // Find 3 consecutive number set whose SAM is the MAX
    for ( i=0 ; i<DATA_NUM-2 ; i=i+1 ) begin
        if( i==0 ) begin
            sum     = proc_data[0] + proc_data[1] + proc_data[2];
            gold[0] = proc_data[0];
            gold[1] = proc_data[1];
            gold[2] = proc_data[2];
        end
        else if( (proc_data[i] + proc_data[i+1] + proc_data[i+2]) > sum ) begin
            sum     = proc_data[i] + proc_data[i+1] + proc_data[i+2];
            gold[0] = proc_data[i];
            gold[1] = proc_data[i+1];
            gold[2] = proc_data[i+2];
        end
    end
end endtask

task wait_task; begin
    exe_lat = -1;
    while ( out_valid!==1 ) begin
        if ( out_data !== 0 ) begin       
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
            $display("    is over 1000 cycles       `:::--:/++:----------::/:.                ");                          
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

task check_task; begin
    out_lat = 0;
    i = 0;
    while ( out_valid === 1 ) begin
        if (out_lat==OUT_NUM) begin
            $display("                                                                                ");   
            $display("                                                   ./+oo+/.                     ");   
            $display("    Out cycles is more than 4                     /s:-----+s`     at %-12d ps   ",$time*1000);   
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

        if ( i<OUT_NUM ) begin
            your[i] = out_data;
            i=i+1;
        end                    
       
        out_lat = out_lat + 1;
        @(negedge clk);
    end

    if (out_lat<OUT_NUM) begin     
        $display("                                                                                ");   
        $display("                                                   ./+oo+/.                     ");   
        $display("    Out cycles is less than 3                     /s:-----+s`     at %-12d ps   ",$time*1000);   
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

    for ( i=0 ; i<OUT_NUM ; i=i+1 ) begin
        if ( your[i] !== gold[i] ) begin
            $display("                                                                                ");   
            $display("                                                   ./+oo+/.                     ");   
            $display("    Out is not correct!!!!!                       /s:-----+s`     at %-12d ps   ",$time*1000);   
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

            $display("\033[1;34m");
            $display("=========================================");
            $display("=              Mode                     =");
            $display("=========================================");
            /*
            $display("=              XS-3 : V                 =");
            $display("=           Sub Mid : V                 =");
            $display("=              Sort : V                 =");
            */

            if ( mode[0]==1 ) $display("=              XS-3 : V                 =");
            else              $display("=              XS-3 : X                 =");

            if ( mode[1]==1 ) $display("=        Sub middle : V                 =");
            else              $display("=        Sub middle : X                 =");

            if ( mode[2]==1 ) $display("=        Cumulation : V                 =");
            else              $display("=        Cumulation : X                 =");

            $write("\033[1;34m");
            $display("=========================================");
            $display("\033[1;34m");
            $display("Original input data : ");
            $display("\033[1;0m");
            for ( j=0 ; j<DATA_NUM ; j=j+1 ) begin
                if ( mode[0]==1 ) $write("  \033[1;32m%3h", data_show[j]);
                else              $write("\033[1;32m%4d ", data_show[j]);
            end
            $display("\033[1;0m");

            if ( mode[0]==1 ) begin
                $display("\033[1;34m");
                $display("Decimal input data : ");
                for ( j=0 ; j<DATA_NUM ; j=j+1 ) begin
                    $write("\033[1;32m%4d ", orig_data[j]);
                end
            end
            $display("\033[1;0m");

            if ( mode[1]==1 ) begin
                $display("\033[1;34m");
                $display("Maximum : \033[1;32m%4d\033[1;34m", max);
                $display("Minimum : \033[1;32m%4d\033[1;34m", min);
                $display("\033[1;34m");
                $display("Mode[1] data : ");
                $display("\033[1;0m");
                for ( j=0 ; j<DATA_NUM ; j=j+1 ) begin
                    $write("\033[1;32m%4d ", stg1_data[j]);
                end
                $display("\033[1;0m");
            end

            if ( mode[2]==1 ) begin
                $display("\033[1;34m");
                $display("Mode[2] data : ");
                $display("\033[1;0m");
                for ( j=0 ; j<DATA_NUM ; j=j+1 ) begin
                    $write("\033[1;32m%4d ", stg2_data[j]);
                end
                $display("\033[1;0m");
            end
            $display("\033[1;34m");
            $display("Your answer : ");
            $display("\033[1;0m");
            for ( j=0 ; j<OUT_NUM ; j=j+1 ) begin
                if ( j==i ) $write("\033[1;31m%4d ", your[j]);
                else        $write("%4d ", your[j]);
                $write("\033[1;0m");
            end
            $display("\033[1;0m");

            $display("\033[1;34m");
            $display("Gold answer : ");
            $display("\033[1;0m");
            for ( j=0 ; j<OUT_NUM ; j=j+1 ) begin
                if ( j==i ) $write("\033[1;31m%4d ", gold[j]);
                else        $write("%4d ", gold[j]);
                $write("\033[1;0m");
            end
            $display("\033[1;0m");
            $display("\033[1;0m");
            $finish;
        end
    end
    $display("\033[1;35mNo.%-5d PATTERN PASS!!! \033[1;34mLatency : %-5d\033[1;0m", pat, exe_lat);
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
    repeat (5) @(negedge clk);
    $finish;
end endtask

endmodule
