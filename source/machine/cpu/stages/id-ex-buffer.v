`include "macro.v"

module id_ex_buffer(
    input   wire                    clock,
    input   wire                    reset,

    input   wire[`ALU_OPERATOR_BUS] id_operator,
    input   wire[`ALU_CATEGORY_BUS] id_category,
    input   wire[`REGS_DATA_BUS]    id_operand1,
    input   wire[`REGS_DATA_BUS]    id_operand2,
    input   wire[`REGS_ADDR_BUS]    id_write_addr,
    input   wire                    id_write_enable,

    output  reg[`ALU_OPERATOR_BUS]  ex_operator,
    output  reg[`ALU_CATEGORY_BUS]  ex_category,
    output  reg[`REGS_DATA_BUS]     ex_operand1,
    output  reg[`REGS_DATA_BUS]     ex_operand2,
    output  reg[`REGS_ADDR_BUS]     ex_write_addr,
    output  reg                     ex_write_enable
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            ex_operator <= 0;              // FIXME: EXE_NOP_OP should be used here, but I used 0
            ex_category <= 0;              // FIXME: EXE_RES_NOP should be used here, but I used 0
            ex_operand1 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_operand2 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_write_addr <= 0;            // FIXME: NOPRegAddr should be used here, but I used 0
            ex_write_enable <= `DISABLE;
        end else begin
            ex_operator <= id_operator;
            ex_category <= id_category;
            ex_operand1 <= id_operand1;
            ex_operand2 <= id_operand2;
            ex_write_addr <= id_write_addr;
            ex_write_enable <= id_write_enable;
        end
    end
    
endmodule // id_ex_buffer
