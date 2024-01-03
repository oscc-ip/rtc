// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rtc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.sv"
`include "rtc_define.sv"

module apb4_rtc_tb ();
  localparam CLK_PEROID = 10;
  localparam RTC_CLK_PEROID = 40;  // for sim

  logic rst_n_i, clk_i;
  logic rtc_rst_n_i, rtc_clk_i;

  initial begin
    clk_i = 1'b0;
    forever begin
      #(CLK_PEROID / 2) clk_i <= ~clk_i;
    end
  end

  initial begin
    rtc_clk_i = 1'b0;
    forever begin
      #(RTC_CLK_PEROID / 2) rtc_clk_i <= ~rtc_clk_i;
    end
  end

  task sim_reset(int delay);
    rst_n_i = 1'b0;
    repeat (delay) @(posedge clk_i);
    #1 rst_n_i = 1'b1;
  endtask

  task rtc_sim_reset(int delay);
    rtc_rst_n_i = 1'b0;
    repeat (delay) @(posedge rtc_clk_i);
    #1 rtc_rst_n_i = 1'b1;
  endtask

  initial begin
    sim_reset(40);
  end

  initial begin
    rtc_sim_reset(60);
  end

  apb4_if u_apb4_if (
      clk_i,
      rst_n_i
  );

  rtc_if u_rtc_if (
      rtc_clk_i,
      rtc_rst_n_i
  );

  test_top u_test_top (
      .apb4(u_apb4_if.master),
      .rtc (u_rtc_if.tb)
  );
  apb4_rtc u_apb4_rtc (
      .apb4(u_apb4_if.slave),
      .rtc (u_rtc_if.dut)
  );

endmodule
