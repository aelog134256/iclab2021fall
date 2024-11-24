`ifdef RTL
    `define CYCLE_TIME 50.0
`endif

`ifdef GATE
    `define CYCLE_TIME 50.0
`endif


module PATTERN_IP(
    // Output signals
    POLY,
    IN1,
    IN2,
    // Input signals
    RESULT
);

//================================================================
//      I/O PORTS
//================================================================
parameter  DEG = 2, OP = 1;
output reg[DEG:0]     POLY;
output reg[DEG-1:0]    IN1;
output reg[DEG-1:0]    IN2;
input     [DEG-1:0] RESULT;

//================================================================
//      PARAMETERS & VARIABLES
//================================================================
parameter PATNUM = 500;
parameter CYCLE  = `CYCLE_TIME;
parameter POLY_NUM = 1;
// EXPLANATION :
// Please follow the example to select your POLY
// EX:
// If you want to select the poly8_15
// You should modify "DEG" to 7 in TESTBED
// And modify "POLY_NUM" to 15 in PATTERN
// Summary :
// poly8_15 ====> DEG = 7, POLY_NUM = 15

parameter DELAY  = 300 ;
integer   SEED   = 1208;


integer       i;
integer       j;
integer       k;
integer    pat1;
integer    pat2;
integer exe_lat;
integer out_lat;

//================================================================
//      REGISTER DECLARATION
//================================================================
reg                   clk;
reg [DEG:0]           max;
reg [2*DEG-1:0]       mul;
reg [DEG-1:0]     in2_inv;
reg              div_flag;
reg [DEG-1:0]        gold;


reg [31:0] operation;

//================================================================
//      POLY TABLE
//================================================================
// DEG = 1
parameter poly2    =    2'b11;

// DEG = 2
parameter poly3    =   3'b111;

// DEG = 3
parameter poly4_1  =  4'b1011;
parameter poly4_2  =  4'b1101;

// DEG = 4
parameter poly5_1  = 5'b10011;
parameter poly5_2  = 5'b11001;

// DEG = 5
parameter poly6_1  = 6'b100101;
parameter poly6_2  = 6'b101001;
parameter poly6_3  = 6'b101111;
parameter poly6_4  = 6'b110111;
parameter poly6_5  = 6'b111011;
parameter poly6_6  = 6'b111101;

// DEG = 6
parameter poly7_1  = 7'b1000011;
parameter poly7_2  = 7'b1011011;
parameter poly7_3  = 7'b1100001;
parameter poly7_4  = 7'b1100111;
parameter poly7_5  = 7'b1101101;
parameter poly7_6  = 7'b1110011;

// DEG = 7
parameter poly8_1  = 8'b10000011;
parameter poly8_2  = 8'b10001001;
parameter poly8_3  = 8'b10001111;
parameter poly8_4  = 8'b10010001;
parameter poly8_5  = 8'b10011101;
parameter poly8_6  = 8'b10100111;
parameter poly8_7  = 8'b10101011;
parameter poly8_8  = 8'b10111001;
parameter poly8_9  = 8'b10111111;
parameter poly8_10 = 8'b11000001;
parameter poly8_11 = 8'b11001011;
parameter poly8_12 = 8'b11010011;
parameter poly8_13 = 8'b11010101;
parameter poly8_14 = 8'b11100101;
parameter poly8_15 = 8'b11101111;
parameter poly8_16 = 8'b11110001;
parameter poly8_17 = 8'b11110111;
parameter poly8_18 = 8'b11111101;

// DEG = 8
parameter poly9_1  = 9'b100011011;
parameter poly9_2  = 9'b100011101;
parameter poly9_3  = 9'b100101011;
parameter poly9_4  = 9'b100101101;
parameter poly9_5  = 9'b101001101;
parameter poly9_6  = 9'b101011111;
parameter poly9_7  = 9'b101100011;
parameter poly9_8  = 9'b101100101;
parameter poly9_9  = 9'b101101001;
parameter poly9_10 = 9'b101110001;
parameter poly9_11 = 9'b110000111;
parameter poly9_12 = 9'b110001101;
parameter poly9_13 = 9'b110101001;
parameter poly9_14 = 9'b111000011;
parameter poly9_15 = 9'b111001111;
parameter poly9_16 = 9'b111100111;
parameter poly9_17 = 9'b111110101;


integer   poly_sel;
integer   poly_max;

//================================================================
//      CLOCK
//================================================================
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk;

//================================================================
//      MAIN
//================================================================
initial exe_total_task;
//initial exe_specify_task;

//================================================================
//      TASK DECLARATION
//================================================================
task exe_total_task; begin
    reset_task;
    for (poly_sel=0 ; poly_sel<poly_max ; poly_sel=poly_sel+1) begin
        for (pat1=0 ; pat1<max ; pat1=pat1+1) begin
            for (pat2=1 ; pat2<max ; pat2=pat2+1) begin
                data_task;
                if ( OP==0 )      add_task;
                else if ( OP==1 ) sub_task;
                else if ( OP==2 ) mul_task;
                else              div_task;
                check_task;
            end
        end
    end
    pass_task;
end endtask

task exe_specify_task; begin
    reset_task;
    specify_task;
    for (pat1=0 ; pat1<max ; pat1=pat1+1) begin
        for (pat2=1 ; pat2<max ; pat2=pat2+1) begin
            data_task;
            if ( OP==0 )      add_task;
            else if ( OP==1 ) sub_task;
            else if ( OP==2 ) mul_task;
            else              div_task;
            check_task;
        end
    end
    pass_task;
end endtask

task reset_task; begin
    force clk = 0;
    IN1 = 0;
    IN2 = 0;
    POLY = 0;

    max = 1;
    for ( i=0 ; i<DEG ; i=i+1 ) begin
        max = max*2;
    end

    case(DEG)
        1: poly_max = 1;
        2: poly_max = 1;
        3: poly_max = 2;
        4: poly_max = 2;
        5: poly_max = 6;
        6: poly_max = 6;
        7: poly_max = 18;
        8: poly_max = 17;
    endcase

    case(OP)
        0 : operation = "ADD";
        1 : operation = "SUB";
        2 : operation = "MULT";
        3 : operation = "DIV";
    endcase

    #(CYCLE);

    release clk;

end endtask

task specify_task; begin
    poly_sel = POLY_NUM-1;
end endtask

task data_task; begin
    @( negedge clk );
    IN1 = pat1; 
    IN2 = pat2; 

    case(DEG)
        1 : POLY = poly2;
        2 : POLY = poly3;
        3 : begin
           if ( poly_sel==0  ) POLY = poly4_1;
           else                POLY = poly4_2;
        end
        4 : begin 
           if ( poly_sel==0  ) POLY = poly5_1;
           else                POLY = poly5_2;
        end
        5 : begin
            case( poly_sel )
                0 : POLY = poly6_1;
                1 : POLY = poly6_2;
                2 : POLY = poly6_3;
                3 : POLY = poly6_4;
                4 : POLY = poly6_5;
                5 : POLY = poly6_6;
                default : POLY = poly6_1;
            endcase
        end
        6 : begin
            case( poly_sel )
                0 : POLY = poly7_1;
                1 : POLY = poly7_2;
                2 : POLY = poly7_3;
                3 : POLY = poly7_4;
                4 : POLY = poly7_5;
                5 : POLY = poly7_6;
                default : POLY = poly7_1;
            endcase
        end
        7 : begin
            case( poly_sel )
                0  : POLY = poly8_1;
                1  : POLY = poly8_2;
                2  : POLY = poly8_3;
                3  : POLY = poly8_4;
                4  : POLY = poly8_5;
                5  : POLY = poly8_6;
                6  : POLY = poly8_7;
                7  : POLY = poly8_8;
                8  : POLY = poly8_9;
                9  : POLY = poly8_10;
                10 : POLY = poly8_11;
                11 : POLY = poly8_12;
                12 : POLY = poly8_13;
                13 : POLY = poly8_14;
                14 : POLY = poly8_15;
                15 : POLY = poly8_16;
                16 : POLY = poly8_17;
                17 : POLY = poly8_18;
                default : POLY = poly8_1;
            endcase
        end
        8 : begin
            case( poly_sel )
                0  : POLY = poly9_1;
                1  : POLY = poly9_2;
                2  : POLY = poly9_3;
                3  : POLY = poly9_4;
                4  : POLY = poly9_5;
                5  : POLY = poly9_6;
                6  : POLY = poly9_7;
                7  : POLY = poly9_8;
                8  : POLY = poly9_9;
                9  : POLY = poly9_10;
                10 : POLY = poly9_11;
                11 : POLY = poly9_12;
                12 : POLY = poly9_13;
                13 : POLY = poly9_14;
                14 : POLY = poly9_15;
                15 : POLY = poly9_16;
                16 : POLY = poly9_17;
                default : POLY = poly9_1;
            endcase
        end
    endcase

end endtask
    
task add_task; begin
    gold = IN1 ^ IN2;     
end endtask

task sub_task; begin
    gold = IN1 ^ IN2;  
end endtask

task mul_task; begin 
    gold = mul_fun( IN1, IN2 );
end endtask

task div_task; begin
    in2_inv = 0;
    div_flag = 0;
    while( div_flag==0 ) begin
        mul = 0;
        mul = mul_fun( in2_inv, IN2 );
        if ( mul==1 ) div_flag=1;
        else          in2_inv = in2_inv + 1'b1;
    end
    if ( IN1==0 ) gold=0;
    else          gold = mul_fun( IN1, in2_inv );
    
end endtask

function [2*DEG-1:0] mul_fun;
    input[DEG-1:0]    a;
    input[DEG-1:0]    b;
    reg[2*DEG-1:0] temp;
    begin
        temp = 0;
        for ( i=0 ; i<DEG ; i=i+1 ) begin
            for ( j=0 ; j<DEG ; j=j+1 ) begin
                temp[i+j] = temp[i+j] ^ (a[i] & b[j] );
            end
        end

        for ( i= 2*DEG-1 ; i>=DEG-1 ; i=i-1 ) begin
            if ( temp[i]==1 ) begin
                temp[i-:DEG+1] = temp[i-:DEG+1] ^ POLY[DEG:0]; 
            end
        end
        mul_fun = temp;
    end
endfunction


task check_task; begin
    @(posedge clk);
    if ( RESULT !== gold ) begin
        $display("\033[1;33m                                                                                                    ");   
        $display("\033[1;33m                                                   ./+oo+/.                                         ");   
        $display("\033[1;36m    Your Soft IP output is not correct\033[1;33m            /s:-----+s`                             ");   
        $display("\033[1;33m                                                  y/-------:y                                       ");   
        $display("\033[1;33m                                             `.-:/od+/------y`                                      ");   
        $display("\033[1;33m                               `:///+++ooooooo+//::::-----:/y+:`                                    ");   
        $display("\033[1;33m                              -m+:::::::---------------------::o+.                                  ");   
        $display("\033[1;33m                             `hod-------------------------------:o+                                 ");   
        $display("\033[1;33m                       ./++/:s/-o/--------------------------------/s///::.                          ");   
        $display("\033[1;33m                      /s::-://--:--------------------------------:oo/::::o+                         ");   
        $display("\033[1;33m                    -+ho++++//hh:-------------------------------:s:-------+/                        ");   
        $display("\033[1;33m                  -s+shdh+::+hm+--------------------------------+/--------:s                        ");   
        $display("\033[1;33m                 -s:hMMMMNy---+y/-------------------------------:---------//                        ");   
        $display("\033[1;33m                 y:/NMMMMMN:---:s-/o:-------------------------------------+`                        ");   
        $display("\033[1;33m                 h--sdmmdy/-------:hyssoo++:----------------------------:/`                         ");   
        $display("\033[1;33m                 h---::::----------+oo+/::/+o:---------------------:+++s-`                          ");   
        $display("\033[1;33m                 s:----------------/s+///------------------------------o`                           ");   
        $display("\033[1;33m           ``..../s------------------::--------------------------------o                            ");   
        $display("\033[1;31m       -/oyhyyyyyym:\033[1;33m----------------://////:--------------------------:/                  ");   
        $display("\033[1;31m      /dyssyyyssssyh:\033[1;33m-------------/o+/::::/+o/------------------------+`                  ");   
        $display("\033[1;33m    -+o/---:\033[1;31m/oyyssshd/\033[1;33m-----------+o:--------:oo---------------------:/.         ");   
        $display("\033[1;33m  `++--------\033[1;31m:/sysssdd\033[1;33my+:-------/+------------s/------------------://`          ");   
        $display("\033[1;33m .s:---------:\033[1;31m+ooyysyydd\033[1;33moo++os-:s-------------/y----------------:++.            ");   
        $display("\033[1;33m s:------------\033[1;31m/yyhssyshy:\033[1;33m---/:o:-------------:dsoo++//:::::-::+syh`            ");   
        $display("\033[1;33m`h--------------\033[1;31mshyssssyyms+oy\033[1;33mo:--------------\033[1;31m/hyyyyyyyyyyyysyhyyyy`  ");   
        $display("\033[1;33m`h--------------:\033[1;31myyssssyyhhyy\033[1;33m+----------------+\033[1;31mdyyyysssssssyyyhs+/.   ");   
        $display("\033[1;33m s:--------------\033[1;31m/yysssssyhy\033[1;33m:-----------------\033[1;31mshyyyyyhyyssssyyh.      ");   
        $display("\033[1;33m .s---------------+\033[1;31msooosyyo\033[1;33m------------------\033[1;31m/yssssssyyyyssssyo       ");   
        $display("\033[1;33m  /+-------------------:++------------------:\033[1;31mysssssssssssssssy-                           ");   
        $display("\033[1;33m  `s+--------------------------------------:\033[1;31msyssssssssssssssyo                            ");   
        $display("\033[1;31m`+yhdo\033[1;33m--------------------:/--------------:\033[1;31msyssssssssssssssyy.                  ");   
        $display("\033[1;31m+yysyhh:\033[1;33m-------------------+o------------\033[1;31m/ysyssssssssssssssy/                   ");   
        $display(" \033[1;31m/hhysyds:\033[1;33m------------------y-----------\033[1;31m/+yyssssssssssssssyh`                   ");   
        $display("\033[1;33m .h-\033[1;31m+yysyds:\033[1;33m---------------:s----------:--\033[1;31m/yssssssssssssssym:         ");   
        $display("\033[1;33m y/---\033[1;31moyyyyhyo:\033[1;33m-----------:o:-------------:\033[1;31mysssssssssyyyssyyd-        ");   
        $display("\033[1;33m`h------\033[1;31m+syyyyhhsoo+///+osh\033[1;33m---------------:\033[1;31mysssyysyyyyysssssyd:       ");   
        $display("\033[1;33m/s--------:\033[1;31m+syyyyyyyyyyyyyyhso/:\033[1;33m-------::\033[1;31m+oyyyyhyyyysssssssyy+-       ");   
        $display("\033[1;33m+s-----------:\033[1;31m/osyyysssssssyyyyhyyyyyyyydhyyyyyyssssssssyys/\033[1;33m`                   ");   
        $display("\033[1;33m+s---------------:\033[1;31m/osyyyysssssssssssssssyyhyyssssssyyyyso/y\033[1;33m`                    ");   
        $display("\033[1;33m/s--------------------:\033[1;31m/+ossyyyyyyssssssssyyyyyyysso+\033[1;33m:----:+                    ");   
        $display("\033[1;33m.h--------------------------:::\033[1;31m/++oooooooo+++/\033[1;33m:::----------o`                   ");
        if (OP==0)     $display("\033[1;36mThe operation is ADDITION                                                   \033[1;0m");
        else if(OP==1) $display("\033[1;36mThe operation is SUBSTRACTION                                               \033[1;0m");
        else if(OP==2) $display("\033[1;36mThe operation is MULTIPLICATION                                             \033[1;0m");
        else           $display("\033[1;36mThe operation is DIVISION                                                   \033[1;0m");
        $display("\033[1;36mThe IN1     is : %d                                                                        \033[1;0m", IN1);
        $display("\033[1;36mThe IN2     is : %d                                                                        \033[1;0m", IN2);
        $display("\033[1;36mThe POLY    is : %b                                                                        \033[1;0m", POLY);
        $display("\033[1;34mYour output is : %d                                                                        \033[1;0m", RESULT);
        $display("\033[1;34mGold output is : %d                                                                        \033[1;0m", gold  );
        repeat(5) @(negedge clk);
        //$finish;
    end
    $display("\033[1;35mPATTERN PASS!!!\033[1;34m Degree : %-1d | Operation : %-s | POLY %-1d_%-2d : %-10b | IN1 : %-3d | IN2 : %-3d\033[1;0m", DEG, operation, DEG+1, poly_sel+1, POLY, pat1, pat2 );     
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
