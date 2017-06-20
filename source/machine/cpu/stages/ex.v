`include "macro.v"

module ex(
    input   wire                    reset,
    
    input   wire[`ALU_OPERATOR_BUS] operator,
    input   wire[`ALU_CATEGORY_BUS] category,
    input   wire[`REGS_DATA_BUS]    operand1,
    input   wire[`REGS_DATA_BUS]    operand2,
    input   wire[`REGS_ADDR_BUS]    input_write_addr,
    input   wire                    input_write_enable,

    output  reg[`REGS_ADDR_BUS]     write_addr,
    output  reg                     write_enable,
    output  reg[`REGS_DATA_BUS]     write_data
);

    reg[`REGS_DATA_BUS]             logic_result;

    always @ (*) begin
        if (reset == `ENABLE) begin
            logic_result <= 0;                      // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            case (operator)
                `OPERATOR_OR: begin
                    logic_result <= operand1 | operand2;
                end
                default: begin
                    logic_result <= 0;              // FIXME: ZERO_WORD should be used here, but 0 is used
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
            default: begin
                write_data <= 0;                    // FIXME: ZERO_WORD should be used here, but 0 is used
            end
        endcase
    end

endmodule // ex
