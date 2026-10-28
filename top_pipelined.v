`timescale 1ns / 1ps
module top_pipelined (
    input wire clk,
    input wire rst,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_writeback_data,
    output wire [4:0]  debug_writeback_rd,
    output wire        debug_regwrite
);

    // =========================================================================
    // Wires and Signals
    // =========================================================================
    wire [31:0] pc_current, pc_next, pc_plus4_if;
    wire [31:0] instruction_if;
    
    // IF/ID Wires
    wire [31:0] pc_id, pc_plus4_id, instruction_id;
    
    // ID Stage Wires
    wire [31:0] rs1_data_id, rs2_data_id, imm_ext_id;
    wire [6:0]  opcode_id = instruction_id[6:0];
    wire [2:0]  funct3_id = instruction_id[14:12];
    wire [4:0]  rs1_id    = instruction_id[19:15];
    wire [4:0]  rs2_id    = instruction_id[24:20];
    wire [4:0]  rd_id     = instruction_id[11:7];
    wire        funct7_id = instruction_id[30];

    // Control Unit Outputs (ID)
    wire Branch_id, MemRead_id, MemtoReg_id, MemWrite_id, ALUSrc_id, RegWrite_id;
    wire LUI_en_id, AUIPC_en_id, JAL_en_id, JALr_en_id;
    wire MAC_Enable_id, MAC_Clear_id, MACLO_Enable_id, MACHI_Enable_id;
    wire [1:0] ALUOp_id;

    // ID/EX Wires
    wire [31:0] pc_ex, pc_plus4_ex, rs1_data_ex, rs2_data_ex, imm_ext_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire [2:0]  funct3_ex;
    wire        funct7_ex;
    wire        RegWrite_ex, ALUSrc_ex, MemRead_ex, MemWrite_ex, MemToReg_ex, Branch_ex;
    wire        JAL_en_ex, JALR_en_ex, AUIPC_en_ex, LUI_en_ex;
    wire        MAC_Enable_ex, MAC_Clear_ex, MACLO_Enable_ex, MACHI_Enable_ex;
    wire [1:0]  ALUOp_ex;

    // EX Stage Wires
    wire [31:0] alu_operand1, alu_operand2, alu_result_ex;
    wire [3:0]  alu_control_ex;
    wire        zero_ex;
    wire [31:0] branch_target_ex;
    wire [1:0]  forwardA, forwardB;
    wire [31:0] mac_result_ex, mac_low_ex, mac_high_ex;

    // EX/MEM Wires
    wire [31:0] alu_result_mem, rs2_data_mem, branch_target_mem, pc_plus4_mem;
    wire [31:0] mac_result_mem, mac_low_mem, mac_high_mem;
    wire [4:0]  rd_mem;
    wire        zero_mem, RegWrite_mem, MemRead_mem, MemWrite_mem, MemToReg_mem, Branch_mem;
    wire        JAL_en_mem, JALR_en_mem, LUI_en_mem;
    wire        MAC_Enable_mem, MACLO_Enable_mem, MACHI_Enable_mem;

    // MEM Stage Wires
    wire [31:0] read_data_mem;
    wire        PCSrc = Branch_mem & zero_mem;

    // MEM/WB Wires
    wire [31:0] memory_data_wb, alu_result_wb, pc_plus4_wb;
    wire [31:0] mac_result_wb, mac_low_wb, mac_high_wb;
    wire [4:0]  rd_wb;
    wire        RegWrite_wb, MemToReg_wb, JAL_en_wb, JALR_en_wb;
    wire        MAC_Enable_wb, MACLO_Enable_wb, MACHI_Enable_wb;
    wire [31:0] writeback_data;

    // Hazard & Clock Gating Enable Wires
    wire Stall_PC, Stall_IF_ID, Flush_ID_EX;
    wire PC_enable    = ~Stall_PC;
    wire IF_ID_enable = ~Stall_IF_ID;
    wire ID_EX_enable  = 1'b1;
    wire EX_MEM_enable = 1'b1;
    wire MEM_WB_enable = 1'b1;

    // =========================================================================
    // Instruction Fetch (IF) Stage
    // =========================================================================
    program_counter pc_reg (
        .clk(clk),
        .rst(rst),
        .enable(PC_enable),
        .PC_in(pc_next),
        .PC_out(pc_current)
    );

    PC_inc pc_incrementer (
        .fromPC(pc_current),
        .toPC(pc_plus4_if)
    );

    instruction_mem imem (
        .read_address(pc_current),
        .instruction_out(instruction_if)
    );

    // Next PC Mux (Branch / JAL / JALR vs PC+4)
    assign pc_next = JALR_en_ex ? alu_result_ex : (PCSrc ? branch_target_mem : (JAL_en_ex ? branch_target_ex : pc_plus4_if));

    IF_ID if_id_reg (
        .clk(clk),
        .rst(rst),
        .stall(Stall_IF_ID),
        .flush(PCSrc || JAL_en_ex || JALR_en_ex),
        .pc_in(pc_current),
        .pc_plus4_in(pc_plus4_if),
        .instruction_in(instruction_if),
        .pc_out(pc_id),
        .pc_plus4_out(pc_plus4_id),
        .instruction_out(instruction_id)
    );

    // =========================================================================
    // Instruction Decode (ID) Stage
    // =========================================================================
    control_unit cu (
        .opcode(opcode_id),
        .funct3(funct3_id),
        .Branch(Branch_id),
        .MemRead(MemRead_id),
        .MemtoReg(MemtoReg_id),
        .MemWrite(MemWrite_id),
        .ALUSrc(ALUSrc_id),
        .RegWrite(RegWrite_id),
        .LUI_en(LUI_en_id),
        .AUIPC_en(AUIPC_en_id),
        .JAL_en(JAL_en_id),
        .JALr_en(JALr_en_id),
        .MAC_Enable(MAC_Enable_id),
        .MAC_Clear(MAC_Clear_id),
        .MACLO_Enable(MACLO_Enable_id),
        .MACHI_Enable(MACHI_Enable_id),
        .ALUOp(ALUOp_id)
    );

    reg_file rf (
        .clk(clk),
        .rst(rst),
        .reg_write(RegWrite_wb),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),
        .write_data(writeback_data),
        .read_data_1(rs1_data_id),
        .read_data_2(rs2_data_id)
    );

    ImmGen imm_gen (
        .opcode(opcode_id),
        .instruction(instruction_id),
        .ImmExt(imm_ext_id)
    );

    HazardDetectionUnit hdu (
        .MemRead_ID_EX(MemRead_ex),
        .rd_ID_EX(rd_ex),
        .rs1_IF_ID(rs1_id),
        .rs2_IF_ID(rs2_id),
        .Stall_PC(Stall_PC),
        .Stall_IF_ID(Stall_IF_ID),
        .Flush_ID_EX(Flush_ID_EX)
    );

    ID_EX id_ex_reg (
        .clk(clk),
        .rst(rst),
        .flush(Flush_ID_EX || PCSrc || JAL_en_ex || JALR_en_ex),
        .enable(ID_EX_enable),
        .pc_in(pc_id),
        .pc_plus4_in(pc_plus4_id),
        .rs1_data_in(rs1_data_id),
        .rs2_data_in(rs2_data_id),
        .immediate_in(imm_ext_id),
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        .funct3_in(funct3_id),
        .funct7_in(funct7_id),
        .RegWrite_in(RegWrite_id),
        .ALUSrc_in(ALUSrc_id),
        .ALUOp_in(ALUOp_id),
        .MemRead_in(MemRead_id),
        .MemWrite_in(MemWrite_id),
        .MemToReg_in(MemtoReg_id),
        .Branch_in(Branch_id),
        .JAL_en_in(JAL_en_id),
        .JALR_en_in(JALr_en_id),
        .AUIPC_en_in(AUIPC_en_id),
        .LUI_en_in(LUI_en_id),
        .MAC_Enable_in(MAC_Enable_id),
        .MAC_Clear_in(MAC_Clear_id),
        .MACLO_Enable_in(MACLO_Enable_id),
        .MACHI_Enable_in(MACHI_Enable_id),
        .pc_out(pc_ex),
        .pc_plus4_out(pc_plus4_ex),
        .rs1_data_out(rs1_data_ex),
        .rs2_data_out(rs2_data_ex),
        .immediate_out(imm_ext_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex),
        .funct3_out(funct3_ex),
        .funct7_out(funct7_ex),
        .RegWrite_out(RegWrite_ex),
        .ALUSrc_out(ALUSrc_ex),
        .ALUOp_out(ALUOp_ex),
        .MemRead_out(MemRead_ex),
        .MemWrite_out(MemWrite_ex),
        .MemToReg_out(MemToReg_ex),
        .Branch_out(Branch_ex),
        .JAL_en_out(JAL_en_ex),
        .JALR_en_out(JALR_en_ex),
        .AUIPC_en_out(AUIPC_en_ex),
        .LUI_en_out(LUI_en_ex),
        .MAC_Enable_out(MAC_Enable_ex),
        .MAC_Clear_out(MAC_Clear_ex),
        .MACLO_Enable_out(MACLO_Enable_ex),
        .MACHI_Enable_out(MACHI_Enable_ex)
    );

    // =========================================================================
    // Execution (EX) Stage
    // =========================================================================
    ForwardingUnit fu (
        .rs1_EX(rs1_ex),
        .rs2_EX(rs2_ex),
        .rd_MEM(rd_mem),
        .RegWrite_MEM(RegWrite_mem),
        .rd_WB(rd_wb),
        .RegWrite_WB(RegWrite_wb),
        .ForwardA(forwardA),
        .ForwardB(forwardB)
    );

    // Forwarding Muxes
    wire [31:0] src1_forwarded = (forwardA == 2'b10) ? alu_result_mem : ((forwardA == 2'b01) ? writeback_data : rs1_data_ex);
    wire [31:0] src2_forwarded = (forwardB == 2'b10) ? alu_result_mem : ((forwardB == 2'b01) ? writeback_data : rs2_data_ex);

    assign alu_operand1 = AUIPC_en_ex ? pc_ex : src1_forwarded;
    assign alu_operand2 = ALUSrc_ex ? imm_ext_ex : src2_forwarded;

    ALU_control alu_cu (
        .ALUOp(ALUOp_ex),
        .fun7(funct7_ex),
        .fun3(funct3_ex),
        .control_out(alu_control_ex)
    );

    ALU_unit alu (
        .A(alu_operand1),
        .B(alu_operand2),
        .control_in(alu_control_ex),
        .zero(zero_ex),
        .ALU_out(alu_result_ex)
    );

    branch_adder b_adder (
        .pc_addr(pc_ex),
        .ImmAddr(imm_ext_ex),
        .mux_in_addr(branch_target_ex)
    );

    mac_unit mac_ex_unit (
        .clk(clk),
        .reset(rst),
        .enable(MAC_Enable_ex),
        .clear_acc(MAC_Clear_ex),
        .A(src1_forwarded),
        .B(src2_forwarded),
        .result(mac_result_ex),
        .acc_low(mac_low_ex),
        .acc_high(mac_high_ex)
    );

    EX_MEM ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .flush(1'b0),
        .enable(EX_MEM_enable),
        .alu_result_in(alu_result_ex),
        .rs2_data_in(src2_forwarded),
        .branch_target_in(branch_target_ex),
        .zero_in(zero_ex),
        .rd_in(rd_ex),
        .pc_plus4_in(pc_plus4_ex),
        .mac_result_in(mac_result_ex),
        .mac_low_in(mac_low_ex),
        .mac_high_in(mac_high_ex),
        .RegWrite_in(RegWrite_ex),
        .MemRead_in(MemRead_ex),
        .MemWrite_in(MemWrite_ex),
        .MemToReg_in(MemToReg_ex),
        .Branch_in(Branch_ex),
        .JAL_en_in(JAL_en_ex),
        .JALR_en_in(JALR_en_ex),
        .LUI_en_in(LUI_en_ex),
        .MAC_Enable_in(MAC_Enable_ex),
        .MACLO_Enable_in(MACLO_Enable_ex),
        .MACHI_Enable_in(MACHI_Enable_ex),
        .alu_result_out(alu_result_mem),
        .rs2_data_out(rs2_data_mem),
        .branch_target_out(branch_target_mem),
        .zero_out(zero_mem),
        .rd_out(rd_mem),
        .pc_plus4_out(pc_plus4_mem),
        .mac_result_out(mac_result_mem),
        .mac_low_out(mac_low_mem),
        .mac_high_out(mac_high_mem),
        .RegWrite_out(RegWrite_mem),
        .MemRead_out(MemRead_mem),
        .MemWrite_out(MemWrite_mem),
        .MemToReg_out(MemToReg_mem),
        .Branch_out(Branch_mem),
        .JAL_en_out(JAL_en_mem),
        .JALR_en_out(JALR_en_mem),
        .LUI_en_out(LUI_en_mem),
        .MAC_Enable_out(MAC_Enable_mem),
        .MACLO_Enable_out(MACLO_Enable_mem),
        .MACHI_Enable_out(MACHI_Enable_mem)
    );

    // =========================================================================
    // Memory (MEM) Stage
    // =========================================================================
    data_mem dmem (
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead_mem),
        .MemWrite(MemWrite_mem),
        .address(alu_result_mem),
        .write_data(rs2_data_mem),
        .read_data(read_data_mem)
    );

    MEM_WB mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .enable(MEM_WB_enable),
        .memory_data_in(read_data_mem),
        .alu_result_in(alu_result_mem),
        .pc_plus4_in(pc_plus4_mem),
        .mac_result_in(mac_result_mem),
        .mac_low_in(mac_low_mem),
        .mac_high_in(mac_high_mem),
        .rd_in(rd_mem),
        .RegWrite_in(RegWrite_mem),
        .MemToReg_in(MemToReg_mem),
        .JAL_en_in(JAL_en_mem),
        .JALR_en_in(JALR_en_mem),
        .MAC_Enable_in(MAC_Enable_mem),
        .MACLO_Enable_in(MACLO_Enable_mem),
        .MACHI_Enable_in(MACHI_Enable_mem),
        .memory_data_out(memory_data_wb),
        .alu_result_out(alu_result_wb),
        .pc_plus4_out(pc_plus4_wb),
        .mac_result_out(mac_result_wb),
        .mac_low_out(mac_low_wb),
        .mac_high_out(mac_high_wb),
        .rd_out(rd_wb),
        .RegWrite_out(RegWrite_wb),
        .MemToReg_out(MemToReg_wb),
        .JAL_en_out(JAL_en_wb),
        .JALR_en_out(JALR_en_wb),
        .MAC_Enable_out(MAC_Enable_wb),
        .MACLO_Enable_out(MACLO_Enable_wb),
        .MACHI_Enable_out(MACHI_Enable_wb)
    );

    // =========================================================================
    // Writeback (WB) Stage & Debug Assignments
    // =========================================================================
    assign writeback_data = MAC_Enable_wb   ? mac_result_wb  :
                            MACLO_Enable_wb ? mac_low_wb     :
                            MACHI_Enable_wb ? mac_high_wb    :
                            (JAL_en_wb || JALR_en_wb) ? pc_plus4_wb :
                            MemToReg_wb     ? memory_data_wb : alu_result_wb;

    assign debug_pc              = pc_current;
    assign debug_alu_result      = alu_result_mem;
    assign debug_writeback_data  = writeback_data;
    assign debug_writeback_rd    = rd_wb;
    assign debug_regwrite        = RegWrite_wb;

endmodule
