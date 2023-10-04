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
`define RTC_DIV  4'b0010 //BASEADDR+0x0C
`define RTC_CNT  4'b0011 //BASEADDR+0x08
`define RTC_ALRM 4'b0100 //BASEADDR+0x10
// verilog_format: on

/* register mapping
 * RTC_CTRL:
 * BITS:   | 31:9 | 8    | 7      | 6    | 5     | 4   | 3     | 2     | 1      | 0     |
 * FIELDS: | RES  | OVIE | ALRMIE | SCIE | LWOFF | CMF | RSYNF | OVIF  | ALRMIF | SCIF  |
 * PERMS:  | NONE | RW   | RW     | RW   | R     | RW  | RC_W0 | RC_W0 | RC_W0  | RC_W0 |
 * --------------------------------------------------------------------------------------
 * RTC_PSCR:
 * BITS:   | 31:20 | 19:0 |
 * FIELDS: | RES   | PSCR |
 * PERMS:  | NONE  | W    |
 * --------------------------------------------------------------------------------------
 * RTC_DIV:
 * BITS:   | 31:20 | 19:0 |
 * FIELDS: | RES   | DIV  |
 * PERMS:  | NONE  | R    |
 * --------------------------------------------------------------------------------------
 * RTC_CNT: WRITE-PROTECTED by LWOFF
 * BITS:   | 31:0 |
 * FIELDS: | CNT  |
 * PERMS:  | RW   |
* --------------------------------------------------------------------------------------
 * RTC_ALRM: WRITE-PROTECTED by LWOFF
 * BITS:   | 31:0 |
 * FIELDS: | ALRM |
 * PERMS:  | W    |
*/
module apb4_rtc (
    // verilog_format: off
    apb4_if.slave apb4,
    // verilog_format: on
    input logic   rtc_clk_i,
    input logic   rtc_rst_n_i,
    output logic  irq_o
);

  logic [31:0] r_rtc_ctrl;
  logic [31:0] r_rtc_pscr;
  logic [31:0] r_rtc_div;
  logic [31:0] r_rtc_cnt;
  logic [31:0] r_rtc_alrm;
  logic        r_tr_clk;

  // config

  // prescaler
  always_ff @(posedge rtc_clk_i, negedge rtc_rst_n_i) begin
    if (~rtc_rst_n_i) begin
      r_rtc_pscr <= '0;
      r_rtc_div  <= '0;
      r_tr_clk   <= '0;
    end else if (r_rtc_div == '0) begin
      r_rtc_div <= r_rtc_pscr;
      r_tr_clk  <= ~r_tr_clk;
    end else begin
      r_rtc_div <= r_rtc_div + 1'b1;
    end
  end
  // interrupt

  assign apb4.pready = 1'b1;
  assign apb4.pslerr = 1'b0;
endmodule
