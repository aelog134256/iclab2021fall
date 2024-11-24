`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif


module PATTERN(
    // Output signals
    clk,
    rst_n,
    in_valid,
    in,
    // Input signals
    out_valid,
    out
);
//======================================
//          I/O PORTS
//======================================
output reg        clk;
output reg      rst_n;
output reg   in_valid;
output reg         in;

input       out_valid;
input [1:0]       out;

//======================================
//      PARAMETERS & VARIABLES
//======================================
parameter PATNUM = 5;
parameter CYCLE  = `CYCLE_TIME;
parameter DELAY  = 3000;
integer   SEED   = 1208;
integer    file;
integer    flag;

// PATTERN CONTROL
integer       i;
integer       j;
integer       k;
integer       m;
integer    stop;
integer     pat;
integer exe_lat;
integer out_lat;

//pragma protect
//pragma protect begin

// Store input
reg map[0:18][0:18];

// Calculate shortest path
integer map_cal[0:18][0:18];
integer stack_x[0:2999];
integer stack_y[0:2999];
integer stack_ptr;
integer cur_x, cur_y;

// Record the output steps
integer map_your[0:18][0:18];
integer pre_dir;
integer your_x, your_y;
integer pre_x, pre_y;
integer your_x_stack[0:289], your_y_stack[0:289];

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
    for (pat=0 ; pat<PATNUM ; pat=pat+1) begin
        input_task;
        solve_map_cal;
        wait_task;
        check_task;
    end
    pass_task;
end endtask

task reset_task; begin

    file = $fopen("../00_TESTBED/input.txt", "r");
    stack_clear;

    force clk = 0;
    rst_n     = 1;
    in_valid  = 0;
    in        = 'dx;

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
    repeat($urandom_range(2,4)) @(negedge clk);
    for( i=0 ; i<19 ; i=i+1 ) begin
        for( j=0 ; j<19 ; j=j+1 ) begin
            if(i==0 || i==18 || j==0 || j==18) begin
                map[i][j]     = 0;
                map_cal[i][j] = -1;
            end
            else begin
                flag = $fscanf(file, "%d", map[i][j]);
                map_cal[i][j] = map[i][j] - 1;
            end
            map_your[i][j] = map[i][j];
        end
    end

    for( i=1 ; i<18 ; i=i+1 ) begin
        for( j=1 ; j<18 ; j=j+1 ) begin
            in_valid = 1;
            in = map[i][j];
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
            @(negedge clk);
        end
    end
    in_valid = 0;
    in = 'dx;
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
            $display("    is over 3000 cycles       `:::--:/++:----------::/:.                ");                          
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
            $display("================================================================================");
            $display("Shortest path");
            display_map;
            //$display("================================================================================");
            //$display("Your path");
            //display_map_your_wall(your_x, your_y);
            //$display("Your    Direction is %11d", out);
            //$display("Your   # of steps is %11d", out_lat-exe_lat);
            //$display("Your X Coordinate is %d", your_x-1);
            //$display("Your Y Coordinate is %d", your_y-1);
            repeat(5) @(negedge clk);
            $finish; 
        end
        exe_lat = exe_lat + 1;
        @(negedge clk);
    end
end endtask

