`timescale 1ns/1ps

module top_pipelined_tb;

    reg clk;
    reg rst;

    // Debug wires from DUT
    wire [31:0] dbg_pc;
    wire [31:0] dbg_alu_result;
    wire [31:0] dbg_writeback_data;
    wire [4:0]  dbg_writeback_rd;
    wire        dbg_regwrite;

    // ============================================================
    // DUT
    // ============================================================

    top_pipelined DUT (
        .clk (clk),
        .rst (rst),
        .debug_pc(dbg_pc),
        .debug_alu_result(dbg_alu_result),
        .debug_writeback_data(dbg_writeback_data),
        .debug_writeback_rd(dbg_writeback_rd),
        .debug_regwrite(dbg_regwrite)
    );

    // ============================================================
    // CLOCK
    // 10 ns clock period
    // ============================================================

    always #5 clk = ~clk;

    // ============================================================
    // CYCLE COUNTER
    // ============================================================

    integer cycle_count;

    // ============================================================
    // PIPELINE PC DEBUG SIGNALS
    // ============================================================

    wire [31:0] PC_IF_dbg;
    wire [31:0] PC_ID_dbg;
    wire [31:0] PC_EX_dbg;
    wire [31:0] PC_MEM_dbg;
    wire [31:0] PC_WB_dbg;

    assign PC_IF_dbg  = DUT.pc_current;
    assign PC_ID_dbg  = DUT.pc_id;
    assign PC_EX_dbg  = DUT.pc_ex;

    // Pipeline stores PC+4, therefore subtract 4
    assign PC_MEM_dbg = DUT.pc_plus4_mem - 32'd4;
    assign PC_WB_dbg  = DUT.pc_plus4_wb  - 32'd4;


    // ============================================================
    // INSTRUCTION DECODER FOR TRANSCRIPT
    // ============================================================

    function [191:0] decode_pc;
        input [31:0] pc;

        begin

            case (pc)

                32'h00000000:
                    decode_pc = "ADDI x1,x0,100";

                32'h00000004:
                    decode_pc = "ADDI x2,x0,55";

                32'h00000008:
                    decode_pc = "SW x2,0(x1)";

                32'h0000000C:
                    decode_pc = "LW x3,0(x1)";

                32'h00000010:
                    decode_pc = "ADD x4,x3,x2";

                32'h00000014:
                    decode_pc = "ADDI x5,x0,5";

                32'h00000018:
                    decode_pc = "ADDI x6,x0,5";

                32'h0000001C:
                    decode_pc = "BEQ x5,x6,+8";

                32'h00000020:
                    decode_pc = "ADDI x7,x0,111";

                32'h00000024:
                    decode_pc = "ADDI x7,x0,222";

                32'h00000028:
                    decode_pc = "JAL x8,+8";

                32'h0000002C:
                    decode_pc = "ADDI x9,x0,111";

                32'h00000030:
                    decode_pc = "ADDI x9,x0,222";

                32'h00000034:
                    decode_pc = "ADDI x10,x0,68";

                32'h00000038:
                    decode_pc = "ADDI x5,x0,10";

                32'h0000003C:
                    decode_pc = "JALR x11,x10,0";

                32'h00000040:
                    decode_pc = "ADDI x12,x0,111";

                32'h00000044:
                    decode_pc = "MAC x7,x5,x6";

                default:
                    decode_pc = "----";

            endcase

        end
    endfunction


    // ============================================================
    // INITIAL TRACE HEADER
    // ============================================================

    initial begin

        cycle_count = 0;

        $display("");
        $display("================================================================================================================");
        $display("                                  5-STAGE RISC-V PIPELINE TRACE");
        $display("================================================================================================================");
        $display("");

        $display("Cycle        IF Stage                  ID Stage                  EX Stage                  MEM Stage                 WB Stage");
        $display("----------------------------------------------------------------------------------------------------------------");
    end


    // ============================================================
    // PIPELINE TRACE
    // ============================================================

    always @(posedge clk) begin

        #1;

        if (!rst) begin

            cycle_count = cycle_count + 1;

            $write("%5d        ", cycle_count);

            // IF STAGE
            $write("%-25s", decode_pc(PC_IF_dbg));

            // ID STAGE
            if (DUT.instruction_id != 32'h00000000)
                $write("%-25s", decode_pc(PC_ID_dbg));
            else
                $write("%-25s", "----");

            // EX STAGE
            if (DUT.RegWrite_ex     ||
                DUT.MemRead_ex      ||
                DUT.MemWrite_ex     ||
                DUT.Branch_ex       ||
                DUT.JAL_en_ex       ||
                DUT.JALR_en_ex      ||
                DUT.MAC_Enable_ex   ||
                DUT.MACLO_Enable_ex ||
                DUT.MACHI_Enable_ex ||
                DUT.LUI_en_ex       ||
                DUT.AUIPC_en_ex) begin

                $write("%-25s", decode_pc(PC_EX_dbg));

            end
            else begin
                $write("%-25s", "----");
            end

            // MEM STAGE
            if (DUT.pc_plus4_mem != 32'h00000000)
                $write("%-25s", decode_pc(PC_MEM_dbg));
            else
                $write("%-25s", "----");

            // WB STAGE
            if (DUT.pc_plus4_wb != 32'h00000000)
                $write("%-25s", decode_pc(PC_WB_dbg));
            else
                $write("%-25s", "----");

            $display("");

            // HAZARD INFORMATION
            if (DUT.Stall_PC &&
                DUT.Stall_IF_ID &&
                DUT.Flush_ID_EX) begin

                $display("");
                $display("             >>> LOAD-USE HAZARD : STALL + FLUSH");
                $display("");

            end

            // FORWARDING INFORMATION
            if ((DUT.forwardA != 2'b00) ||
                (DUT.forwardB != 2'b00)) begin

                $display("             >>> FORWARDING       : A = %b     B = %b",
                         DUT.forwardA,
                         DUT.forwardB);

            end

            // CONTROL HAZARD INFORMATION
            if (DUT.PCSrc) begin
                $display("");
                $display("             >>> BEQ TAKEN        : CONTROL FLUSH");
                $display("");
            end

            if (DUT.JAL_en_ex) begin
                $display("");
                $display("             >>> JAL TAKEN        : CONTROL FLUSH");
                $display("");
            end

            if (DUT.JALR_en_ex) begin
                $display("");
                $display("             >>> JALR TAKEN       : CONTROL FLUSH");
                $display("");
            end

        end

    end


    // ============================================================
    // RESET + TEST
    // ============================================================

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        #20;
        rst = 1'b0;
        #300;

        $display("");
        $display("================================================================================================================");
        $display("                                  FINAL FUNCTIONAL VERIFICATION");
        $display("================================================================================================================");

        $display("");
        $display("REGISTER RESULTS");
        $display("----------------------------");

        $display("x1  = %08h", DUT.rf.registers[1]);
        $display("x2  = %08h", DUT.rf.registers[2]);
        $display("x3  = %08h", DUT.rf.registers[3]);
        $display("x4  = %08h", DUT.rf.registers[4]);
        $display("x5  = %08h", DUT.rf.registers[5]);
        $display("x6  = %08h", DUT.rf.registers[6]);
        $display("x7  = %08h", DUT.rf.registers[7]);
        $display("x8  = %08h", DUT.rf.registers[8]);
        $display("x9  = %08h", DUT.rf.registers[9]);
        $display("x10 = %08h", DUT.rf.registers[10]);
        $display("x11 = %08h", DUT.rf.registers[11]);
        $display("x12 = %08h", DUT.rf.registers[12]);

        $display("");
        $display("MEMORY RESULT");
        $display("----------------------------");
        $display("D_mem[25] = %08h", DUT.dmem.D_mem[25]);

        $display("");
        $display("MAC RESULTS");
        $display("----------------------------");
        $display("MAC_result_WB = %08h", DUT.mac_result_wb);
        $display("MAC_low_WB    = %08h", DUT.mac_low_wb);
        $display("MAC_high_WB   = %08h", DUT.mac_high_wb);

        $display("");
        $display("FUNCTIONAL CHECK");
        $display("----------------------------");

        if ((DUT.rf.registers[1]  == 32'h00000064) &&
            (DUT.rf.registers[2]  == 32'h00000037) &&
            (DUT.rf.registers[3]  == 32'h00000037) &&
            (DUT.rf.registers[4]  == 32'h0000006E) &&
            (DUT.rf.registers[7]  == 32'h00000032) &&
            (DUT.rf.registers[8]  == 32'h0000002C) &&
            (DUT.rf.registers[9]  == 32'h000000DE) &&
            (DUT.rf.registers[11] == 32'h00000040) &&
            (DUT.rf.registers[12] == 32'h00000000) &&
            (DUT.dmem.D_mem[25] == 32'h00000037) &&
            (DUT.mac_result_wb == 32'h00000032) &&
            (DUT.mac_low_wb    == 32'h00000032) &&
            (DUT.mac_high_wb   == 32'h00000000)) begin

            $display("");
            $display("============================================================");
            $display("              RESULT = ALL INTEGRATED TESTS PASSED");
            $display("============================================================");

        end
        else begin

            $display("");
            $display("============================================================");
            $display("              RESULT = INTEGRATED TEST FAILED");
            $display("============================================================");

        end

        $display("");
        $display("================================================================================================================");
        $display("Total clock cycles executed = %0d", cycle_count);
        $display("================================================================================================================");

        #20;
        $finish;

    end

    initial begin
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, top_pipelined_tb);
    end

endmodule
