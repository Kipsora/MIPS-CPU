`include "macro.v"

module id(
    input   wire                        reset,

    input   wire[`INST_ADDR_BUS]        program_counter,
    input   wire[`INST_DATA_BUS]        instruction,

    input   wire                        ex_write_enable,
    input   wire[`REGS_ADDR_BUS]        ex_write_addr,
    input   wire[`REGS_DATA_BUS]        ex_write_data,

    input   wire                        mem_write_enable,
    input   wire[`REGS_ADDR_BUS]        mem_write_addr,
    input   wire[`REGS_DATA_BUS]        mem_write_data,

    input   wire[`REGS_DATA_BUS]        read_result1,
    input   wire[`REGS_DATA_BUS]        read_result2,

    output  reg                         read_enable1,
    output  reg                         read_enable2,
    output  reg[`REGS_ADDR_BUS]         read_addr1,
    output  reg[`REGS_ADDR_BUS]         read_addr2,

    output  reg[`ALU_OPERATOR_BUS]      alu_operator,
    output  reg[`ALU_CATEGORY_BUS]      alu_category,
    output  reg[`REGS_DATA_BUS]         alu_operand1,
    output  reg[`REGS_DATA_BUS]         alu_operand2,

    output  reg                         write_enable,
    output  reg[`REGS_ADDR_BUS]         write_addr,

    output  wire                        stall_signal
);

    reg[`REGS_DATA_BUS]                 imm;
    reg                                 validality;

    assign stall_signal = `DISABLE;

    always @ (*) begin
        if (reset == `ENABLE) begin
            alu_operator <= `INST_NOP_OPERATOR;
            alu_category <= `INST_NOP_CATEGORY;
            write_addr <= 0;                    // FIXME: NOPRegAddr should be applied here, but 0 is used
            write_enable <= `DISABLE;
            validality <= `VALID;
            read_enable1 <= `DISABLE;
            read_enable2 <= `DISABLE;
            read_addr1 <= 0;                    // FIXME: NOPRegAddr should be applied here, but 0 is used
            read_addr2 <= 0;                    // FIXME: NOPRegAddr should be applied here, but 0 is used
            imm <= 0;                           // FIXME: ZERO_WORD should be applied here, but 0 is used
        end else begin
            alu_operator <= `INST_NOP_OPERATOR;
            alu_category <= `INST_NOP_CATEGORY;
            write_enable <= `DISABLE;
            write_addr <= instruction[15 : 11];
            validality <= `INVALID;
            read_enable1 <= `DISABLE;
            read_enable2 <= `DISABLE;
            read_addr1 <= instruction[25 : 21];
            read_addr2 <= instruction[20 : 16];
            imm <= 0;                           // FIXME: ZERO_WORD should be applied here, but 0 is used
            case (instruction[31 : 26])
                6'b000000: begin                // category 1: special instruction
                    if (instruction[10 : 6] == 5'b00000) begin
                        case (instruction[5 : 0])
                            `INST_OR_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_OR_OPERATOR;
                                alu_category <= `INST_OR_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_AND_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_AND_OPERATOR;
                                alu_category <= `INST_AND_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_XOR_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_XOR_OPERATOR;
                                alu_category <= `INST_XOR_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_NOR_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_NOR_OPERATOR;
                                alu_category <= `INST_NOR_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SLLV_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SLLV_OPERATOR;
                                alu_category <= `INST_SLLV_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SRLV_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SRLV_OPERATOR;
                                alu_category <= `INST_SRLV_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SRAV_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SRAV_OPERATOR;
                                alu_category <= `INST_SRAV_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SYNC_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SYNC_OPERATOR;
                                alu_category <= `INST_SYNC_CATEGORY;
                                read_enable1 <= `DISABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_MFHI_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_MFHI_OPERATOR;
                                alu_category <= `INST_MFHI_CATEGORY;
                                read_enable1 <= `DISABLE;
                                read_enable2 <= `DISABLE;
                                validality <= `VALID;
                            end
                            `INST_MFLO_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_MFLO_OPERATOR;
                                alu_category <= `INST_MFLO_CATEGORY;
                                read_enable1 <= `DISABLE;
                                read_enable2 <= `DISABLE;
                                validality <= `VALID;
                            end
                            `INST_MTHI_ID: begin // FIXME: due to no data being written to gpr-file, 
                                                 //        thus alu_category <= `INST_MTHI_CATEGORY is not needed.
                                write_enable <= `DISABLE;
                                alu_operator <= `INST_MTHI_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `DISABLE;
                                validality <= `VALID;
                            end
                            `INST_MTLO_ID: begin // FIXME: due to no data being written to gpr-file, 
                                                 //        thus alu_category <= `INST_MTHI_CATEGORY is not needed.
                                write_enable <= `DISABLE;
                                alu_operator <= `INST_MTLO_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `DISABLE;
                                validality <= `VALID;
                            end
                            `INST_MOVN_ID: begin
                                if (alu_operand2 != 0) begin // FIXME: 0 is used here, but `ZERO_WORD is expected
                                    write_enable <= `ENABLE;
                                end else begin
                                    write_enable <= `DISABLE;
                                end
                                alu_operator <= `INST_MOVN_OPERATOR;
                                alu_category <= `INST_MOVN_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_MOVZ_ID: begin
                                if (alu_operand2 == 0) begin // FIXME: 0 is used here, but `ZERO_WORD is expected
                                    write_enable <= `ENABLE;
                                end else begin
                                    write_enable <= `DISABLE;
                                end
                                alu_operator <= `INST_MOVZ_OPERATOR;
                                alu_category <= `INST_MOVZ_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SLT_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SLT_OPERATOR;
                                alu_category <= `INST_SLT_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SLTU_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SLTU_OPERATOR;
                                alu_category <= `INST_SLTU_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_ADD_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_ADD_OPERATOR;
                                alu_category <= `INST_ADD_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_ADDU_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_ADDU_OPERATOR;
                                alu_category <= `INST_ADDU_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SUB_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SUB_OPERATOR;
                                alu_category <= `INST_SUB_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_SUBU_ID: begin
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_SUBU_OPERATOR;
                                alu_category <= `INST_SUBU_CATEGORY;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_MULT_ID: begin // FIXME: mult has no category due to no data
                                                 // are needed to write back
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_MULT_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_MULTU_ID: begin // FIXME: multu has no category due to no data
                                                  // are needed to write back
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_MULTU_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_DIV_ID: begin // FIXME: div has no category due to no data
                                                // are needed to write back to gprfile
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_DIV_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            `INST_DIVU_ID: begin // FIXME: divu has no category due to no data
                                                 // are needed to write back to gprfile
                                write_enable <= `ENABLE;
                                alu_operator <= `INST_DIVU_OPERATOR;
                                read_enable1 <= `ENABLE;
                                read_enable2 <= `ENABLE;
                                validality <= `VALID;
                            end
                            default: begin
                            end
                        endcase
                    end
                end
                6'b011100: begin                // category 2: special instruction
                    case (instruction[5 : 0])
                        `INST_CLZ_ID: begin
                            write_enable <= `ENABLE;
                            alu_operator <= `INST_CLZ_OPERATOR;
                            alu_category <= `INST_CLZ_CATEGORY;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `DISABLE;
                            validality <= `VALID;
                        end
                        `INST_CLO_ID: begin
                            write_enable <= `ENABLE;
                            alu_operator <= `INST_CLO_OPERATOR;
                            alu_category <= `INST_CLO_CATEGORY;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `DISABLE;
                            validality <= `VALID;
                        end
                        `INST_MUL_ID: begin 
                            write_enable <= `ENABLE;
                            alu_operator <= `INST_MUL_OPERATOR;
                            alu_category <= `INST_MUL_CATEGORY;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `ENABLE;
                            validality <= `VALID;
                        end
                        `INST_MADD_ID: begin // FIXME: mult has no category due to no data
                                             // are needed to write back
                            write_enable <= `DISABLE;
                            alu_operator <= `INST_MADD_OPERATOR;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `ENABLE;
                            validality <= `VALID;
                        end
                        `INST_MADDU_ID: begin // FIXME: mult has no category due to no data
                                              // are needed to write back
                            write_enable <= `DISABLE;
                            alu_operator <= `INST_MADDU_OPERATOR;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `ENABLE;
                            validality <= `VALID;
                        end
                        `INST_MSUB_ID: begin // FIXME: mult has no category due to no data
                                             // are needed to write back
                            write_enable <= `DISABLE;
                            alu_operator <= `INST_MSUB_OPERATOR;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `ENABLE;
                            validality <= `VALID;
                        end
                        `INST_MSUBU_ID: begin // FIXME: mult has no category due to no data
                                              // are needed to write back
                            write_enable <= `DISABLE;
                            alu_operator <= `INST_MSUBU_OPERATOR;
                            read_enable1 <= `ENABLE;
                            read_enable2 <= `ENABLE;
                            validality <= `VALID;
                        end
                        default: begin
                        end
                    endcase
                end
                `INST_ORI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_ORI_OPERATOR;
                    alu_category <= `INST_ORI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {16'h0, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_ANDI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_ANDI_OPERATOR;
                    alu_category <= `INST_ANDI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {16'h0, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_XORI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_XORI_OPERATOR;
                    alu_category <= `INST_XORI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {16'h0, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_LUI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_LUI_OPERATOR;
                    alu_category <= `INST_LUI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {instruction[15 : 0], 16'h0};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_PREF_ID: begin
                    write_enable <= `DISABLE;
                    alu_operator <= `INST_PREF_OPERATOR;
                    alu_category <= `INST_PREF_CATEGORY;
                    read_enable1 <= `DISABLE;
                    read_enable2 <= `DISABLE;
                    validality <= `VALID;
                end
                `INST_SLTI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_SLTI_OPERATOR;
                    alu_category <= `INST_SLTI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {{16{instruction[15]}}, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_SLTIU_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_SLTIU_OPERATOR;
                    alu_category <= `INST_SLTIU_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {{16{instruction[15]}}, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_ADDI_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_ADDI_OPERATOR;
                    alu_category <= `INST_ADDI_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {{16{instruction[15]}}, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                `INST_ADDIU_ID: begin
                    write_enable <= `ENABLE;
                    alu_operator <= `INST_ADDIU_OPERATOR;
                    alu_category <= `INST_ADDIU_CATEGORY;
                    read_enable1 <= `ENABLE;
                    read_enable2 <= `DISABLE;
                    imm <= {{16{instruction[15]}}, instruction[15 : 0]};
                    write_addr <= instruction[20 : 16];
                    validality <= `VALID;
                end
                default: begin
                end
            endcase
            if (instruction[31 : 21] == 11'b00000000000) begin
                case (instruction[5 : 0])
                    `INST_SLL_ID: begin
                        write_enable <= `ENABLE;
                        alu_operator <= `INST_SLL_OPERATOR;
                        alu_category <= `INST_SLL_CATEGORY;
                        read_enable1 <= `DISABLE;
                        read_enable2 <= `ENABLE;
                        imm[4 : 0] <= instruction[10 : 6];
                        write_addr <= instruction[15 : 11];
                        validality <= `VALID;
                    end
                    `INST_SRL_ID: begin
                        write_enable <= `ENABLE;
                        alu_operator <= `INST_SRL_OPERATOR;
                        alu_category <= `INST_SRL_CATEGORY;
                        read_enable1 <= `DISABLE;
                        read_enable2 <= `ENABLE;
                        imm[4 : 0] <= instruction[10 : 6];
                        write_addr <= instruction[15 : 11];
                        validality <= `VALID;
                    end
                    `INST_SRA_ID: begin
                        write_enable <= `ENABLE;
                        alu_operator <= `INST_SRA_OPERATOR;
                        alu_category <= `INST_SRA_CATEGORY;
                        read_enable1 <= `DISABLE;
                        read_enable2 <= `ENABLE;
                        imm[4 : 0] <= instruction[10 : 6];
                        write_addr <= instruction[15 : 11];
                        validality <= `VALID;
                    end
                endcase
            end
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            alu_operand1 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
        end else if (read_enable1 == `ENABLE && ex_write_enable == `ENABLE && ex_write_addr == read_addr1) begin
            alu_operand1 <= ex_write_data;
        end else if (read_enable1 == `ENABLE && mem_write_enable == `ENABLE && mem_write_addr == read_addr1) begin
            alu_operand1 <= mem_write_data;
        end else if (read_enable1 == `ENABLE) begin
            alu_operand1 <= read_result1;
        end else if (read_enable1 == `DISABLE) begin
            alu_operand1 <= imm;
        end else begin
            alu_operand1 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            alu_operand2 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
        end else if (read_enable2 == `ENABLE && ex_write_enable == `ENABLE && ex_write_addr == read_addr2) begin
            alu_operand2 <= ex_write_data;
        end else if (read_enable2 == `ENABLE && mem_write_enable == `ENABLE && mem_write_addr == read_addr2) begin
            alu_operand2 <= mem_write_data;
        end else if (read_enable2 == `ENABLE) begin
            alu_operand2 <= read_result2;
        end else if (read_enable2 == `DISABLE) begin
            alu_operand2 <= imm;
        end else begin
            alu_operand2 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
        end
    end

endmodule // id
