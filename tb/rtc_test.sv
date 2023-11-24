// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rtc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_RTC_TEST_SV
`define INC_RTC_TEST_SV

`include "apb4_master.sv"
`include "rtc_define.sv"

class RTCTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual rtc_if.tb      rtc;

  extern function new(string name = "pwm_test", virtual apb4_if.master apb4, virtual rtc_if.tb rtc);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_clk_div(input bit [31:0] run_times = 10);
  extern task automatic test_inc_cnt(input bit [31:0] run_times = 10);
  extern task automatic test_irq(input bit [31:0] run_times = 10);
endclass

function RTCTest::new(string name, virtual apb4_if.master apb4, virtual rtc_if.tb rtc);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.rtc    = rtc;
endfunction

task automatic RTCTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`RTC_CTRL_ADDR, "CTRL REG", 32'b0 & {`RTC_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_PSCR_ADDR, "PSCR REG", 32'b0 & {`RTC_PSCR_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_ALRM_ADDR, "ALRM REG", 32'b0 & {`RTC_ALRM_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_ISTA_ADDR, "ISTA REG", 32'b0 & {`RTC_ISTA_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_SSTA_ADDR, "SSTA REG", 32'b0 & {`RTC_SSTA_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic RTCTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    // this.wr_rd_check(`PWM_CTRL_ADDR, "CTRL REG", $random & {`PWM_CTRL_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic RTCTest::test_clk_div(input bit [31:0] run_times = 10);
  $display("=== [test rtc clk div] ===");
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`PWM_PSCR_ADDR, 32'd10 & {`PWM_PSCR_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`PWM_PSCR_ADDR, 32'd4 & {`PWM_PSCR_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // for (int i = 0; i < run_times; i++) begin
  //   this.wr_val = ($random % 20) & {`PWM_PSCR_WIDTH{1'b1}};
  //   if (this.wr_val < 2) this.wr_val = 2;
  //   if (this.wr_val % 2) this.wr_val -= 1;
  //   this.wr_rd_check(`PWM_PSCR_ADDR, "PSCR REG", this.wr_val, Helper::EQUL);
  //   repeat (200) @(posedge this.apb4.pclk);
  // end
endtask

task automatic RTCTest::test_inc_cnt(input bit [31:0] run_times = 10);
  $display("=== [test rtc inc cnt] ===");
  // this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  // this.write(`PWM_PSCR_ADDR, 32'd4 & {`PWM_PSCR_WIDTH{1'b1}});
  // this.write(`PWM_CMP_ADDR, 32'hF & {`PWM_CMP_WIDTH{1'b1}});
  // this.write(`PWM_CTRL_ADDR, 32'b10 & {`PWM_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
endtask

task automatic RTCTest::test_irq(input bit [31:0] run_times = 10);
  super.test_irq();
  // this.read(`PWM_STAT_ADDR);
  // this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  // this.write(`PWM_PSCR_ADDR, 32'd4 & {`PWM_PSCR_WIDTH{1'b1}});
  // this.write(`PWM_CMP_ADDR, 32'hE & {`PWM_CMP_WIDTH{1'b1}});

  // for (int i = 0; i < run_times; i++) begin
  //   this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  //   this.read(`PWM_STAT_ADDR);
  //   $display("%t rd_data: %h", $time, super.rd_data);
  //   this.write(`PWM_CTRL_ADDR, 32'b11 & {`PWM_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  // end

endtask
`endif
