`include "macro.v"

module ex(
    input   wire                        reset,

    input   wire[`REGS_DATA_BUS]        operand_hi,
    input   wire[`REGS_DATA_BUS]        operand_lo,

    input   wire                        wb_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]        wb_write_hi_data,
    input   wire[`REGS_DATA_BUS]        wb_write_lo_data,

    input   wire                        mem_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]        mem_write_hi_data,
    input   wire[`REGS_DATA_BUS]        mem_write_lo_data,

    input   wire[`DOUBLE_REGS_DATA_BUS] ex_div_result,
    input   wire                        ex_div_is_ended,

    input   wire[`ALU_OPERATOR_BUS]     operator,
    input   wire[`ALU_CATEGORY_BUS]     category,
    input   wire[`REGS_DATA_BUS]        operand1,
    input   wire[`REGS_DATA_BUS]        operand2,
    input   wire[`REGS_ADDR_BUS]        input_write_addr,
    input   wire                        input_write_enable,

    input   wire[`DOUBLE_REGS_DATA_BUS] last_result,
    input   wire[`CYCLE_BUS]            last_cycle,

    input   wire[`REGS_DATA_BUS]        return_target,
    input   wire                        is_curr_in_delayslot,

    output  reg[`REGS_DATA_BUS]         to_div_operand1,
    output  reg[`REGS_DATA_BUS]         to_div_operand2,
    output  reg                         to_div_is_start,
    output  reg                         to_div_is_signed,

    output  reg                         write_hilo_enable,
    output  reg[`REGS_DATA_BUS]         write_hi_data,
    output  reg[`REGS_DATA_BUS]         write_lo_data,

    output  reg[`REGS_ADDR_BUS]         write_addr,
    output  reg                         write_enable,
    output  reg[`REGS_DATA_BUS]         write_data,

    output  reg[`DOUBLE_REGS_DATA_BUS]  current_result,
    output  reg[`CYCLE_BUS]             current_cycle,

    output  reg                         stall_signal
);

    reg[`REGS_DATA_BUS]                 logic_result;
    reg[`REGS_DATA_BUS]                 shift_result;
    reg[`REGS_DATA_BUS]                 move_result;
    reg[`REGS_DATA_BUS]                 arithmetic_result;
    reg[`DOUBLE_REGS_DATA_BUS]          mult_result;

    reg[`REGS_DATA_BUS]                 hi_result_0;
    reg[`REGS_DATA_BUS]                 lo_result_0;
    reg[`REGS_DATA_BUS]                 hi_result_1;
    reg[`REGS_DATA_BUS]                 lo_result_1;
    wire                                is_overflow;
    wire[`REGS_DATA_BUS]                operand2_mux;
    wire[`REGS_DATA_BUS]                addition_sum;
    wire[`REGS_DATA_BUS]                operand1_not;
    wire[`REGS_DATA_BUS]                opdata1_mult;
    wire[`REGS_DATA_BUS]                opdata2_mult;
    reg                                 stall_signal_from_div;
    reg                                 stall_signal_from_mul;

    assign operand2_mux = (operator == `OPERATOR_SUB
        || operator == `OPERATOR_SUBU
        || operator == `OPERATOR_SLT) ?
        (~operand2) + 1 : operand2;
    
    assign operand1_not = ~operand1;

    assign addition_sum = operand1 + operand2_mux;

    assign is_overflow = ((!operand1[31] && !operand2_mux[31]) && addition_sum[31])
        || (operand1[31] && operand2_mux[31]) && (!addition_sum[31]);

    assign opdata1_mult = ((operator == `OPERATOR_MUL || operator == `OPERATOR_MULT || operator == `OPERATOR_MADD || operator == `OPERATOR_MSUB) && operand1[31]) ? (~operand1 + 1) : operand1;
    assign opdata2_mult = ((operator == `OPERATOR_MUL || operator == `OPERATOR_MULT || operator == `OPERATOR_MADD || operator == `OPERATOR_MSUB) && operand2[31]) ? (~operand2 + 1) : operand2;
    always @ (*) begin
        if (reset == `ENABLE) begin
            mult_result <= 0;                     // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
        end else if (operator == `OPERATOR_MUL || operator == `OPERATOR_MULT 
            || operator == `OPERATOR_MADD || operator == `OPERATOR_MSUB) begin
            if (operand1[31] ^ operand2[31] == 1'b1) begin // if the answer is negative
                mult_result <= ~(opdata1_mult * opdata2_mult) + 1;
            end else begin
                mult_result <= opdata1_mult * opdata2_mult;
            end
        end else begin // operator == `OPERATOR_MULTU
            mult_result <= operand1 * operand2;
        end
    end

    always @ (*) begin
        stall_signal <= stall_signal_from_div || stall_signal_from_mul;
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            to_div_operand1 <= 0;      // FIXME: ZERO_WORD should be used here
            to_div_operand2 <= 0;      // FIXME: ZERO_WORD should be used here
            to_div_is_start <= `FALSE;
            to_div_is_signed <= `FALSE;
            stall_signal_from_div <= `DISABLE;
        end else begin
            to_div_operand1 <= 0;      // FIXME: ZERO_WORD should be used here
            to_div_operand2 <= 0;      // FIXME: ZERO_WORD should be used here
            to_div_is_start <= `FALSE;
            to_div_is_signed <= `FALSE;
            stall_signal_from_div <= `DISABLE;
            case (operator)
                `OPERATOR_DIV: begin
                    if (ex_div_is_ended == `FALSE) begin
                        to_div_operand1 <= operand1;
                        to_div_operand2 <= operand2;
                        to_div_is_start <= `TRUE;
                        to_div_is_signed <= `TRUE;
                        stall_signal_from_div <= `ENABLE;
                    end else if (ex_div_is_ended == `TRUE) begin
                        to_div_operand1 <= operand1;
                        to_div_operand2 <= operand2;
                        to_div_is_start <= `FALSE;
                        to_div_is_signed <= `TRUE;
                        stall_signal_from_div <= `DISABLE;
                    end else begin
                        to_div_operand1 <= 0;      // FIXME: ZERO_WORD should be used here
                        to_div_operand2 <= 0;      // FIXME: ZERO_WORD should be used here
                        to_div_is_start <= `FALSE;
                        to_div_is_signed <= `FALSE;
                        stall_signal_from_div <= `DISABLE;
                    end
                end
                `OPERATOR_DIVU: begin
                    if (ex_div_is_ended == `FALSE) begin
                        to_div_operand1 <= operand1;
                        to_div_operand2 <= operand2;
                        to_div_is_start <= `TRUE;
                        to_div_is_signed <= `FALSE;
                        stall_signal_from_div <= `ENABLE;
                    end else if (ex_div_is_ended == `TRUE) begin
                        to_div_operand1 <= operand1;
                        to_div_operand2 <= operand2;
                        to_div_is_start <= `FALSE;
                        to_div_is_signed <= `FALSE;
                        stall_signal_from_div <= `DISABLE;
                    end else begin
                        to_div_operand1 <= 0;      // FIXME: ZERO_WORD should be used here
                        to_div_operand2 <= 0;      // FIXME: ZERO_WORD should be used here
                        to_div_is_start <= `FALSE;
                        to_div_is_signed <= `FALSE;
                        stall_signal_from_div <= `DISABLE;
                    end
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            current_result <= 0;                  // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
            current_cycle <= 0;                   // FIXME: 2'b00 should be used here, but 0 is used
            stall_signal_from_mul <= `DISABLE;
        end else begin
            case (operator)
                `OPERATOR_MADD, `OPERATOR_MADDU: begin
                    if (last_cycle == 0) begin    // FIXME: 2'b00 should be used here, but 0 is used
                        current_result <= mult_result;
                        current_cycle <= 1;       // FIXME: 2'b01 should be used here, but 1 is used
                        {hi_result_1, lo_result_1} <= 0; // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
                        stall_signal_from_mul <= `ENABLE;
                    end else if (last_cycle == 1) begin // FIXME: 2'b01 should be used here, but 0 is used
                        current_result <= 0;      // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
                        current_cycle <= 2;       // FIXME: 2'b10 should be used here, but 2 is used
                        {hi_result_1, lo_result_1} <= last_result + {hi_result_0, lo_result_0};
                        stall_signal_from_mul <= `DISABLE;
                    end
                end
                `OPERATOR_MSUB, `OPERATOR_MSUBU: begin
                    if (last_cycle == 0) begin    // FIXME: 2'b00 should be used here, but 0 is used
                        current_result <= ~mult_result + 1;
                        current_cycle <= 1;       // FIXME: 2'b01 should be used here, but 1 is used
                        {hi_result_1, lo_result_1} <= 0; // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used 
                                                         // TODO: check whether it is valid(added by myself)
                        stall_signal_from_mul <= `ENABLE;
                    end else if (last_cycle == 1) begin
                        current_result <= 0;      // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
                        current_cycle <= 2;       // FIXME: 2'b10 should be used here, but 2 is used
                        {hi_result_1, lo_result_1} <= last_result + {hi_result_0, lo_result_0};
                        stall_signal_from_mul <= `DISABLE;
                    end
                end
                default: begin
                    current_result <= 0;      // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
                    current_cycle <= 0;       // FIXME: 2'b00 should be used here, but 0 is used
                    stall_signal_from_mul <= `DISABLE;
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            arithmetic_result <= 0;               // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
        end else begin
            case (operator)
                `OPERATOR_SLT, `OPERATOR_SLTU: begin
                    arithmetic_result <=
                        ((operand1[31] && !operand2[31])
                            || (!operand1[31] && !operand2[31] && addition_sum[31])
                            || (operand1[31] && operand2[31] && addition_sum[31]));
                end
                `OPERATOR_SLTU: begin
                    arithmetic_result <= (operand1 < operand2);
                end
                `OPERATOR_ADD, `OPERATOR_ADDU,
                `OPERATOR_SUB, `OPERATOR_SUBU,
                `OPERATOR_ADDI, `OPERATOR_ADDIU: begin
                    arithmetic_result <= addition_sum;
                end
                `OPERATOR_CLZ: begin
                    arithmetic_result <= 
                        operand1[31] ? 0  : operand1[30] ? 1  : operand1[29] ? 2  :
                        operand1[28] ? 3  : operand1[27] ? 4  : operand1[26] ? 5  :
                        operand1[25] ? 6  : operand1[24] ? 7  : operand1[23] ? 8  :
                        operand1[22] ? 9  : operand1[21] ? 10 : operand1[20] ? 11 :
                        operand1[19] ? 12 : operand1[18] ? 13 : operand1[17] ? 14 :
                        operand1[16] ? 15 : operand1[15] ? 16 : operand1[14] ? 17 :
                        operand1[13] ? 18 : operand1[12] ? 19 : operand1[11] ? 20 :
                        operand1[10] ? 21 : operand1[9]  ? 22 : operand1[8]  ? 23 :
                        operand1[7]  ? 24 : operand1[6]  ? 25 : operand1[5]  ? 26 :
                        operand1[4]  ? 27 : operand1[3]  ? 28 : operand1[2]  ? 29 :
                        operand1[1]  ? 30 : operand1[0]  ? 31 : 32;
                end
                `OPERATOR_CLO: begin
                    arithmetic_result <= 
                        operand1_not[31] ? 0  : operand1_not[30] ? 1  : operand1_not[29] ? 2  :
                        operand1_not[28] ? 3  : operand1_not[27] ? 4  : operand1_not[26] ? 5  :
                        operand1_not[25] ? 6  : operand1_not[24] ? 7  : operand1_not[23] ? 8  :
                        operand1_not[22] ? 9  : operand1_not[21] ? 10 : operand1_not[20] ? 11 :
                        operand1_not[19] ? 12 : operand1_not[18] ? 13 : operand1_not[17] ? 14 :
                        operand1_not[16] ? 15 : operand1_not[15] ? 16 : operand1_not[14] ? 17 :
                        operand1_not[13] ? 18 : operand1_not[12] ? 19 : operand1_not[11] ? 20 :
                        operand1_not[10] ? 21 : operand1_not[9]  ? 22 : operand1_not[8]  ? 23 :
                        operand1_not[7]  ? 24 : operand1_not[6]  ? 25 : operand1_not[5]  ? 26 :
                        operand1_not[4]  ? 27 : operand1_not[3]  ? 28 : operand1_not[2]  ? 29 :
                        operand1_not[1]  ? 30 : operand1_not[0]  ? 31 : 32;
                end
                default: begin
                    arithmetic_result <= 0;               // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            {hi_result_0, lo_result_0} <= 0;          // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
        end else if (mem_write_hilo_enable == `ENABLE) begin
            {hi_result_0, lo_result_0} <= {mem_write_hi_data, mem_write_lo_data};
        end else if (wb_write_hilo_enable == `ENABLE) begin
            {hi_result_0, lo_result_0} <= {wb_write_hi_data, wb_write_lo_data};
        end else begin
            {hi_result_0, lo_result_0} <= {operand_hi, operand_lo};
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            move_result <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            move_result <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
            case (operator)
                `INST_MFHI_OPERATOR: begin
                    move_result <= hi_result_0;
                end
                `INST_MFLO_OPERATOR: begin
                    move_result <= lo_result_0;
                end
                `INST_MOVZ_OPERATOR: begin
                    move_result <= operand1;
                end
                `INST_MOVN_OPERATOR: begin
                    move_result <= operand1;
                end
                default: begin
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            logic_result <= 0;                      // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            case (operator)
                `OPERATOR_OR: begin
                    logic_result <= operand1 | operand2;
                end
                `OPERATOR_AND: begin
                    logic_result <= operand1 & operand2;
                end
                `OPERATOR_NOR: begin
                    logic_result <= ~(operand1 | operand2);
                end
                `OPERATOR_XOR: begin
                    logic_result <= operand1 ^ operand2;
                end
                default: begin
                    logic_result <= 0;              // FIXME: ZERO_WORD should be used here, but 0 is used
                end
            endcase
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            shift_result <= 0;                      // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            case (operator)
                `OPERATOR_SLL: begin
                    shift_result <= operand2 << operand1[4 : 0];
                end
                `OPERATOR_SRL: begin
                    shift_result <= operand2 >> operand1[4 : 0];
                end
                `OPERATOR_SRA: begin
                    shift_result <= ({32{operand2[31]}} << (6'd32 - {1'b0, operand1[4 : 0]})) 
                        | operand2 >> operand1[4 : 0];
                end
                default: begin
                    shift_result <= 0;              // FIXME: ZERO_WORD should be used here, but 0 is used
                end
            endcase
        end
    end

    always @ (*) begin
        write_addr <= input_write_addr;
        if ((operator == `OPERATOR_ADD || operator == `OPERATOR_ADDI
            || operator ==`OPERATOR_SUB) && is_overflow == 1'b1) begin
            write_enable <= `DISABLE;
        end else begin
            write_enable <= input_write_enable;
        end

        case (category)
            `CATEGORY_LOGIC: begin
                write_data <= logic_result;
            end
            `CATEGORY_SHIFT: begin
                write_data <= shift_result;
            end
            `CATEGORY_MOVE: begin
                write_data <= move_result;
            end
            `CATEGORY_ARITHMETIC: begin
                write_data <= arithmetic_result;
            end
            `CATEGORY_MULTIPLY: begin
                write_data <= mult_result;
            end
            `CATEGORY_FORK: begin
                write_data <= return_target;
            end
            default: begin
                write_data <= 0;                    // FIXME: ZERO_WORD should be used here, but 0 is used
            end
        endcase
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            write_hilo_enable <= `DISABLE;
            write_hi_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
            write_lo_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
        end else if (operator == `OPERATOR_DIV || operator == `OPERATOR_DIVU) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= ex_div_result[63 : 32];
            write_lo_data <= ex_div_result[31 : 0];
        end else if (operator == `OPERATOR_MSUB || operator == `OPERATOR_MSUBU
            || operator == `OPERATOR_MADD || operator == `OPERATOR_MADDU) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= hi_result_1;
            write_lo_data <= lo_result_1;
        end else if (operator == `OPERATOR_MULT || operator == `OPERATOR_MULTU) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= mult_result[63 : 32];
            write_lo_data <= mult_result[31 : 0];
        end else if (operator == `OPERATOR_MTHI) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= operand1;
            write_lo_data <= lo_result_0;
        end else if (operator == `OPERATOR_MTLO) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= hi_result_0;
            write_lo_data <= operand1;
        end else begin
            write_hilo_enable <= `DISABLE;
            write_hi_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
            write_lo_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
        end
    end

endmodule // ex
