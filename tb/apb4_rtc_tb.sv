`timescale 1ns / 1ps

module apb4_rtc_tb();
  reg rst_n;
  reg clk_25m;
  always #20.000 clk_25m <= ~clk_25m;

  initial begin
    $display("hello world");
    $finish;
  end
endmodule