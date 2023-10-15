`timescale 1ns / 1ps

module apb4_rtc_tb ();
  reg rst_n;
  reg clk_25m;
  always #20.000 clk_25m <= ~clk_25m;

  initial begin
    clk_25m = 1'b0;
    rst_n   = 1'b0;
    // wait for a while to release reset signal
    // repeat (4096) @(posedge clk_25m);
    repeat (40) @(posedge clk_25m);
    #100 rst_n = 1;
  end

  initial begin
    if ($test$plusargs("dump_fst_wave")) begin
      $dumpfile("apb4_rtc_tb.wave");
      $dumpvars(0, apb4_rtc_tb);
      $display("sim 4000ns");
      #4000 $finish;
    end else if ($test$plusargs("default_args")) begin
      $display("=========sim default args===========");
      $display("sim 11000ns");
      #11000 $finish;
    end
  end

  apb4_rtc u_apb4_rtc(
    .rtc_clk_i(clk_25m),
    .rtc_rst_n_i(rst_n)
  );
endmodule
