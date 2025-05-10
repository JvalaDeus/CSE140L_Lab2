module Top_Level #(parameter int NS=60, parameter int NH=24, parameter int ND=7, parameter int NM=12)(
  input Reset,
        Timeset,
        Alarmset,
        Minadv,
        Hrsadv,
        Dayadv,
        Alarmon,
        Datadv,
        Monadv,
        Pulse,
  output [6:0] S1disp, S0disp,
              M1disp, M0disp,
              H1disp, H0disp,
                      D0disp,
              T1disp, T0disp,
              N1disp, N0disp,
  output logic Buzz);

  localparam int yr = 2024;

  logic [6:0] TSec, TMin, THrs, TDay;
  logic [6:0] AMin, AHrs, ADay;
  logic [6:0] Min, Hrs, Day;
  logic [5:0] TDate, ADate, Date_disp, max_days;
  logic [3:0] TMonth, AMonth, Month_disp;
  logic S_max, M_max, H_max, D_max;
  logic TMen, THen, TDen;
  logic AMen, AHen, ADen, ADateen, AMonen;
  logic alarm_trigger;
  logic date_rollover;

  assign TMen = (Timeset & Minadv) | (!Timeset & S_max);
  assign THen = (Timeset & Hrsadv) | (!Timeset & S_max & M_max);
  assign TDen = Timeset ? Dayadv : (S_max & M_max & H_max);

  assign AMen    = Alarmset & Minadv;
  assign AHen    = Alarmset & Hrsadv;
  assign ADen    = Alarmset & Dayadv;
  assign ADateen = Alarmset & Datadv;
  assign AMonen  = Alarmset & Monadv;

  assign Min  = Alarmset ? AMin   : TMin;
  assign Hrs  = Alarmset ? AHrs   : THrs;
  assign Day  = Alarmset ? ADay   : TDay;
  assign Date_disp  = Alarmset ? ADate  : TDate;
  assign Month_disp = Alarmset ? AMonth : TMonth;

  always_comb begin
    unique case (TMonth)
      4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12: max_days = 31;
      4'd4,4'd6,4'd9,4'd11:               max_days = 30;
      default:                           max_days = ( (yr%400==0) || (yr%4==0 && yr%100!=0) ) ? 29 : 28;
    endcase
    date_rollover = (TDate == max_days);
  end

  always_ff @(posedge Pulse or posedge Reset) begin
    if (Reset) begin
      TDate  <= 6'd1;
      TMonth <= 4'd1;
    end else if (Timeset && Datadv) begin
      if (TDate == max_days)
        TDate <= 1;
      else
        TDate <= TDate + 1;
    end else if (Timeset && Monadv) begin
      if (TMonth == 12)
        TMonth <= 1;
      else
        TMonth <= TMonth + 1;
    end else if (!Timeset && S_max && M_max && H_max) begin
      if (date_rollover) begin
        TDate <= 1;
        TMonth <= (TMonth == 12) ? 1 : TMonth + 1;
      end else begin
        TDate <= TDate + 1;
      end
    end
  end

  ct_mod_N Sct (.clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(7'(NS)), .ct_out(TSec), .ct_max(S_max));
  ct_mod_N Mct (.clk(Pulse), .rst(Reset), .en(TMen),     .modulus(7'(NS)), .ct_out(TMin), .ct_max(M_max));
  ct_mod_N Hct (.clk(Pulse), .rst(Reset), .en(THen),     .modulus(7'(NH)), .ct_out(THrs), .ct_max(H_max));
  ct_mod_N Dct (.clk(Pulse), .rst(Reset), .en(TDen),     .modulus(7'(ND)), .ct_out(TDay), .ct_max(D_max));

  ct_mod_N Mreg (.clk(Pulse), .rst(Reset), .en(AMen),     .modulus(7'(NS)), .ct_out(AMin), .ct_max());
  ct_mod_N Hreg (.clk(Pulse), .rst(Reset), .en(AHen),     .modulus(7'(NH)), .ct_out(AHrs), .ct_max());
  ct_mod_N Dreg (.clk(Pulse), .rst(Reset), .en(ADen),     .modulus(7'(ND)), .ct_out(ADay), .ct_max());
  ct_mod_N DRreg(.clk(Pulse), .rst(Reset), .en(ADateen),  .modulus(6'd31),  .ct_out(ADate), .ct_max());
  ct_mod_N MRreg(.clk(Pulse), .rst(Reset), .en(AMonen),   .modulus(4'd12),  .ct_out(AMonth), .ct_max());

  lcd_int Sdisp (.bin_in(TSec),        .Segment1(S1disp), .Segment0(S0disp));
  lcd_int Mdisp (.bin_in(Min),         .Segment1(M1disp), .Segment0(M0disp));
  lcd_int Hdisp (.bin_in(Hrs),         .Segment1(H1disp), .Segment0(H0disp));
  lcd_int Ddisp (.bin_in(Day),         .Segment1(),       .Segment0(D0disp));
  lcd_int Tdisp (.bin_in({1'b0, Date_disp}),  .Segment1(T1disp), .Segment0(T0disp));
  lcd_int Ndisp (.bin_in({3'b000, Month_disp}), .Segment1(N1disp), .Segment0(N0disp));

  alarm a1(.tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tday(TDay), .aday(ADay), .buzz(alarm_trigger));

  assign Buzz = alarm_trigger & Alarmon;
endmodule
