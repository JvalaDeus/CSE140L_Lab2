// 1. convert binary to binary coded decimal 
// 2. convert BCD to 7-segment LED/LCD/etc. display
module lcd_int(
  input[6:0] bin_in,
  output logic [6:0] Segment1,
                     Segment0);

  logic[3:0] bin0;			  // binary to binary coded decimal (BCD)
  logic[3:0] bin1;          // tens digit

  // Improve handling of binary to BCD conversion
  always_comb begin
    if (bin_in < 100) begin
      bin0 = bin_in % 10;    // ones digit (0-9)
      bin1 = bin_in / 10;    // tens digit (0-9)
    end else begin
      // For values >= 100, display modulo 100
      bin0 = bin_in % 10;
      bin1 = (bin_in / 10) % 10;
    end
  end
  
// mapping of BCD to 7-segment layout
// 7-segment display bit positions:
//      0
//    5   1
//      6
//    4   2
//      3
  always_comb case(bin0) 
    4'b0000 : Segment0 = 7'b1111110; // 0: segments 0,1,2,3,4,5 on
    4'b0001 : Segment0 = 7'b0110000; // 1: segments 1,2 on
    4'b0010 : Segment0 = 7'b1101101; // 2: segments 0,1,3,4,6 on
    4'b0011 : Segment0 = 7'b1111001; // 3: segments 0,1,2,3,6 on
    4'b0100 : Segment0 = 7'b0110011; // 4: segments 1,2,5,6 on
    4'b0101 : Segment0 = 7'b1011011; // 5: segments 0,2,3,5,6 on
    4'b0110 : Segment0 = 7'b1011111; // 6: segments 0,2,3,4,5,6 on
    4'b0111 : Segment0 = 7'b1110000; // 7: segments 0,1,2 on
    4'b1000 : Segment0 = 7'b1111111; // 8: all segments on
    4'b1001 : Segment0 = 7'b1111011; // 9: segments 0,1,2,3,5,6 on
    default : Segment0 = 7'b0000000; // all segments off for invalid values
  endcase

  always_comb case(bin1) 
    4'b0000 : Segment1 = 7'b1111110; // 0
    4'b0001 : Segment1 = 7'b0110000; // 1
    4'b0010 : Segment1 = 7'b1101101; // 2
    4'b0011 : Segment1 = 7'b1111001; // 3
    4'b0100 : Segment1 = 7'b0110011; // 4
    4'b0101 : Segment1 = 7'b1011011; // 5
    4'b0110 : Segment1 = 7'b1011111; // 6
    4'b0111 : Segment1 = 7'b1110000; // 7
    4'b1000 : Segment1 = 7'b1111111; // 8
    4'b1001 : Segment1 = 7'b1111011; // 9
    default : Segment1 = 7'b0000000; // all segments off for invalid values
  endcase

endmodule