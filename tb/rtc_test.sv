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
  extern task automatic test_wr_rd_cnt_reg(input bit [31:0] run_times = 10);
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
  this.rd_check(`RTC_PSCR_ADDR, "PSCR REG", 32'd2 & {`RTC_PSCR_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_ALRM_ADDR, "ALRM REG", 32'b0 & {`RTC_ALRM_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_ISTA_ADDR, "ISTA REG", 32'b0 & {`RTC_ISTA_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RTC_SSTA_ADDR, "SSTA REG", 32'b10 & {`RTC_SSTA_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic RTCTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`RTC_CTRL_ADDR, "CTRL REG", $random & {`RTC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`RTC_CTRL_ADDR, "CTRL REG", 32'b1 & {`RTC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`RTC_ALRM_ADDR, "ALRM REG", $random & {`RTC_ALRM_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`RTC_CTRL_ADDR, "CTRL REG", 32'b0 & {`RTC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic RTCTest::test_clk_div(input bit [31:0] run_times = 10);
  $display("=== [test rtc clk div] ===");
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`RTC_CTRL_ADDR, 32'b0 & {`RTC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});  // enter cmf mode
  this.write(`RTC_PSCR_ADDR, 32'd10 & {`RTC_PSCR_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`RTC_PSCR_ADDR, 32'd4 & {`RTC_PSCR_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  for (int i = 0; i < run_times; i++) begin
    this.wr_val = ($random % 20) & {`RTC_PSCR_WIDTH{1'b1}};
    if (this.wr_val < 2) this.wr_val = 2;
    if (this.wr_val % 2) this.wr_val -= 1;
    this.wr_rd_check(`RTC_PSCR_ADDR, "PSCR REG", this.wr_val, Helper::EQUL);
    repeat (500) @(posedge this.apb4.pclk);
  end
endtask

task automatic RTCTest::test_inc_cnt(input bit [31:0] run_times = 10);
  $display("=== [test rtc inc cnt] ===");
  this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});
  this.write(`RTC_PSCR_ADDR, 32'd4 & {`RTC_PSCR_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`RTC_ALRM_ADDR, 32'h2FF & {`RTC_ALRM_WIDTH{1'b1}});
  this.write(`RTC_CTRL_ADDR, 32'b1_0000 & {`RTC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
endtask

task automatic RTCTest::test_wr_rd_cnt_reg(input bit [31:0] run_times = 10);
  $display("=== [test rtc wr or rd cnt reg] ===");
  this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});
  this.write(`RTC_PSCR_ADDR, 32'd6 & {`RTC_PSCR_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  for (int i = 0; i < run_times; i++) begin
    this.wr_val = $random & {`RTC_CNT_WIDTH{1'b1}};
    this.write(`RTC_CNT_ADDR, this.wr_val);
    repeat (200) @(posedge this.apb4.pclk);
    this.wr_rd_check(`RTC_CNT_ADDR, "RTC REG", this.wr_val, Helper::EQUL, Helper::INFO);
    repeat (200) @(posedge this.apb4.pclk);
  end
endtask

task automatic RTCTest::test_irq(input bit [31:0] run_times = 10);
  super.test_irq();
  this.wr_val = 32'hE;
  this.read(`RTC_ISTA_ADDR);
  this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});
  this.write(`RTC_PSCR_ADDR, 32'd4 & {`RTC_PSCR_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`RTC_ALRM_ADDR, this.wr_val & {`RTC_ALRM_WIDTH{1'b1}});
  this.write(`RTC_CNT_ADDR, 32'b0 & {`RTC_CNT_WIDTH{1'b1}});
  this.write(`RTC_CTRL_ADDR, 32'b1_1110 & {`RTC_CTRL_WIDTH{1'b1}});

  for (int i = 0; i < run_times; i++) begin
    this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});
    this.read(`RTC_ISTA_ADDR);
    $display("%t rtc ista reg: %h", $time, super.rd_data);
    if (super.rd_data[1]) begin
      this.wr_val += 32'h2F;
      this.write(`RTC_ALRM_ADDR, this.wr_val & {`RTC_ALRM_WIDTH{1'b1}});
    end
    this.write(`RTC_CTRL_ADDR, 32'b1_1110 & {`RTC_CTRL_WIDTH{1'b1}});
    repeat (200) @(posedge this.apb4.pclk);
  end

  // ovif test
  this.write(`RTC_CTRL_ADDR, 32'b1 & {`RTC_CTRL_WIDTH{1'b1}});
  this.read(`RTC_ISTA_ADDR);
  this.write(`RTC_CNT_ADDR, -32'hFF & {`RTC_CNT_WIDTH{1'b1}});
  this.write(`RTC_CTRL_ADDR, 32'b1_1110 & {`RTC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);

  do begin
    this.read(`RTC_ISTA_ADDR);
    if (super.rd_data[2]) begin
      $display("%t [ovif] rtc ista reg: %h", $time, super.rd_data);
      break;
    end
    repeat (200) @(posedge this.apb4.pclk);
  end while (1);
endtask
`endif
