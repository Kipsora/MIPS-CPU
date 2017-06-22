`include "macro.v"

module ex_mem_buffer(
    input   wire                        clock,
    input   wire                        reset,

    input   wire[`SIGNAL_BUS]           stall,

    input   wire                        ex_write_enable,
    input   wire[`REGS_ADDR_BUS]        ex_write_addr,
    input   wire[`REGS_DATA_BUS]        ex_write_data,

    input   wire                        ex_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]        ex_write_hi_data,
    input   wire[`REGS_DATA_BUS]        ex_write_lo_data,

    input   wire[`DOUBLE_REGS_DATA_BUS] ex_current_result,
    input   wire[`CYCLE_BUS]            ex_current_cycle,

    input   wire[`ALU_OPERATOR_BUS]     ex_alu_operator,
    input   wire[`REGS_DATA_BUS]        ex_alu_operand2,
    input   wire[`REGS_DATA_BUS]        ex_ram_addr,

    output  reg                         mem_write_enable,
    output  reg[`REGS_ADDR_BUS]         mem_write_addr,
    output  reg[`REGS_DATA_BUS]         mem_write_data,

    output  reg                         mem_write_hilo_enable,
    output  reg[`REGS_DATA_BUS]         mem_write_hi_data,
    output  reg[`REGS_DATA_BUS]         mem_write_lo_data,

    output  reg[`DOUBLE_REGS_DATA_BUS]  mem_last_result,
    output  reg[`CYCLE_BUS]             mem_last_cycle,

    output  reg[`ALU_OPERATOR_BUS]      mem_alu_operator,
    output  reg[`REGS_DATA_BUS]         mem_alu_operand2,
    output  reg[`REGS_DATA_BUS]         mem_ram_addr
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            mem_write_enable <= `DISABLE;
            mem_write_data <= 0;               // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_addr <= 0;               // FIXME: NOPRegAddr should be used here, but 0 is used
            mem_write_hilo_enable <= `DISABLE;
            mem_write_hi_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_lo_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_last_result <= 0;              // FIXME: {`ZERO_WORD, `ZEROWORD} should be used here, but 0 is used
            mem_last_cycle <= 0;               // FIXME: 2'b00 should be used here, but 0 is used
            mem_alu_operator <= 0;             // FIXME: EXE_NOP_OP should be used here, but 0 is used
            mem_alu_operand2 <= 0;             // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_ram_addr <= 0;                 // FIXME: ZERO_WORD should be used here, but 0 is used
        end if (stall[3] == `ENABLE && stall[4] == `DISABLE) begin
            mem_write_enable <= `DISABLE;
            mem_write_data <= 0;               // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_addr <= 0;               // FIXME: NOPRegAddr should be used here, but 0 is used
            mem_write_hilo_enable <= `DISABLE;
            mem_write_hi_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_lo_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_last_result <= ex_current_result;
            mem_last_cycle <= ex_current_cycle;
            mem_alu_operator <= 0;             // FIXME: EXE_NOP_OP should be used here, but 0 is used
            mem_alu_operand2 <= 0;             // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_ram_addr <= 0;                 // FIXME: ZERO_WORD should be used here, but 0 is used
        end else if (stall[3] == `DISABLE) begin
            mem_write_enable <= ex_write_enable;
            mem_write_addr <= ex_write_addr;
            mem_write_data <= ex_write_data;
            mem_write_hilo_enable <= ex_write_hilo_enable;
            mem_write_hi_data <= ex_write_hi_data;
            mem_write_lo_data <= ex_write_lo_data;
            mem_last_result <= 0;              // FIXME: {`ZERO_WORD, `ZEROWORD} should be used here, but 0 is used
            mem_last_cycle <= 0;               // FIXME: 2'b00 should be used here, but 0 is used
            mem_alu_operator <= ex_alu_operator;
            mem_alu_operand2 <= ex_alu_operand2;
            mem_ram_addr <= ex_ram_addr;
        end else begin
            mem_last_result <= ex_current_result;
            mem_last_cycle <= ex_current_cycle;
        end
    end

endmodule // ex_mem_buffer
