//==========================================================================
// 
// This Pattern policy is BRUTE FORCE!!!
//
// If you don't want to generate the "LARGE .FSDB FILE"
// 
// You should change the PAT_S ( pat_p start ) and PAT_E ( pat_p_end )
//
// (PAT0_S, PAT0_E) =>  GF(?)
// (0, 1)           =>  GF(4) 
// (1, 3)           =>  GF(8) 
// (3, 5)           =>  GF(16)
// (6, 11)          =>  GF(32)
//
//==========================================================================
`ifdef RTL
    `define CYCLE_TIME 20.0
`endif

`ifdef GATE
    `define CYCLE_TIME 20.0
`endif


module PATTERN(
    // Output signals
    clk,
    rst_n, 
    in_valid, 
    in_data,
    deg, 
    poly,
    // Input signals
    out_valid,
    out_data
);

//================================================================
//      I/O PORTS
//================================================================
output reg            clk;
output reg          rst_n;
output reg       in_valid;

output reg [4:0]  in_data;
output reg [2:0]      deg;
output reg [5:0]     poly;

input           out_valid;
input [4:0]      out_data;


//======================================
//      PARAMETERS & VARIABLES
//======================================
//--------------------------------------
// Change by yourself
//
parameter PAT_S = 6;
//        ^^^^^^^^^
parameter PAT_E = 11;
//        ^^^^^^^^^
//--------------------------------------
parameter CYCLE  = `CYCLE_TIME;
parameter DELAY  = 300;

integer       i;
integer       j;
integer       m;
integer       n;

integer   pat_p;
integer    pat0;
integer    pat1;
integer    pat2;
integer    pat3;
integer    size;

integer exe_lat;
integer out_lat;

//================================================================
//      REGISTER DECLARATION
//================================================================
reg [4:0] data[0:3];
reg [2:0]   deg_sel;
reg [5:0]  poly_sel;
// determine
reg [4:0]   prod_03;
reg [4:0]   prod_12;
reg [4:0]       det;
reg [4:0] term[0:3];
// element
reg [4:0] your[0:3];
reg [4:0] gold[0:3];

reg [4:0] a;
reg [4:0] b;
reg [4:0] c;

//================================================================
//      POLY TABLE
//================================================================
// DEG = 2
parameter poly3   =   5'b111; //pat=0

// DEG = 3
parameter poly4_1 =  5'b1011; //pat=1
parameter poly4_2 =  5'b1101; //pat=2

// DEG = 4
parameter poly5_1 = 5'b10011; //pat=3
parameter poly5_2 = 5'b11001; //pat=4

// DEG = 5
parameter poly6_1  = 6'b100101; //pat=5
parameter poly6_2  = 6'b101001; //pat=6
parameter poly6_3  = 6'b101111; //pat=7
parameter poly6_4  = 6'b110111; //pat=8
parameter poly6_5  = 6'b111011; //pat=9
parameter poly6_6  = 6'b111101; //pat=10

parameter deg_2   = 2;
parameter deg_3   = 3;
parameter deg_4   = 4;
parameter deg_5   = 5;

//======================================
//      PARAMETERS & VARIABLES
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
    for ( pat_p=PAT_S ; pat_p<PAT_E ; pat_p=pat_p+1 ) begin
        field_task;
        for ( pat0=0 ; pat0<size ; pat0=pat0+1 ) begin
            for ( pat1=0 ; pat1<size ; pat1=pat1+1 ) begin
                for ( pat2=0 ; pat2<size ; pat2=pat2+1 ) begin
                    for ( pat3=0 ; pat3<size ; pat3=pat3+1 ) begin
                        input_task;
                        wait_task;
                        check_task;
                    end
                    //if ( pat2==0 && pat3==0 ) $finish;
                end
                //if ( pat1==3 ) $finish;
            end
        end
        //if ( pat_p==2 ) $finish;
    end
   /* 
    for ( pat_p=0 ; pat_p<5 ; pat_p=pat_p+1 ) begin
        field_task;
        for ( pat0=0 ; pat0<size ; pat0=pat0+1 ) begin 
            for ( pat1=1 ; pat1<size ; pat1=pat1+1 ) begin
                a = pat0;
                b = pat1;
                c = div_fun( a, b );
                $display("%d/%d=\033[1;31m%d\033[1;0m",a, b, c); 
            end
        end
    end*/
    pass_task;
    $finish;

end endtask

task reset_task; begin
    force clk = 0;
    rst_n     = 1;
    in_valid  = 0;
    in_data   = 4'dx;
    deg       = 3'dx;
    poly      = 5'dx;

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

task field_task; begin
    if (pat_p==0)      deg_sel=3'd2;
    else if (pat_p==1) deg_sel=3'd3;
    else if (pat_p==2) deg_sel=3'd3;
    else if (pat_p==3) deg_sel=3'd4;
    else if (pat_p==4) deg_sel=3'd4;
    else               deg_sel=3'd5;

    if (pat_p==0)       poly_sel=  poly3;
    else if (pat_p==1)  poly_sel=poly4_1;
    else if (pat_p==2)  poly_sel=poly4_2;
    else if (pat_p==3)  poly_sel=poly5_1;
    else if (pat_p==4)  poly_sel=poly5_2;
    else if (pat_p==5)  poly_sel=poly6_1;
    else if (pat_p==6)  poly_sel=poly6_2;
    else if (pat_p==7)  poly_sel=poly6_3;
    else if (pat_p==8)  poly_sel=poly6_4;
    else if (pat_p==9)  poly_sel=poly6_5;
    else                poly_sel=poly6_6;
    
    if (pat_p==0)      size= 4;
    else if (pat_p==1) size= 8;
    else if (pat_p==2) size= 8;
    else if (pat_p==3) size=16;
    else if (pat_p==4) size=16;
    else               size=32;

end endtask

task input_task; begin
    repeat(2) @(negedge clk);
    for ( i=0 ; i<4 ; i=i+1 ) begin
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
            repeat(5) @(negedge clk);
            $finish;
        end
        if(i==0) begin
            in_data =     pat0;
            data[0] =     pat0;
            deg     =  deg_sel;
            poly    = poly_sel;
        end     
        else if(i==1) begin
            in_data = pat1;
            data[1] = pat1;
            deg     =  'dx;
            poly    =  'dx;
        end 
        else if(i==2) begin
            in_data = pat2;
            data[2] = pat2;
            deg     =  'dx;
            poly    =  'dx;            
        end 
        else begin
            in_data = pat3;
            data[3] = pat3;
            deg     =  'dx;
            poly    =  'dx;            
        end
        @(negedge clk);     
    end

    in_valid=   0;
    in_data = 'dx;
    deg     = 'dx;
    poly    = 'dx;
    
    // Golden Output
    term[0] = data[3];
    term[1] = data[1];
    term[2] = data[2];
    term[3] = data[0];
    
    prod_03 = mul_fun( data[0], data[3] );
    prod_12 = mul_fun( data[1], data[2] );
    det     = sub_fun( prod_03, prod_12 );

    for ( m=0 ; m<4 ; m=m+1 ) begin
        if (det==0) gold[m] = 'd0;
        else        gold[m] = div_fun( term[m], det ); 
    end

end endtask

task wait_task; begin
    exe_lat = -1;
    while ( out_valid!==1 ) begin
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
            $display("    is over 5000 cycles       `:::--:/++:----------::/:.                ");                          
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
    // Check Output
    out_lat = 0;
    i = 0;
    while ( out_valid === 1 ) begin
    //for ( j=0; j<4 ; j=j+1) begin
        //$display("out_valid check : %d", out_lat );
        if (out_lat==4) begin
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
        
        if ( i<4 ) begin
            your[i] = out_data;
            i=i+1;
        end                    
       
        out_lat = out_lat + 1;
        @(negedge clk);
    end
    
    if (out_lat<4) begin     
        $display("                                                                                ");   
        $display("                                                   ./+oo+/.                     ");   
        $display("    Out cycles is less than 4                     /s:-----+s`     at %-12d ps   ",$time*1000);   
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
    
    for ( i=0 ; i<4 ; i=i+1 ) begin
        if ( your[i] !== gold[i] ) begin
            $display("...`...`....````````````````````````````````````````````````````...`````................   ");
            $display("................`````.```````````````````````````````````````````````.`...`................");
            $display(".............-/:.`.``````````````````````````````````````-///+++//+/-```...................");
            $display("..........```o::++/.```````````````````````````````````:o/::::::::::++.``..................");
            $display("............`o:-.`.::-``````````````````.:-```````````/+:::::::::::::/o``..................");
            $display("...........``o:.`````-/-`````````````-:/::/``````````.s/::::::::::::::y```.`...............");
            $display(".........```.:/-```````-/.````````.--``-:/```````````.y+/::::::::::::/o```````.............");
            $display("......`.....`.+:.````````:/.```...``` .::`````````````-+::::::::::::/o.```.`...............");
            $display(".........````..o:.`````````/-.-.``` `-/-```````````.:/++o+++///+osso/```````..``..`........");
            $display(".....`...```.``.o/:.````````-. `` `-/:..:::/+//++///::::::::::::::/+so/.```.``...`.........");
            $display("....```````````.o-.``````---   `.:/:..+ssoo+/:::::::::::::::::::::::://+o-.`..-/////++:....");
            $display("...`````````````//```:+o-  -:-///-```-o::::::::::::::::::::::::::::::::::o+.-o+:::::::+o-..");
            $display("...``````````````.:oyh+.`-/ohNh+:-.``:+os///::::::::::::::::::::::::::::::/yo:::::::::::s..");
            $display("...``````````````.hyyo/::--dNNNNy//++oyMN/o::::::::/os:::::::::::::::::::::s:::::::::::://.");
            $display("...`.`````````````--``````oNmmmmN/::::://+/::::::::::ss:::::::::::::::::::o/::::::::::::/+`");
            $display("...`.````````````````````.sNNmmNm:::::::::::::::::::::y/::::::::::::::::::o:::::::::::::+:`");
            $display("...``````````````````````++ohys+:::::::::::::::ohy::::s/::::::::::::::::::o+:::::::::::/o`.");
            $display("...``Your matrix`````````o/:::::::::::::::::::oMNs::::/::::::::::::::::::::/:::::::::/o/``.");
            $display("...``````````````````````/+::::::::::::::::::::/:::::::::::::::::::::::::::://///++++:.`...");
            $display("...```is incorrect!!````.s::::::::::::::::::::::::::::::::::::::::::::::::::::h/..`````.``");
            $display("...```````````````````````os::::::::::::::::::::::::::::::::::::::::::::::::::/y.``````````");
            $display("...```````````````````````/++:::::::::::::::::::::::::::::::::::::::::::::::::h-```.```````");
            $display("...````````````````````````o/++:::::::::/ss/:::::::::::::::::::::::::::::::::h:.``````````.");
            $display("...````````````````````````-o::++++/::/++//o/::::::::::::::::::::::::::::::/o-`..``.`.```..");
            $display("...`````````````````````````-o:::::/++/:::::::::::::::::::::::::::::::::::/o..`````..`.``..");
            $display("...``````````````````````````.+/:::::::::::::::::::::::::::::::::::::::::+o..```...........");
            $display("...````````````````````````````:o::::::::::::::::::::::::::::::::::::::::dy:.......`.``....");
            $display("...`````````````````````````````.o+::::::::::::::::::::::::::::::::::::/yhhds..............");
            $display("...```````````````````````````````+y/::::::::::::::::::::::::://+oosyhhhhhdy-....`....`....");
            $display("...``````````````````````````````-hyhs/::::::::::::::::/+osyyhhhyyyyyyyyyds.`....`.........");
            $display("...`````````````````````````````-ydyyyh+++//::::::/+oyhhhhyyyyyyyyyyyyyyyh`................");
            $display("...````````````````````````````-hhhyyyh::::/ooyhhhdhhhyyyyyyyyyyyyhyyyyyyho................");
            $display("...``````````````````````````-ohydyyyyd//oshdhhhhhyyyyyyyyyyyyyyhhyyyyyyyyhs:..............");
            $display("...````````````````````````-hhdyyhyyyyyhhyhyhyyyyyyyyyyyyyyyyyhhyyyyyyyyyyyhh+.............");
            $display("...````````````````````.://dhydyhhyyyyyyyyyyyyyyyyyyyyyyyyyyyhyyyyyyyyyyyyyyhhy-...........");
            $display("...```````````````-//+++/:/dhyhddyyyyyyyyyyyyyyyyyyyyyyyyyyyhyyyyyyyyyyyyyyyyyhh/..........");
            $display("...``````````.://+/::::::::dhyydyyyyyyyyyyyyyyyyyyyyyyyhyyyhyyyyyyyyyyyyyyhhhhhhds-........");
            $display("...``````.:///:::::::::::::shhdyyyyyyyyyyyyyyyyyyyyyyyyhyyhhyyyyyyyyyyyhhhhhhyyyhhhy:......");
            $display("...````-++//::::::::::::::/hhyhhhhhyyyyyyyyyyyyyyyyyyyyhyydyyyyyyyyyhhhyyhhyyyyyyyyyh+.....");
            $display("...``-o+/o/::::::::::::::shyyyyyyyyhhhhyyyyhyyyyyyyyyyyhyydyyyyyyyyhhyyyhyyyhyyyyyyyhh:....");
            $display("...`-o:/o:::::o/::::::::hhyyyyyyyyyyyyyyhhhhyhhhhyyyyyyyyyhyyyyyyyhyyhhhyysso+//:::::oy....");
            $display("...`o/:/o::::oo:::::::::+hyosyyyyyyyyyyyyyyyyyyyyyyyyyyyyyhyyyyyyhyyhhyyo//:::::::::::o+...");
            $display("...`/o:::++++:::::::::::oo::::/++osyyyyyyyyyyyyyyyyyyyyyyyyyyyyyydyyhyss/:::::::::::::/y...");
            $display("...`.s+::::::::::::/+++yo:::::::::::+osyhyyyyyyyyyyyyyyyyyhhhhyyyhyhhy/::::::::::::::::++..");
            $display("...``.++::::::/++/::-.o+:::::::::::::::::+osyhyyyyyyyyyyyyyyyhhhhdds+:::::::::::::::::::o`.");
            
            $display("Input matrix and determine:");
            for ( i=0 ; i<4 ; i=i+1 ) begin
                $write( "%d ", data[i] );
                if ( i==1 ) $display( " " );
            end
            $display("");
            $display("ditermine : %d", det);
              
            $display("Your matrix:");
            for ( i=0 ; i<4 ; i=i+1 ) begin
                if ( your[i] != gold[i] )
                    $write( "\033[1;31m%d \033[1;0m", your[i] );
                else
                    $write( "%d ", your[i] );
                if ( i==1 ) $display( " " );
            end
            $display("");
            
            $display("Golden matrix:");
            for ( i=0 ; i<4 ; i=i+1 ) begin
                if ( your[i] != gold[i] )
                    $write( "\033[1;31m%d \033[1;0m", gold[i] );
                else
                    $write( "%d ", gold[i] );
                if ( i==1 ) $display( " " );
            end
            $display("");

            repeat(5) @(negedge clk);
            $finish;
        end
    end
    if ( deg_sel==2 )      $display("\033[1;35mGF(4)  and poly index( %-2d ): %-2d %-2d %-2d %-2d  PATTERN PASS!!! \033[1;34mLatency : %-5d\033[1;0m",0       , pat0, pat1, pat2, pat3,  exe_lat);
    else if ( deg_sel==3 ) $display("\033[1;35mGF(8)  and poly index( %-2d ): %-2d %-2d %-2d %-2d  PATTERN PASS!!! \033[1;34mLatency : %-5d\033[1;0m",pat_p   , pat0, pat1, pat2, pat3,  exe_lat);
    else if ( deg_sel==4 ) $display("\033[1;35mGF(16) and poly index( %-2d ): %-2d %-2d %-2d %-2d  PATTERN PASS!!! \033[1;34mLatency : %-5d\033[1;0m",pat_p-2 , pat0, pat1, pat2, pat3,  exe_lat);
    else if ( deg_sel==5 ) $display("\033[1;35mGF(32) and poly index( %-2d ): %-2d %-2d %-2d %-2d  PATTERN PASS!!! \033[1;34mLatency : %-5d\033[1;0m",pat_p-4 , pat0, pat1, pat2, pat3,  exe_lat);
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
//======================================
//              FUNCTIONS
//======================================
function [4:0] add_fun;
    input[4:0] a;
    input[4:0] b;
    begin
        add_fun = a ^ b;
    end
