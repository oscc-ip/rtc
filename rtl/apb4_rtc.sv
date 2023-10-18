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
`define RTC_ALRM 4'b0011 //BASEADDR+0x0C
// verilog_format: on

/* register mapping
 * RTC_CTRL:
 * BITS:   | 31: 10 | 9  | 8    | 7      | 6    | 5     | 4   | 3     | 2     | 1      | 0     |
 * FIELDS: | RES    | EN | OVIE | ALRMIE | SCIE | LWOFF | CMF | RSYNF | OVIF  | ALRMIF | SCIF  |
 * PERMS:  | NONE   | RW | RW   | RW     | RW   | R     | RW  | RC_W0 | RC_W0 | RC_W0  | RC_W0 |
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

  logic [3:0] s_apb_addr;
  logic [31:0] s_rtc_ctrl_d, s_rtc_ctrl_q;
  logic [31:0] s_rtc_pscr_d, s_rtc_pscr_q;
  logic [31:0] s_rtc_cnt_d, s_rtc_cnt_q;
  logic [31:0] s_rtc_alrm_d, s_rtc_alrm_q;
  logic s_valid, s_ready, s_done, s_tr_clk;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk, s_normal_mode;
  logic s_tick_irq, s_ov_irq, s_alrm_irq;
  logic s_wr_pready, s_rd_pready;
  logic s_wr_src_valid_d, s_wr_src_valid_q, s_wr_dst_valid;
  logic [31:0] s_wr_dst_data;
  logic s_rd_src_valid_d, s_rd_src_valid_q, s_rd_dst_valid;
  logic [31:0] s_rd_dst_data;


  assign s_apb_addr      = apb.paddr[5:2];
  assign s_apb4_wr_hdshk = apb.psel && apb.penable && apb.pwrite;
  assign s_apb4_rd_hdshk = apb.psel && apb.penable && (~apb.pwrite);
  assign s_normal_mode   = s_rtc_ctrl_q[9] & s_done;

  assign s_ov_irq        = s_rtc_ctrl_q[8] & s_rtc_ctrl_q[2];
  assign s_alrm_irq      = s_rtc_ctrl_q[7] & s_rtc_ctrl_q[1];
  assign s_tick_irq      = s_rtc_ctrl_q[6] & s_rtc_ctrl_q[0];
  assign irq_o           = s_ov_irq | s_alrm_irq | s_tick_irq;


  always_comb begin
    s_rtc_pscr_d = s_rtc_pscr_q;
    if (s_apb4_wr_hdshk && s_apb_addr == `RTC_PSCR) begin
      s_rtc_pscr_d = apb4.pwdata < 2 ? 32'd2 : abp4.pwdata;
    end
  end

  dffr #(32) u_rtc_pscr_dffr (
      .clk_i  (apb4.hclk),
      .rst_n_i(apb4.hresetn),
      .dat_i  (s_rtc_pscr_d),
      .dat_o  (s_rtc_pscr_q)
  );

  assign s_valid = s_apb4_wr_hdshk && s_apb_addr == `RTC_PSCR && s_done;
  clk_int_even_div_simple u_clk_int_even_div_simple (
      .clk_i      (rtc_clk_i),
      .rst_n_i    (rtc_rst_n_i),
      .div_i      (s_rtc_pscr_q),
      .div_valid_i(s_valid),
      .div_ready_o(s_ready),
      .div_done_o (s_done),
      .clk_o      (s_tr_clk)
  );

  assign s_wr_src_valid_d = s_apb4_wr_hdshk && s_apb_addr == `RTC_CNT;
  dffr #(1) u_wr_src_valid_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_wr_src_valid_d,
      s_wr_src_valid_q
  );

  cdc_2phase #(32) u_wr_cdc_2phase (
      .src_clk_i  (apb4.hclk),
      .src_rst_n_i(apb4.hresetn),
      .src_data_i (apb4.pwdata),
      .src_valid_i(s_wr_src_valid_d),
      .src_ready_o(s_wr_pready),

      .dst_clk_i  (rtc_clk_i),
      .dst_rst_n_i(rtc_rst_n_i),
      .dst_data_o (s_wr_dst_data),
      .dst_valid_o(s_wr_dst_valid),
      .dst_ready_i(1'b1)
  );

  always_comb begin
    s_rtc_cnt_d = s_rtc_cnt_q;
    if (s_wr_dst_valid) begin  // cdc data is prepared
      s_rtc_cnt_d = s_wr_dst_data;
    end else if (s_normal_mode) begin
      s_rtc_cnt_d = s_rtc_cnt_q + 1'b1;
    end
  end

  dffr #(32) u_rtc_cnt_dffr (
      s_tr_clk,
      apb4.hresetn,
      s_rtc_cnt_d,
      s_rtc_cnt_q
  );

  always_comb begin
    s_rtc_ctrl_d = s_rtc_ctrl_q;
    if (s_apb4_wr_hdshk && s_apb_addr == `RTC_CTRL) begin
      s_rtc_ctrl_d = apb4.pwdata;
    end else if (s_normal_mode) begin
      if (s_rtc_cnt_d == 32'hFFFF_FFFF - 1) begin
        s_rtc_ctrl_d[2] = 1'b1;
      end else if (s_rtc_cnt_q == s_rtc_alrm_q) begin
        s_rtc_ctrl_d[1] = 1'b1;
      end
    end
  end

  dffr #(32) u_rtc_ctrl_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_rtc_ctrl_d,
      s_rtc_ctrl_q
  );

  assign s_rtc_alrm_d = (s_apb4_wr_hdshk && s_apb_addr == `RTC_ALRM) ? apb4.pwdata : s_rtc_alrm_q;
  dffr #(32) u_tim_cmp_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_rtc_alrm_d,
      s_rtc_alrm_q
  );


  assign s_rd_src_valid_d = s_apb4_rd_hdshk && s_apb_addr == `RTC_CNT;
  dffr #(1) u_rd_src_valid_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_rd_src_valid_d,
      s_rd_src_valid_q
  );
  cdc_2phase #(32) u_rd_cdc_2phase (
      .src_clk_i  (rtc_clk_i),
      .src_rst_n_i(rtc_rst_n_i),
      .src_data_i (s_rtc_cnt_q),
      .src_valid_i(s_rd_src_valid_d),
      .src_ready_o(s_rd_pready),

      .dst_clk_i  (apb4.hclk),
      .dst_rst_n_i(abp4.hresetn),
      .dst_data_o (s_rd_dst_data),
      .dst_valid_o(s_rd_dst_valid),
      .dst_ready_i(1'b1)
  );

  always_comb begin
    apb.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb_addr)
        `RTC_CTRL: apb.prdata = s_rtc_ctrl_q;
        `RTC_PSCR: apb4.prdata = s_rtc_pscr_q;
        `RTC_CNT:  apb4.prdata = s_rd_dst_valid ? s_rd_dst_data : '0;
        `RTC_ALRM: apb.prdata = s_rtc_alrm_q;
      endcase
    end
  end


  always_comb begin
    apb4.pready = 1'b1;
    if (s_wr_src_valid_d) begin
      apb4.pready = s_wr_pready && s_wr_src_valid_q;
    end else if (s_rd_src_valid_d) begin
      apb4.pready = s_rd_pready && s_rd_src_valid_q;
    end
  end

  assign apb4.pslerr = 1'b0;
endmodule
