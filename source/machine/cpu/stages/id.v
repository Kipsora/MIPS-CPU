`include "macro.v"

module id(
    input   wire                    reset,

    input   wire[`INST_ADDR_BUS]    program_counter,
    input   wire[`INST_DATA_BUS]    instruction,

    input   wire[`REGS_DATA_BUS]    read_result1,
    input   wire[`REGS_DATA_BUS]    read_result2,

    output  reg                     read_enable1,
    output  reg                     read_enable2,
    output  reg[`REGS_ADDR_BUS]     read_addr1,
    output  reg[`REGS_ADDR_BUS]     read_addr2,

    output  reg[`ALU_OPERATOR_BUS]  alu_operator,
    output  reg[`ALU_CATEGORY_BUS]  alu_category,
    output  reg[`REGS_DATA_BUS]     alu_operand1,
    output  reg[`REGS_DATA_BUS]     alu_operand2,

    output  reg                     write_enable,
    output  reg[`REGS_ADDR_BUS]     write_addr
);

    reg[`REGS_DATA_BUS]             imm;
    reg                             validality;

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
                default: begin
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            alu_operand1 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
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
        end else if (read_enable2 == `ENABLE) begin
            alu_operand2 <= read_result2;
        end else if (read_enable2 == `DISABLE) begin
            alu_operand2 <= imm;
        end else begin
            alu_operand2 <= 0;                  // FIXME: ZERO_WORD should be applied here, but 0 is used
        end
    end

endmodule // id
