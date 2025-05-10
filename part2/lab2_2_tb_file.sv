// testbench for lab2 part 2 -- alarm clock
// days, hours, minutes, and seconds
`include "lab2_2_display_tb_file.sv"
module lab2_2_tb_file #(parameter NS = 60, NH = 24);
  bit   Reset    = 1,
        Timeset     ,
        Alarmset    ,
		Minadv      ,
		Hrsadv      ,
        Dayadv      ,
		Alarmon  = 1,
		Pulse       ;

  wire[6:0] S1disp, S0disp,
            M1disp, M0disp,
            H1disp, H0disp, D0disp;
  wire Buzz;

  Top_Level sd(.Reset   (Reset   ),   // our DUT itself 
               .Pulse   (Pulse   ),
               .Timeset (Timeset ),
               .Alarmset(Alarmset),
               .Minadv  (Minadv  ),
               .Hrsadv  (Hrsadv  ),
               .Dayadv  (Dayadv  ),
               .Alarmon (Alarmon ),
               .S1disp            ,
               .S0disp            ,
               .M1disp            ,
               .M0disp            ,
               .H1disp            ,
               .H0disp            ,
               .D0disp            ,
               .Buzz              );         
  

  initial begin
    
    $monitor("buzz = %b  at time %t",Buzz,$time);
	#  2us  Reset    = 'b0;
	#  1us  Timeset  = 'b1;	 // set clock (real) time
	        Minadv   = 'b1;
	# 59us  Minadv   = 'b0;  // 59 minutes
	        Hrsadv   = 'b1;
	#  7us  Hrsadv   = 'b0;  // 7 hours
	        Timeset  = 'b0;	 // day defaults to 0
	$display("time should read day=0, time = 07:59");
//	force (.sd.Min = 'h5);
//	release(.sd.Min);
    lab2_2_display_tb_file (.seg_j(D0disp), .seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .Buzz(Buzz));
	#  1us  Alarmset = 'b1;	// set alarm time
	        Hrsadv   = 'b1;
	#  8us  Hrsadv   = 'b0;	// 8 hrs
	        Minadv   = 'b1;
	#  2us  Minadv   = 'b0;	// 2 min
	        Dayadv   = 'b1;	
	#  6us  Dayadv   = 'b0;	// day 6
    $display("alarm should read day=6, time = 08:02");
	        Alarmset = 'b0;
    lab2_2_display_tb_file (.seg_j(D0disp), .seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .Buzz(Buzz));
	fork
    for(int i=0; i<164; i++) 
	# 10us  lab2_2_display_tb_file (.seg_j(D0disp), .seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp),.Buzz(Buzz));
	begin
	  #400us Alarmset = 'b1;
	         Minadv   = 'b1;
			 Dayadv   = 'b1;
	  #  3us Dayadv   = 'b0;	  // day 1
	  #  5us Minadv   = 'b0;	  // min 08
	         Alarmset = 'b0;
	  $display("alarm should read day = 1, time = 08:10");
	end
  	join
  	#1000us  $stop;
  end 
  always begin
    #500ns Pulse = 'b1;
	#500ns Pulse = 'b0;
  end

endmodule