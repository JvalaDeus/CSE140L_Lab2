// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,						 
  output logic buzz
);

  always_comb
    buzz = (tmin == amin) && (thrs == ahrs);
    /* fill in the guts:
	buzz = 1 when tmin and thrs match amin and ahrs, respectively */

endmodule