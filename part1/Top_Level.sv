// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module Top_Level #(parameter NS=60, NH=24)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Alarmon,
		Pulse,		  // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
//                       D0disp,   // for part 2
  output logic Buzz);	           // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs,     // clock/time 
             AMin, AHrs;		   // alarm setting
  logic[6:0] Min, Hrs;
  logic S_max, M_max, H_max, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen; 
  logic alarm_trigger;             // alarm internal trigger signal

// set control logic - revised based on component specifications
  assign TMen = (Timeset & Minadv) | (!Timeset & S_max);  // Minute counter enable
  assign THen = (Timeset & Hrsadv) | (!Timeset & S_max & M_max);  // Hour counter enable - increment when both sec & min are max
  assign AMen = Alarmset & Minadv;           // Alarm minute setting enable
  assign AHen = Alarmset & Hrsadv;           // Alarm hour setting enable
  
// Time or alarm display selection
  assign Min = Alarmset? AMin : TMin;        // Display minutes (time or alarm)
  assign Hrs = Alarmset? AHrs : THrs;        // Display hours (time or alarm)

// (almost) free-running seconds counter	-- be sure to set modulus inputs on ct_mod_N modules
  ct_mod_N  Sct(
// input ports
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(7'(NS)),
// output ports    
    .ct_out(TSec), .ct_max(S_max));

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
// input ports     
    .clk(Pulse), .rst(Reset), .en(TMen), .modulus(7'(NS)),
// output ports
    .ct_out(TMin), .ct_max(M_max));

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Hct(
// input ports
	.clk(Pulse), .rst(Reset), .en(THen), .modulus(7'(NH)),
// output ports
    .ct_out(THrs), .ct_max(H_max));

// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AMen), .modulus(7'(NS)),
// output ports    
    .ct_out(AMin), .ct_max()  ); 

  ct_mod_N  Hreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AHen), .modulus(7'(NH)),
// output ports    
    .ct_out(AHrs), .ct_max() ); 

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(					  // seconds display
    .bin_in    (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in    (Min),
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in    (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .buzz(alarm_trigger)
	);
	
// Enable/disable alarm based on Alarmon setting
  assign Buzz = alarm_trigger & Alarmon;

endmodule