task check_task; begin
    out_lat = exe_lat;
    your_x = 1;
    your_y = 1;
    stop = 0;
    map_your[your_y][your_x] = 2;
    pre_dir = -1;
    for(i = 0 ; i < 3000 ; i=i+1) begin
        your_x_stack[i] = 'dx;
        your_y_stack[i] = 'dx;
    end
    your_x_stack[0] = 1;
    your_y_stack[0] = 1;
    
    while (out_valid === 1) begin
        if(pre_dir == 0 && out == 2) map_your[your_y][your_x] = 1;
        if(pre_dir == 1 && out == 3) map_your[your_y][your_x] = 1;
        if(pre_dir == 2 && out == 0) map_your[your_y][your_x] = 1;
        if(pre_dir == 3 && out == 1) map_your[your_y][your_x] = 1;

        case(out)
            2'd0: your_x = your_x + 1;
            2'd1: your_y = your_y + 1;
            2'd2: your_x = your_x - 1;
            2'd3: your_y = your_y - 1;
        endcase

        if(map_your[your_y][your_x] == 2)
            map_your[your_y][your_x] = 1;
        else
            map_your[your_y][your_x] = 2;
        pre_dir = out;

        if (out_lat == DELAY) begin
            map_your[your_y][your_x] = 3;
            $display("                                   ..--.                                ");
            $display("                                `:/:-:::/-                              ");
            $display("                                `/:-------o                             ");
            $display("                                /-------:o:                             ");
            $display("                                +-:////+s/::--..                        ");
            $display("    The execution latency      .o+/:::::----::::/:-.       at %-12d ps  ", $time*1000);
            $display("    is over 3000 cycles       `:::--:/++:----------::/:.                ");
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
            $display("================================================================================");
            $display("Shortest path");
            display_map;
            $display("================================================================================");
            $display("Your path");
            display_map_your;
            $display("Your    Direction is %11d", out);
            $display("Your   # of steps is %11d", out_lat-exe_lat);
            $display("Your X Coordinate is %d", your_x-1);
            $display("Your Y Coordinate is %d", your_y-1);
            repeat(5) @(negedge clk);
            $finish;
        end

        if(map[your_y][your_x] == 0) begin
            map_your[your_y][your_x] = 3;
            $display("                                                                                ");
            $display("                                                   ./+oo+/.                     ");
            $display("    You walk into the wall!!!!!                   /s:-----+s`     at %-12d ps   ",$time*1000);
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
            
            $display("================================================================================");
            $display("Shortest path");
            display_map;
            $display("================================================================================");
            $display("Your path");
            display_map_your_wall(your_x, your_y);
            $display("Your    Direction is %11d", out);
            $display("Your   # of steps is %11d", out_lat-exe_lat);
            $display("Your X Coordinate is %d", your_x-1);
            $display("Your Y Coordinate is %d", your_y-1);
            for(i=0 ; i<out_lat - exe_lat ; i=i+1) begin
                if(i == 0) $write("X : %-2d ", your_x_stack[i]-1);
                else       $write("%-2d ", your_x_stack[i]-1);
            end
            $write("\n");
            for(i=0 ; i<out_lat - exe_lat ; i=i+1) begin
                if(i == 0) $write("Y : %-2d ", your_y_stack[i]-1);
                else       $write("%-2d ", your_y_stack[i]-1);
            end
            $write("\n");
            repeat(5) @(negedge clk);
            $finish;
        end
        your_x_stack[out_lat - exe_lat + 1] = your_x;
        your_y_stack[out_lat - exe_lat + 1] = your_y;
        @(negedge clk);
        out_lat = out_lat + 1;
    end

    // If the design walk to the end
    // But the out_valid is still 1
    // We should check
    /*
    if(out_valid == 1 && stop == 1) begin
        map_your[your_y][your_x] = 3;
        $display("                                                                                ");   
        $display("                                                   ./+oo+/.                     ");   
        $display("    You find the end!                              /s:-----+s`    at %-12d ps   ",$time*1000);
        $display("    But your out_valid is still 1                 y/-------:y                   ");
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
    */

    if( out_valid == 0 && (your_x != 17 || your_y != 17) ) begin
        map_your[your_y][your_x] = 3;
        $display("                                                                                ");   
        $display("                                                   ./+oo+/.                     ");   
        $display("    You didn't find the end!!!!!                   /s:-----+s`    at %-12d ps   ",$time*1000);
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
        $display("================================================================================");
        $display("Shortest path");
        display_map;
        $display("================================================================================");
        $display("Your path");
        display_map_your;
        $display("Your    Direction is %11d", out);
        $display("Your   # of steps is %11d", out_lat-exe_lat);
        $display("Your X Coordinate is %d", your_x-1);
        $display("Your Y Coordinate is %d", your_y-1);
        repeat(5) @(negedge clk);
        $finish;
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

task display_map; begin
    // Print idx X
    $write("\033[1;0m");
    $write("   ");
    for ( i=0 ; i<19 ; i=i+1 ) begin
        if(i==0 || i==18) $write("\033[1;32m W ");
        else              $write("\033[1;32m%2d ", i-1);
    end
    $write("\n");
    $write("\033[1;0m");

    for ( i=0 ; i<19 ; i=i+1 ) begin
        for ( j=0 ; j<19 ; j=j+1 ) begin
            $write("\033[1;0m");
            // Print idx Y
            if(j==0) begin
                if(i==0 || i==18) $write("\033[1;32m W ");
                else              $write("\033[1;32m%2d ", i-1);
            end
            if(map[i][j] == 0)       $write("\033[1;37m\033[1;44m%2d ", map[i][j]);
            else if(map_cal[i][j]>0) $write("\033[1;31m%2d ", map[i][j]);
            else                     $write("\033[1;33m%2d ", map[i][j]);
            $write("\033[1;0m");
        end
        $write("\n");
    end
    $write("\n");
end endtask

task display_map_your; begin
    // Print idx X
    $write("\033[1;0m");
    $write("   ");
    for ( i=0 ; i<19 ; i=i+1 ) begin
        if(i==0 || i==18) $write("\033[1;32m W ");
        else              $write("\033[1;32m%2d ", i-1);
    end
    $write("\n");
    $write("\033[1;0m");

    for ( i=0 ; i<19 ; i=i+1 ) begin
        for ( j=0 ; j<19 ; j=j+1 ) begin
            $write("\033[1;0m");
            // Print idx Y
            if(j==0) begin
                if(i==0 || i==18) $write("\033[1;32m W ");
                else              $write("\033[1;32m%2d ", i-1);
            end
            // Print map
            if(map_your[i][j] == 0)      $write("\033[1;37m\033[1;44m%2d ", map_your[i][j]);
            else if(map_your[i][j] == 2) $write("\033[1;31m%2d ", map_your[i][j]);
            else if(map_your[i][j] == 3) $write("\033[1;36m%2d ", map_your[i][j]);
            else                         $write("\033[1;33m%2d ", map_your[i][j]);
            $write("\033[1;0m");
        end
        $write("\n");
    end
    $write("\n");
