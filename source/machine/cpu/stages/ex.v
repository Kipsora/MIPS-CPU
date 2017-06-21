`include "macro.v"

module ex(
    input   wire                    reset,

    input   wire[`REGS_DATA_BUS]    operand_hi,
    input   wire[`REGS_DATA_BUS]    operand_lo,

    input   wire                    wb_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]    wb_write_hi_data,
    input   wire[`REGS_DATA_BUS]    wb_write_lo_data,

    input   wire                    mem_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]    mem_write_hi_data,
    input   wire[`REGS_DATA_BUS]    mem_write_lo_data,

    input   wire[`ALU_OPERATOR_BUS] operator,
    input   wire[`ALU_CATEGORY_BUS] category,
    input   wire[`REGS_DATA_BUS]    operand1,
    input   wire[`REGS_DATA_BUS]    operand2,
    input   wire[`REGS_ADDR_BUS]    input_write_addr,
    input   wire                    input_write_enable,

    output  reg                     write_hilo_enable,
    output  reg[`REGS_DATA_BUS]     write_hi_data,
    output  reg[`REGS_DATA_BUS]     write_lo_data,

    output  reg[`REGS_ADDR_BUS]     write_addr,
    output  reg                     write_enable,
    output  reg[`REGS_DATA_BUS]     write_data
);

    reg[`REGS_DATA_BUS]             logic_result;
    reg[`REGS_DATA_BUS]             shift_result;
    reg[`REGS_DATA_BUS]             move_result;
    reg[`REGS_DATA_BUS]             hi_result;
    reg[`REGS_DATA_BUS]             lo_result;

    always @ (*) begin
        if (reset == `ENABLE) begin
            {hi_result, lo_result} <= 0;          // FIXME: {`ZERO_WORD, `ZERO_WORD} should be used here, but 0 is used
        end else if (mem_write_hilo_enable == `ENABLE) begin
            {hi_result, lo_result} <= {mem_write_hi_data, mem_write_lo_data};
        end else if (wb_write_hilo_enable == `ENABLE) begin
            {hi_result, lo_result} <= {wb_write_hi_data, wb_write_lo_data};
        end else begin
            {hi_result, lo_result} <= {operand_hi, operand_lo};
        end
    end

    always @ (*) begin
        if (reset == `ENABLE) begin
            move_result <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            move_result <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
            case (operator)
                `INST_MFHI_OPERATOR: begin
                    move_result <= hi_result;
                end
                `INST_MFLO_OPERATOR: begin
                    move_result <= lo_result;
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
        write_enable <= input_write_enable;
        write_addr <= input_write_addr;
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
        end else if (operator == `INST_MTHI_OPERATOR) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= operand1;
            write_lo_data <= lo_result;
        end else if (operator == `INST_MTLO_OPERATOR) begin
            write_hilo_enable <= `ENABLE;
            write_hi_data <= hi_result;
            write_lo_data <= operand1;
        end else begin
            write_hilo_enable <= `DISABLE;
            write_hi_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
            write_lo_data <= 0;                     // FIXME: ZERO_WORD should be used here, but 0 is used
        end
    end

endmodule // ex
