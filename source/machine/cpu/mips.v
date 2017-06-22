`include "macro.v"
`include "machine/cpu/control.v"
`include "machine/cpu/stages/pc-reg.v"
`include "machine/cpu/stages/if-id-buffer.v"
`include "machine/cpu/stages/id.v"
`include "machine/cpu/regfile/gpr-file.v"
`include "machine/cpu/regfile/hilo-file.v"
`include "machine/cpu/stages/id-ex-buffer.v"
`include "machine/cpu/stages/ex.v"
`include "machine/cpu/stages/ex-div.v"
`include "machine/cpu/stages/ex-mem-buffer.v"
`include "machine/cpu/stages/mem.v"
`include "machine/cpu/stages/mem-wb-buffer.v"

module mips(
    input   wire                        clock,
    input   wire                        reset,

    input   wire[`INST_DATA_BUS]        rom_data,

    output  wire[`INST_ADDR_BUS]        rom_addr,
    output  wire                        rom_chip_enable
);
    wire[`INST_ADDR_BUS]                if_program_counter;

    wire[`INST_ADDR_BUS]                id_program_counter;
    wire[`INST_DATA_BUS]                id_instruction;
    wire[`ALU_OPERATOR_BUS]             id_alu_operator;
    wire[`ALU_CATEGORY_BUS]             id_alu_category;
    wire[`REGS_DATA_BUS]                id_alu_operand1;
    wire[`REGS_DATA_BUS]                id_alu_operand2;
    wire                                id_write_enable;
    wire[`REGS_ADDR_BUS]                id_write_addr;

    wire[`ALU_OPERATOR_BUS]             id_ex_buffer_alu_operator;
    wire[`ALU_CATEGORY_BUS]             id_ex_buffer_alu_category;
    wire[`REGS_DATA_BUS]                id_ex_buffer_alu_operand1;
    wire[`REGS_DATA_BUS]                id_ex_buffer_alu_operand2;
    wire                                id_ex_buffer_write_enable;
    wire[`REGS_ADDR_BUS]                id_ex_buffer_write_addr;

    wire                                ex_write_enable;
    wire[`REGS_ADDR_BUS]                ex_write_addr;
    wire[`REGS_DATA_BUS]                ex_write_data;
    wire                                ex_write_hilo_enable;
    wire[`REGS_DATA_BUS]                ex_write_hi_data;
    wire[`REGS_DATA_BUS]                ex_write_lo_data;
    wire[`REGS_DATA_BUS]                ex_to_div_operand1;
    wire[`REGS_DATA_BUS]                ex_to_div_operand2;
    wire                                ex_to_div_is_start;
    wire                                ex_to_div_is_signed;

    wire[`DOUBLE_REGS_DATA_BUS]         ex_div_result;
    wire                                ex_div_is_ended;

    wire                                ex_mem_buffer_write_enable;
    wire[`REGS_ADDR_BUS]                ex_mem_buffer_write_addr;
    wire[`REGS_DATA_BUS]                ex_mem_buffer_write_data;
    wire                                ex_mem_buffer_write_hilo_enable;
    wire[`REGS_DATA_BUS]                ex_mem_buffer_write_hi_data;
    wire[`REGS_DATA_BUS]                ex_mem_buffer_write_lo_data;

    wire                                mem_write_enable;
    wire[`REGS_ADDR_BUS]                mem_write_addr;
    wire[`REGS_DATA_BUS]                mem_write_data;
    wire                                mem_write_hilo_enable;
    wire[`REGS_DATA_BUS]                mem_write_hi_data;
    wire[`REGS_DATA_BUS]                mem_write_lo_data;

    wire                                mem_wb_buffer_write_enable;
    wire[`REGS_ADDR_BUS]                mem_wb_buffer_write_addr;
    wire[`REGS_DATA_BUS]                mem_wb_buffer_write_data;
    wire                                mem_wb_buffer_write_hilo_enable;
    wire[`REGS_DATA_BUS]                mem_wb_buffer_write_hi_data;
    wire[`REGS_DATA_BUS]                mem_wb_buffer_write_lo_data;

    wire                                gpr_file_read_enable1;
    wire                                gpr_file_read_enable2;
    wire[`REGS_ADDR_BUS]                gpr_file_read_addr1;
    wire[`REGS_ADDR_BUS]                gpr_file_read_addr2;
    wire[`REGS_DATA_BUS]                gpr_file_read_result1;
    wire[`REGS_DATA_BUS]                gpr_file_read_result2;

    wire[`REGS_DATA_BUS]                hilo_file_hi_data;
    wire[`REGS_DATA_BUS]                hilo_file_lo_data;

    wire[`SIGNAL_BUS]                   stall_signal;
    wire                                stall_from_id;
    wire                                stall_from_ex;

    wire[`DOUBLE_REGS_DATA_BUS]         ex_current_result;
    wire[`CYCLE_BUS]                    ex_current_cycle;
    wire[`DOUBLE_REGS_DATA_BUS]         ex_mem_last_result;
    wire[`CYCLE_BUS]                    ex_mem_last_cycle;

    wire                                curr_next_is_in_delayslot_connector;
    wire                                id_is_curr_in_delayslot;
    wire                                id_is_next_in_delayslot;
    wire                                id_branch_signal;
    wire[`REGS_DATA_BUS]                id_branch_target;
    wire[`REGS_DATA_BUS]                id_return_target;
    wire                                id_ex_is_curr_in_delayslot;
    wire[`REGS_DATA_BUS]                id_ex_return_target;

    pc_reg                              pc_reg_instance(
        .clock(clock), 
        .reset(reset),
        .stall(stall_signal),
        .program_counter(if_program_counter),
        .chip_enable(rom_chip_enable),
        .branch_signal(id_branch_signal),
        .branch_target(id_branch_target)
    );

    assign rom_addr = if_program_counter;

    control                             control_instance(
        .reset(reset),
        .stall_from_id(stall_from_id),
        .stall_from_ex(stall_from_ex),
        .stall(stall_signal)
    );

    if_id_buffer                        if_id_buffer_instance(
        .clock(clock),
        .reset(reset),
        .stall(stall_signal),
        .if_program_counter(if_program_counter),
        .if_instruction(rom_data),
        .id_program_counter(id_program_counter),
        .id_instruction(id_instruction)
    );

    gpr_file                            gpr_file_instance(
        .clock(clock),
        .reset(reset),
        .write_enable(mem_wb_buffer_write_enable),
        .write_addr(mem_wb_buffer_write_addr),
        .write_data(mem_wb_buffer_write_data),
        .read_enable1(gpr_file_read_enable1),
        .read_addr1(gpr_file_read_addr1),
        .read_data1(gpr_file_read_result1),
        .read_enable2(gpr_file_read_enable2),
        .read_addr2(gpr_file_read_addr2),
        .read_data2(gpr_file_read_result2)
    );

    hilo_file                           hilo_file_instance(
        .clock(clock),
        .reset(reset),
        .write_hilo_enable(mem_wb_buffer_write_hilo_enable),
        .write_hi_data(mem_wb_buffer_write_hi_data),
        .write_lo_data(mem_wb_buffer_write_lo_data),
        .hi_data(hilo_file_hi_data),
        .lo_data(hilo_file_lo_data)
    );

    id                                  id_instance(
        .reset(reset),
        .program_counter(id_program_counter),
        .instruction(id_instruction),
        .ex_write_enable(ex_write_enable),
        .ex_write_addr(ex_write_addr),
        .ex_write_data(ex_write_data),
        .mem_write_enable(mem_write_enable),
        .mem_write_addr(mem_write_addr),
        .mem_write_data(mem_write_data),
        .read_result1(gpr_file_read_result1),
        .read_result2(gpr_file_read_result2),
        .input_is_curr_in_delayslot(curr_next_is_in_delayslot_connector),
        .is_curr_in_delayslot(id_is_curr_in_delayslot),
        .is_next_in_delayslot(id_is_next_in_delayslot),
        .branch_signal(id_branch_signal),
        .branch_target(id_branch_target),
        .return_target(id_return_target),
        .read_enable1(gpr_file_read_enable1),
        .read_enable2(gpr_file_read_enable2),
        .read_addr1(gpr_file_read_addr1),
        .read_addr2(gpr_file_read_addr2),
        .alu_operator(id_alu_operator),
        .alu_category(id_alu_category),
        .alu_operand1(id_alu_operand1),
        .alu_operand2(id_alu_operand2),
        .write_enable(id_write_enable),
        .write_addr(id_write_addr),
        .stall_signal(stall_from_id)
    );

    id_ex_buffer                        id_ex_buffer_instance(
        .clock(clock),
        .reset(reset),
        .stall(stall_signal),
        .id_operator(id_alu_operator),
        .id_category(id_alu_category),
        .id_operand1(id_alu_operand1),
        .id_operand2(id_alu_operand2),
        .id_write_addr(id_write_addr),
        .id_write_enable(id_write_enable),
        .id_return_target(id_return_target),
        .id_is_curr_in_delayslot(id_is_curr_in_delayslot),
        .input_is_next_in_delayslot(id_is_next_in_delayslot),
        .ex_operator(id_ex_buffer_alu_operator),
        .ex_category(id_ex_buffer_alu_category),
        .ex_operand1(id_ex_buffer_alu_operand1),
        .ex_operand2(id_ex_buffer_alu_operand2),
        .ex_write_addr(id_ex_buffer_write_addr),
        .ex_write_enable(id_ex_buffer_write_enable),
        .ex_return_target(id_ex_return_target),
        .ex_is_curr_in_delayslot(id_ex_is_curr_in_delayslot),
        .is_curr_in_delayslot(curr_next_is_in_delayslot_connector)
    );

    ex                                  ex_instance(
        .reset(reset),
        .operand_hi(hilo_file_hi_data),
        .operand_lo(hilo_file_lo_data),
        .wb_write_hilo_enable(mem_wb_buffer_write_hilo_enable),
        .wb_write_hi_data(mem_wb_buffer_write_hi_data),
        .wb_write_lo_data(mem_wb_buffer_write_lo_data),
        .mem_write_hilo_enable(mem_write_hilo_enable),
        .mem_write_hi_data(mem_write_hi_data),
        .mem_write_lo_data(mem_write_lo_data),
        .ex_div_result(ex_div_result),
        .ex_div_is_ended(ex_div_is_ended),
        .operator(id_ex_buffer_alu_operator),
        .category(id_ex_buffer_alu_category),
        .operand1(id_ex_buffer_alu_operand1),
        .operand2(id_ex_buffer_alu_operand2),
        .input_write_addr(id_ex_buffer_write_addr),
        .input_write_enable(id_ex_buffer_write_enable),
        .last_result(ex_mem_last_result),
        .last_cycle(ex_mem_last_cycle),
        .return_target(id_ex_return_target),
        .is_curr_in_delayslot(id_ex_is_curr_in_delayslot),
        .to_div_operand1(ex_to_div_operand1),
        .to_div_operand2(ex_to_div_operand2),
        .to_div_is_start(ex_to_div_is_start),
        .to_div_is_signed(ex_to_div_is_signed),
        .write_hilo_enable(ex_write_hilo_enable),
        .write_hi_data(ex_write_hi_data),
        .write_lo_data(ex_write_lo_data),
        .write_addr(ex_write_addr),
        .write_enable(ex_write_enable),
        .write_data(ex_write_data),
        .current_result(ex_current_result),
        .current_cycle(ex_current_cycle),
        .stall_signal(stall_from_ex)
    );

    ex_div                              ex_div_instance(
        .clock(clock),
        .reset(reset),
        .is_signed(ex_to_div_is_signed),
        .operand1(ex_to_div_operand1),
        .operand2(ex_to_div_operand2),
        .is_start(ex_to_div_is_start),
        .is_annul(1'b0),
        .is_ended(ex_div_is_ended),
        .result(ex_div_result)
    );

    ex_mem_buffer                       ex_mem_buffer_instance(
        .clock(clock),
        .reset(reset),
        .stall(stall_signal),
        .ex_write_enable(ex_write_enable),
        .ex_write_addr(ex_write_addr),
        .ex_write_data(ex_write_data),
        .ex_write_hilo_enable(ex_write_hilo_enable),
        .ex_write_hi_data(ex_write_hi_data),
        .ex_write_lo_data(ex_write_lo_data),
        .ex_current_result(ex_current_result),
        .ex_current_cycle(ex_current_cycle),
        .mem_write_enable(ex_mem_buffer_write_enable),
        .mem_write_addr(ex_mem_buffer_write_addr),
        .mem_write_data(ex_mem_buffer_write_data),
        .mem_write_hilo_enable(ex_mem_buffer_write_hilo_enable),
        .mem_write_hi_data(ex_mem_buffer_write_hi_data),
        .mem_write_lo_data(ex_mem_buffer_write_lo_data),
        .mem_last_result(ex_mem_last_result),
        .mem_last_cycle(ex_mem_last_cycle)
    );

    mem                                 mem_instance(
        .reset(reset),
        .input_write_enable(ex_mem_buffer_write_enable),
        .input_write_addr(ex_mem_buffer_write_addr),
        .input_write_data(ex_mem_buffer_write_data),
        .input_write_hilo_enable(ex_mem_buffer_write_hilo_enable),
        .input_write_hi_data(ex_mem_buffer_write_hi_data),
        .input_write_lo_data(ex_mem_buffer_write_lo_data),
        .write_enable(mem_write_enable),
        .write_addr(mem_write_addr),
        .write_data(mem_write_data),
        .write_hilo_enable(mem_write_hilo_enable),
        .write_hi_data(mem_write_hi_data),
        .write_lo_data(mem_write_lo_data)
    );

    mem_wb_buffer                       mem_wb_buffer_instance(
        .clock(clock),
        .reset(reset),
        .stall(stall_signal),
        .mem_write_enable(mem_write_enable),
        .mem_write_addr(mem_write_addr),
        .mem_write_data(mem_write_data),
        .mem_write_hilo_enable(mem_write_hilo_enable),
        .mem_write_hi_data(mem_write_hi_data),
        .mem_write_lo_data(mem_write_lo_data),
        .wb_write_enable(mem_wb_buffer_write_enable),
        .wb_write_addr(mem_wb_buffer_write_addr),
        .wb_write_data(mem_wb_buffer_write_data),
        .wb_write_hilo_enable(mem_wb_buffer_write_hilo_enable),
        .wb_write_hi_data(mem_wb_buffer_write_hi_data),
        .wb_write_lo_data(mem_wb_buffer_write_lo_data)
    );

endmodule // mips
