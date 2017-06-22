`include "macro.v"

module id_ex_buffer(
    input   wire                        clock,
    input   wire                        reset,

    input   wire[`SIGNAL_BUS]           stall,

    input   wire[`ALU_OPERATOR_BUS]     id_operator,
    input   wire[`ALU_CATEGORY_BUS]     id_category,
    input   wire[`REGS_DATA_BUS]        id_operand1,
    input   wire[`REGS_DATA_BUS]        id_operand2,
    input   wire[`REGS_ADDR_BUS]        id_write_addr,
    input   wire                        id_write_enable,

    input   wire[`REGS_DATA_BUS]        id_return_target,
    input   wire                        id_is_curr_in_delayslot,

    input   wire                        input_is_next_in_delayslot,

    output  reg[`ALU_OPERATOR_BUS]      ex_operator,
    output  reg[`ALU_CATEGORY_BUS]      ex_category,
    output  reg[`REGS_DATA_BUS]         ex_operand1,
    output  reg[`REGS_DATA_BUS]         ex_operand2,
    output  reg[`REGS_ADDR_BUS]         ex_write_addr,
    output  reg                         ex_write_enable,

    output  reg[`REGS_DATA_BUS]         ex_return_target,
    output  reg                         ex_is_curr_in_delayslot,
    output  reg                         is_curr_in_delayslot
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            ex_operator <= 0;              // FIXME: EXE_NOP_OP should be used here, but I used 0
            ex_category <= 0;              // FIXME: EXE_RES_NOP should be used here, but I used 0
            ex_operand1 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_operand2 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_write_addr <= 0;            // FIXME: NOPRegAddr should be used here, but I used 0
            ex_write_enable <= `DISABLE;
            ex_return_target <= 0;         // FIXME: NOPRegAddr should be used here, but I used 0
            ex_is_curr_in_delayslot <= `FALSE;
            is_curr_in_delayslot <= `FALSE;
        end else if (stall[2] == `ENABLE && stall[3] == `DISABLE) begin
            ex_operator <= 0;              // FIXME: EXE_NOP_OP should be used here, but I used 0
            ex_category <= 0;              // FIXME: EXE_RES_NOP should be used here, but I used 0
            ex_operand1 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_operand2 <= 0;              // FIXME: ZERO_WORD should be used here, but I used 0
            ex_write_addr <= 0;            // FIXME: NOPRegAddr should be used here, but I used 0
            ex_write_enable <= `DISABLE;
            ex_return_target <= 0;
            ex_is_curr_in_delayslot <= `FALSE;
        end else if (stall[2] == `DISABLE) begin
            ex_operator <= id_operator;
            ex_category <= id_category;
            ex_operand1 <= id_operand1;
            ex_operand2 <= id_operand2;
            ex_write_addr <= id_write_addr;
            ex_write_enable <= id_write_enable;
            ex_return_target <= id_return_target;
            ex_is_curr_in_delayslot <= id_is_curr_in_delayslot;
            is_curr_in_delayslot <= input_is_next_in_delayslot;
        end
    end
    
endmodule // id_ex_buffer
