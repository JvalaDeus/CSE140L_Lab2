// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,
               tday,
               aday,						 
  output logic buzz
);

  always_comb begin
    if (alarmon && (tday != aday) && (tday != (aday + 1) % 7) &&
        (tmin == amin) && (thrs == ahrs)) begin
      buzz = 1;
    end else begin
      buzz = 0;
    end
  end
endmodule