end endtask

task display_map_your_wall;
    input integer x;
    input integer y;
begin
    // Print idx X
    $write("\033[1;0m");
    $write("   ");
    for ( i=0 ; i<19 ; i=i+1 ) begin
        if(i==0 || i==18) $write("\033[1;32m W ");
        else              $write("\033[1;32m%2d ", i-1);
    end
    $write("\n");
    $write("\033[1;0m");

    for ( i=0 ; i<19 ; i=i+1 ) begin
        for ( j=0 ; j<19 ; j=j+1 ) begin
            $write("\033[1;0m");
            // Print idx Y
            if(j==0) begin
                if(i==0 || i==18) $write("\033[1;32m W ");
                else              $write("\033[1;32m%2d ", i-1);
            end
            // Print map
            if(i==y && j==x)             $write("\033[1;37m\033[1;45m%2d ", map_your[i][j]);
            else if(map_your[i][j] == 0) $write("\033[1;37m\033[1;44m%2d ", map_your[i][j]);
            else if(map_your[i][j] == 2) $write("\033[1;31m%2d ", map_your[i][j]);
            else if(map_your[i][j] == 3) $write("\033[1;36m%2d ", map_your[i][j]);
            else                         $write("\033[1;33m%2d ", map_your[i][j]);
            $write("\033[1;0m");
        end
        $write("\n");
    end
    $write("\n");
end endtask

task display_map_cal; begin
    for ( i=0 ; i<19 ; i=i+1 ) begin
        for ( j=0 ; j<19 ; j=j+1 ) begin
            $write("\033[1;0m");
            if(map_cal[i][j] >= 0) $write("\033[1;33m%2d ", map_cal[i][j]);
            else                   $write("\033[1;37m\033[1;44m%2d ", map_cal[i][j]);
            $write("\033[1;0m");
        end
        $write("\n");
    end
end endtask

task solve_map_cal; begin
    stop = 0;
    map_cal[1][1] = 1;
    k = 2;
    cur_x = 1;
    cur_y = 1;
    stack_push(cur_x, cur_y);
    while(!stop) begin
    //for ( m=0 ; m<34 ; m=m+1 ) begin
        //display_map_cal;
        //$display("%d %d %d", k, cur_x, cur_y);
        // UP
        if(map_cal[cur_y-1][cur_x] == 0) begin
            map_cal[cur_y-1][cur_x] = k;
            k = k + 1;
            cur_y = cur_y - 1;
            stack_push(cur_x, cur_y);
        end
        // DOWN
        else if(map_cal[cur_y+1][cur_x] == 0) begin
            map_cal[cur_y+1][cur_x] = k;
            k = k + 1;
            cur_y = cur_y + 1;
            stack_push(cur_x, cur_y);
        end
        // LEFT
        else if(map_cal[cur_y][cur_x-1] == 0) begin
            map_cal[cur_y][cur_x-1] = k;
            k = k + 1;
            cur_x = cur_x - 1;
            stack_push(cur_x, cur_y);
        end
        // RIGHT
        else if(map_cal[cur_y][cur_x+1] == 0) begin
            map_cal[cur_y][cur_x+1] = k;
            k = k + 1;
            cur_x = cur_x + 1;
            stack_push(cur_x, cur_y);
        end
        else begin
            k = map_cal[cur_y][cur_x];
            map_cal[cur_y][cur_x] = -1;
            stack_pop(cur_x, cur_y);
            stack_top(cur_x, cur_y);
        end
        if(cur_x == 17 && cur_y == 17)
            stop = 1;
    end
    //stack_display;
end endtask

// Stack Operation
task stack_push;
    input integer x;
    input integer y;
begin
    stack_ptr = stack_ptr + 1;
    stack_x[stack_ptr] = x;
    stack_y[stack_ptr] = y;
end endtask

task stack_pop;
    output integer x;
    output integer y;
begin
    x = stack_x[stack_ptr];
    y = stack_y[stack_ptr];
    stack_x[stack_ptr] = 0;
    stack_y[stack_ptr] = 0;
    stack_ptr = stack_ptr - 1;
end endtask

task stack_top;
    output integer x;
    output integer y;
begin
    x = stack_x[stack_ptr];
    y = stack_y[stack_ptr];
end endtask

task stack_clear; begin
    for(i=0 ; i<289 ; i=i+1) begin
        stack_x[i] = 0;
        stack_y[i] = 0;
        stack_ptr = -1;
    end
end endtask

task stack_display; begin
    $write("Ptr #%d\n", stack_ptr);
    for(i=0 ; i<289 ; i=i+1) begin
        $write("Ptr #%d at x : %d\n", i, stack_x[i]);
        $write("Ptr #%d at y : %d\n", i, stack_y[i]);
    end
end endtask

endmodule

//pragma protect end
