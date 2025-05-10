// CSE140L  
// What does this do? 
// How long does "ct_max" stay high? 
module ct_mod_N (
  input             clk, 
                    rst, 	   // synchronous reset ct_out to 0
                    en,		   // enables ct_out increment; else hold
  input       [6:0] modulus,   // counter runs 0 to modulus-1      
  output logic[6:0] ct_out,	   // counter accumulator and output 
  output logic      ct_max);   // goes high when ct_out = modulus-1

  always_ff @(posedge clk)	 begin :clk_loop
    if(rst)	begin      :reset_loop
	  ct_out <= 'b0;
	end			       :reset_loop
	else if(en)	begin  :inc_loop
      if(ct_out == modulus-1) ct_out <= 'b0;
	  else                    ct_out <= ct_out + 'b1;
    end				   :inc_loop
//    else
//   	  ct_out <= ct_out;  // hold; don't enable	 
  end	  :clk_loop

  always_comb begin ct_max = ct_out==(modulus-1); end  // always @(*)   // always @(ct_out)

endmodule



/*
 always_ff @(posedge clk)
    if(rst)
	  ct_out <= 0;
	else if(en)
	  ct_out <= ct_out_next;
//    else
//	  ct_out <= ct_out;

  always_comb	  
	 ct_out = (ct_out+1)%N;	


  always_ff @(posedge clk)
    if(rst)
	  ct_out <= 'd0;
	else
	  ct_out <= ct_out_next;


  always_comb	  
	 ct_out_next = en? (ct_out+1)%N : ct_out;	



  month counter    count_N   mod 12   0, 1, 2, ..., 11
						 mon0 + 1 = month
                                      1, 2, 3, ..., 12

*/