///////////////////////////////////////////
// csr.sv
//
// Written: David_Harris@hmc.edu 9 January 2021
// Modified: 
//
// Purpose: Counter Control and Status Registers
//          See RISC-V Privileged Mode Specification 20190608 
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

`include "wally-macros.sv"

module csr #(parameter XLEN = 64, MISA = 0, ZCSR = 1, ZCOUNTERS = 1) (
  input  logic clk, reset,
  input  logic [31:0] InstrM, 
  input  logic [XLEN-1:0] PCM, SrcAM,
  input  logic            CSRWriteM, TrapM, MTrapM, STrapM, UTrapM, mretM, sretM, uretM,
  input  logic            TimerIntM, ExtIntM, SwIntM,
  input  logic            InstrValidW, FloatRegWriteW, LoadStallD,
  input  logic [1:0]      NextPrivilegeModeM, PrivilegeModeW,
  input  logic [XLEN-1:0] CauseM, NextFaultMtvalM,
  output logic [1:0]      STATUS_MPP,
  output logic            STATUS_SPP, STATUS_TSR,
  output logic [XLEN-1:0] MEPC_REGW, SEPC_REGW, UEPC_REGW, UTVEC_REGW, STVEC_REGW, MTVEC_REGW,
  output logic [XLEN-1:0] MEDELEG_REGW, MIDELEG_REGW, SEDELEG_REGW, SIDELEG_REGW, 
  output logic [11:0]     MIP_REGW, MIE_REGW,
  output logic            STATUS_MIE, STATUS_SIE,
  input  logic [4:0]      SetFflagsM,
  output logic [2:0]      FRM_REGW, 
//  output logic [11:0]     MIP_REGW, SIP_REGW, UIP_REGW, MIE_REGW, SIE_REGW, UIE_REGW,
  output logic [XLEN-1:0] CSRReadValM,
  output logic            IllegalCSRAccessM
);

  logic [XLEN-1:0] CSRMReadValM, CSRSReadValM, CSRUReadValM, CSRNReadValM, CSRCReadValM;
  logic [XLEN-1:0] CSRSrcM, CSRRWM, CSRRSM, CSRRCM, CSRWriteValM;
 
  logic [XLEN-1:0] MSTATUS_REGW, SSTATUS_REGW, USTATUS_REGW;
  logic [31:0]     MCOUNTINHIBIT_REGW, MCOUNTEREN_REGW, SCOUNTEREN_REGW;
  logic            WriteMSTATUSM, WriteSSTATUSM, WriteUSTATUSM;
  logic            CSRMWriteM, CSRSWriteM, CSRUWriteM;
  logic            WriteMIPM, WriteSIPM, WriteUIPM, WriteMIEM, WriteSIEM, WriteUIEM;

  logic [XLEN-1:0] UnalignedNextEPCM, NextEPCM, NextCauseM, NextMtvalM;

  logic [XLEN-1:0] zero = 0;
  logic [XLEN-1:0] resetExceptionVector = {{(XLEN-32){1'b0}}, 32'h80000000}; // initial exception vector at reset

  logic [11:0] CSRAdrM;
  logic [11:0] SIP_REGW, SIE_REGW;
  logic [11:0] UIP_REGW, UIE_REGW = 0; // N user-mode exceptions not supported
  logic        IllegalCSRCAccessM, IllegalCSRMAccessM, IllegalCSRSAccessM, IllegalCSRUAccessM, IllegalCSRNAccessM, InsufficientCSRPrivilegeM;

  generate
    if (`ZCSR_SUPPORTED) begin
      // modify CSRs
      always_comb begin
        // Choose either rs1 or uimm[4:0] as source
        CSRSrcM = InstrM[14] ? {{(XLEN-5){1'b0}}, InstrM[19:15]} : SrcAM;
        // Compute AND/OR modification
        CSRRWM = CSRSrcM;
        CSRRSM = CSRReadValM | CSRSrcM;
        CSRRCM = CSRReadValM & ~CSRSrcM;
        case (InstrM[13:12])
          2'b01:  CSRWriteValM = CSRRWM;
          2'b10:  CSRWriteValM = CSRRSM;
          2'b11:  CSRWriteValM = CSRRCM;
          default: CSRWriteValM = CSRReadValM;
        endcase
      end

      // write CSRs
      assign CSRAdrM = InstrM[31:20];
      assign UnalignedNextEPCM = TrapM ? PCM : CSRWriteValM;
      assign NextEPCM = `C_SUPPORTED ? {UnalignedNextEPCM[XLEN-1:1], 1'b0} : {UnalignedNextEPCM[XLEN-1:2], 2'b00}; // 3.1.15 alignment
      assign NextCauseM = TrapM ? CauseM : CSRWriteValM;
      assign NextMtvalM = TrapM? NextFaultMtvalM : CSRWriteValM;
      assign CSRMWriteM = CSRWriteM && (PrivilegeModeW == `M_MODE);
      assign CSRSWriteM = CSRWriteM && (PrivilegeModeW[0]);
      assign CSRUWriteM = CSRWriteM;  

      csri #(XLEN, MISA) csri(
        clk, reset, CSRMWriteM, CSRSWriteM, CSRAdrM, ExtIntM, TimerIntM, SwIntM,
        MIDELEG_REGW, MIP_REGW, MIE_REGW, SIP_REGW, SIE_REGW, CSRWriteValM);

      csrsr #(XLEN, MISA) csrsr(
        clk, reset, 
        WriteMSTATUSM, WriteSSTATUSM, WriteUSTATUSM, TrapM, FloatRegWriteW,
        NextPrivilegeModeM, PrivilegeModeW,
        mretM, sretM, uretM,
        CSRWriteValM,
        MSTATUS_REGW, SSTATUS_REGW, USTATUS_REGW,
        STATUS_MPP, STATUS_SPP, STATUS_TSR, STATUS_MIE, STATUS_SIE);

      csrc #(XLEN, ZCOUNTERS) counters(
        clk, reset, 
        InstrValidW, LoadStallD, CSRMWriteM, CSRAdrM, PrivilegeModeW, CSRWriteValM,
        MCOUNTINHIBIT_REGW, MCOUNTEREN_REGW, SCOUNTEREN_REGW,
        CSRCReadValM, IllegalCSRCAccessM);

      // Machine Mode CSRs
      csrm #(XLEN, MISA) csrm(
        clk, reset, 
        CSRMWriteM, MTrapM, CSRAdrM,  
        resetExceptionVector, 
        NextEPCM, NextCauseM, NextMtvalM, MSTATUS_REGW,
        CSRWriteValM, CSRMReadValM, MEPC_REGW, MTVEC_REGW, MCOUNTEREN_REGW, MCOUNTINHIBIT_REGW, 
        MEDELEG_REGW, MIDELEG_REGW, MIP_REGW, MIE_REGW, WriteMIPM, WriteMIEM, WriteMSTATUSM, IllegalCSRMAccessM
      );

      csrs #(XLEN, MISA) csrs(
        clk, reset, 
        CSRSWriteM, STrapM, CSRAdrM,  
        resetExceptionVector, 
        NextEPCM, NextCauseM, NextMtvalM, SSTATUS_REGW,
        CSRWriteValM, CSRSReadValM, SEPC_REGW, STVEC_REGW, SCOUNTEREN_REGW, 
        SEDELEG_REGW, SIDELEG_REGW, SIP_REGW, SIE_REGW, WriteSIPM, WriteSIEM, WriteSSTATUSM, IllegalCSRSAccessM
      );

      csrn #(XLEN, MISA) csrn( // User Mode Exception Registers
        clk, reset, 
        CSRUWriteM, UTrapM, CSRAdrM,  
        resetExceptionVector, 
        NextEPCM, NextCauseM, NextMtvalM, USTATUS_REGW,
        CSRWriteValM, CSRNReadValM, UEPC_REGW, UTVEC_REGW, 
        UIP_REGW, UIE_REGW, WriteUIPM, WriteUIEM, WriteUSTATUSM, IllegalCSRNAccessM
      ); 

      csru #(XLEN, MISA) csru( // Floating Point Flags are part of User MOde
        clk, reset, CSRUWriteM, CSRAdrM,  
        CSRWriteValM, CSRUReadValM, SetFflagsM, FRM_REGW, IllegalCSRUAccessM
      ); 

      // merge CSR Reads
      assign CSRReadValM = CSRUReadValM | CSRSReadValM | CSRMReadValM | CSRCReadValM | CSRNReadValM; 

      // merge illegal accesses: illegal if none of the CSR addresses is legal or privilege is insufficient
      assign InsufficientCSRPrivilegeM = (CSRAdrM[9:8] == 2'b11 && PrivilegeModeW != `M_MODE) ||
                                        (CSRAdrM[9:8] == 2'b01 && PrivilegeModeW == `U_MODE);
      assign IllegalCSRAccessM = (IllegalCSRCAccessM && IllegalCSRMAccessM && 
        IllegalCSRSAccessM && IllegalCSRUAccessM  && IllegalCSRNAccessM ||
        InsufficientCSRPrivilegeM) && CSRWriteM;
    end else begin // CSRs not implemented
      assign STATUS_MPP = 2'b11;
      assign STATUS_SPP = 2'b0;
      assign STATUS_TSR = 0;
      assign MEPC_REGW = 0;
      assign SEPC_REGW = 0;
      assign UEPC_REGW = 0;
      assign UTVEC_REGW = 0;
      assign STVEC_REGW = 0;
      assign MTVEC_REGW = 0;
      assign MEDELEG_REGW = 0;
      assign MIDELEG_REGW = 0;
      assign SEDELEG_REGW = 0;
      assign SIDELEG_REGW = 0;
      assign MIP_REGW = 0;
      assign MIE_REGW = 0;
      assign STATUS_MIE = 0;
      assign STATUS_SIE = 0;
      assign FRM_REGW = 0;
      assign CSRReadValM = 0;
      assign IllegalCSRAccessM = CSRWriteM;
    end
  endgenerate
endmodule