endfunction

function [4:0] sub_fun;
    input[4:0] a;
    input[4:0] b;
    begin
        sub_fun = a ^ b;
    end
endfunction

function [9:0] mul_fun;
    input[4:0]    a;
    input[4:0]    b;
    reg  [9:0] temp;
    begin
        temp = 0;
        //$display("size : %-d", size);
        //$display("deg  : %-d", deg_sel);
        //$display("poly : %-d", poly_sel);
        for ( i=0 ; i<deg_sel ; i=i+1 ) begin
            for ( j=0 ; j<deg_sel ; j=j+1 ) begin
                temp[i+j] = temp[i+j] ^ (a[i] & b[j] );
            end
            //$display("Loop : %b", temp);
        end
        //$display("Out %b %d", temp, temp);
        
        if ( deg_sel==2 ) begin
            for ( i= 9 ; i>=1 ; i=i-1 ) begin
                if ( temp[i]==1 ) begin
                    temp[i-:3] = temp[i-:3] ^ poly_sel[2:0]; 
                end
            end
        end
        else if ( deg_sel==3 ) begin
            for ( i= 9 ; i>=2 ; i=i-1 ) begin
                if ( temp[i]==1 ) begin
                    temp[i-:4] = temp[i-:4] ^ poly_sel[3:0]; 
                end
            end
        end
        else if ( deg_sel==4 ) begin
            for ( i= 9 ; i>=3 ; i=i-1 ) begin
                if ( temp[i]==1 ) begin
                    temp[i-:5] = temp[i-:5] ^ poly_sel[4:0]; 
                end
            end
        end
        else if ( deg_sel==5 ) begin
            for ( i= 9 ; i>=4 ; i=i-1 ) begin
                if ( temp[i]==1 ) begin
                    temp[i-:6] = temp[i-:6] ^ poly_sel[5:0]; 
                end
            end
        end
        mul_fun = temp;
    end
endfunction

function [4:0] div_fun;
    input[4:0]     a, b;
    reg  [4:0]   mul;
    reg  [4:0] b_inv;
    reg     div_flag;
    begin
        b_inv    = 0;
        div_flag = 0;
        if ( a==0 ) begin
            div_fun = 0; 
        end
        else begin 
            while( div_flag==0 ) begin
               mul = 0;
               mul = mul_fun( b_inv, b );
               if ( mul==1 ) div_flag = 1;
               else          b_inv    = b_inv + 1'b1;
            end
            div_fun = mul_fun( a, b_inv );
        end
    end
endfunction

endmodule
