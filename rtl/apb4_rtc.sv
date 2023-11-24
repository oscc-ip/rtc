// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rtc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "clk_int_div.sv"
`include "cdc_2phase.sv"
`include "edge_det.sv"
`include "rtc_define.sv"

module apb4_rtc (
    apb4_if.slave apb4,
    rtc_if.dut    rtc
);

  logic [3:0] s_apb4_addr;
  logic [`RTC_CTRL_WIDTH-1:0] s_rtc_ctrl_d, s_rtc_ctrl_q;
  logic [`RTC_PSCR_WIDTH-1:0] s_rtc_pscr_d, s_rtc_pscr_q;
  logic [`RTC_CNT_WIDTH-1:0] s_rtc_cnt_d, s_rtc_cnt_q;
  logic [`RTC_ALRM_WIDTH-1:0] s_rtc_alrm_d, s_rtc_alrm_q;
  logic [`RTC_ISTA_WIDTH-1:0] s_rtc_ista_d, s_rtc_ista_q;
  logic [`RTC_SSTA_WIDTH-1:0] s_rtc_ssta_d, s_rtc_ssta_q;
  logic s_valid, s_done, s_tc_clk;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk, s_normal_mode;
  logic s_ov_en, s_alrm_en, s_tick_en;
  logic s_ov_irq_trg, s_alrm_irq_trg, s_tick_irq_trg;
  logic s_wr_pready, s_rd_pready, s_rtc_wr_valid;
  logic s_wr_src_valid, s_wr_dst_valid;
  logic s_rd_src_valid, s_rd_dst_valid;
  logic [`RTC_CNT_WIDTH-1:0] s_wr_dst_data, s_rd_dst_data;


  assign s_apb4_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready = apb4.pwrite ? s_wr_pready : s_rd_pready;
  assign apb4.pslverr = 1'b0;

  assign s_normal_mode = s_rtc_ctrl_q[4] & s_done;
  assign s_ov_en = s_rtc_ctrl_q[3];
  assign s_alrm_en = s_rtc_ctrl_q[2];
  assign s_tick_en = s_rtc_ctrl_q[1];
  assign s_rtc_wr_valid = s_rtc_ctrl_q[0] & s_rtc_ssta_q[1];
  assign rtc.irq_o = s_rtc_ista_q[0] | s_rtc_ista_q[1] | s_rtc_ista_q[2];


  assign s_rtc_ctrl_d = (s_apb4_wr_hdshk && s_apb4_addr == `RTC_CTRL) ? apb4.pwdata[`RTC_CTRL_WIDTH-1:0] : s_rtc_ctrl_q;
  dffr #(`RTC_CTRL_WIDTH) u_rtc_ctrl_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rtc_ctrl_d,
      s_rtc_ctrl_q
  );

  always_comb begin
    s_rtc_pscr_d = s_rtc_pscr_q;
    if (s_apb4_wr_hdshk && s_apb4_addr == `RTC_PSCR && s_rtc_wr_valid) begin
      s_rtc_pscr_d = apb4.pwdata[`RTC_PSCR_WIDTH-1:0] < `RTC_PSCR_MIN_VAL ? `RTC_PSCR_MIN_VAL : apb4.pwdata[`RTC_PSCR_WIDTH-1:0];
    end
  end

  dffr #(`RTC_PSCR_WIDTH) u_rtc_pscr_dffr (
      .clk_i  (apb4.pclk),
      .rst_n_i(apb4.presetn),
      .dat_i  (s_rtc_pscr_d),
      .dat_o  (s_rtc_pscr_q)
  );

  assign s_valid = s_apb4_wr_hdshk && s_apb4_addr == `RTC_PSCR && s_rtc_wr_valid && s_done;
  clk_int_even_div_simple #(`RTC_PSCR_WIDTH) u_clk_int_even_div_simple (
      .clk_i      (rtc.rtc_clk_i),
      .rst_n_i    (rtc.rtc_rst_n_i),
      .div_i      (s_rtc_pscr_q),
      .div_valid_i(s_valid),
      .div_ready_o(),
      .div_done_o (s_done),
      .clk_o      (s_tc_clk)
  );

  assign s_wr_src_valid = s_apb4_wr_hdshk && s_apb4_addr == `RTC_CNT && s_rtc_wr_valid;
  cdc_2phase #(`RTC_CNT_WIDTH) u_wr_cdc_2phase (
      .src_clk_i  (apb4.pclk),
      .src_rst_n_i(apb4.presetn),
      .src_data_i (apb4.pwdata),
      .src_valid_i(s_wr_src_valid),
      .src_ready_o(s_wr_pready),

      .dst_clk_i  (rtc.rtc_clk_i),
      .dst_rst_n_i(rtc.rtc_rst_n_i),
      .dst_data_o (s_wr_dst_data),
      .dst_valid_o(s_wr_dst_valid),
      .dst_ready_i(1'b1)
  );

  assign s_rd_src_valid = s_apb4_rd_hdshk && s_apb4_addr == `RTC_CNT;


  cdc_2phase #(`RTC_CNT_WIDTH) u_rd_cdc_2phase (
      .src_clk_i  (rtc.rtc_clk_i),
      .src_rst_n_i(rtc.rtc_rst_n_i),
      .src_data_i (s_rtc_cnt_q),
      .src_valid_i(s_rd_src_valid),
      .src_ready_o(s_rd_pready),

      .dst_clk_i  (apb4.pclk),
      .dst_rst_n_i(apb4.presetn),
      .dst_data_o (s_rd_dst_data),
      .dst_valid_o(s_rd_dst_valid),
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

  dffr #(`RTC_CNT_WIDTH) u_rtc_cnt_dffr (
      s_tc_clk,
      apb4.presetn,
      s_rtc_cnt_d,
      s_rtc_cnt_q
  );

  assign s_rtc_alrm_d = (s_apb4_wr_hdshk && s_apb4_addr == `RTC_ALRM && s_rtc_wr_valid) ? apb4.pwdata[`RTC_ALRM_WIDTH-1:0] : s_rtc_alrm_q;
  dffr #(`RTC_ALRM_WIDTH) u_rtc_alrm_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rtc_alrm_d,
      s_rtc_alrm_q
  );

  cdc_sync #(2, 1) u_ov_irq_cdc_sync (
      apb4.pclk,
      apb4.presetn,
      s_rtc_cnt_q == 32'hFFFF_FFFF - 1,
      s_ov_irq_trg
  );

  cdc_sync #(2, 1) u_alrm_irq_cdc_sync (
      apb4.pclk,
      apb4.presetn,
      s_rtc_cnt_q >= s_rtc_alrm_q,
      s_alrm_irq_trg
  );

  edge_det_re #(2, 1) u_tick_edge_det_re (
      .clk_i  (apb4.pclk),
      .rst_n_i(apb4.presetn),
      .dat_i  (s_tc_clk),
      .re_o   (s_tick_irq_trg)
  );

  always_comb begin
    s_rtc_ista_d = s_rtc_ista_q;
    if (rtc.irq_o && s_apb4_rd_hdshk && s_apb4_addr == `RTC_ISTA) begin
      s_rtc_ista_d = '0;
    end else if (~s_rtc_ista_q[2] && s_ov_en && s_ov_irq_trg) begin
      s_rtc_ista_d[2] = 1'b1;
    end else if (~s_rtc_ista_q[1] && s_alrm_en && s_alrm_irq_trg) begin
      s_rtc_ista_d[1] = 1'b1;
    end else if (~s_rtc_ista_q[0] && s_tick_en && s_tick_irq_trg) begin
      s_rtc_ista_d[0] = 1'b1;
    end
  end

  dffr #(`RTC_ISTA_WIDTH) u_rtc_ista_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rtc_ista_d,
      s_rtc_ista_q
  );

  cdc_sync #(2, 1) u_rsynf_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rd_dst_valid,
      s_rtc_ssta_d[0]
  );

  assign s_rtc_ssta_d[1] = s_wr_pready;
  dffr #(`RTC_SSTA_WIDTH) u_rtc_ssta_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rtc_ssta_d,
      s_rtc_ssta_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `RTC_CTRL: apb4.prdata[`RTC_CTRL_WIDTH-1:0] = s_rtc_ctrl_q;
        `RTC_PSCR: apb4.prdata[`RTC_PSCR_WIDTH-1:0] = s_rtc_pscr_q;
        `RTC_CNT:  apb4.prdata[`RTC_CNT_WIDTH-1:0] = s_rd_dst_valid ? s_rd_dst_data : '0;
        `RTC_ALRM: apb4.prdata[`RTC_ALRM_WIDTH-1:0] = s_rtc_alrm_q;
        `RTC_ISTA: apb4.prdata[`RTC_ISTA_WIDTH-1:0] = s_rtc_ista_q;
        `RTC_SSTA: apb4.prdata[`RTC_SSTA_WIDTH-1:0] = s_rtc_ssta_q;
        default:   apb4.prdata = '0;
      endcase
    end
  end
endmodule
