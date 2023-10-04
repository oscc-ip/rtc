// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rtc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// verilog_format: off
`define RTC_CTRL 4'b0000 //BASEADDR+0x00
`define RTC_PSCR 4'b0001 //BASEADDR+0x04
`define RTC_CNT  4'b0010 //BASEADDR+0x08
`define RTC_DIV  4'b0011 //BASEADDR+0x0C
`define RTC_ALRM 4'b0100 //BASEADDR+0x10
// verilog_format: on

/*

*/
module apb4_rtc (
    // verilog_format: off
    apb4_if.slave apb4,
    // verilog_format: on
    input logic   rtc_clk_i,
    output logic  irq_o
);

  logic [31:0] r_rtc_ctrl;
  logic [31:0] r_rtc_pscr;
  logic [31:0] r_rtc_cnt;
  logic [31:0] r_rtc_div;
  logic [31:0] r_rtc_alrm;
  logic        s_tr_clk;

  // prescaler

  assign apb4.pready = 1'b1;
  assign apb4.pslerr = 1'b0;
endmodule
