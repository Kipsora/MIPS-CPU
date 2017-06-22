`include "macro.v"

module mem(
    input   wire                        reset,

    input   wire                        input_write_enable,
    input   wire[`REGS_ADDR_BUS]        input_write_addr,
    input   wire[`REGS_DATA_BUS]        input_write_data,

    input   wire                        input_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]        input_write_hi_data,
    input   wire[`REGS_DATA_BUS]        input_write_lo_data,

    input   wire[`ALU_OPERATOR_BUS]     input_alu_operator,
    input   wire[`REGS_DATA_BUS]        input_alu_operand2,
    input   wire[`REGS_DATA_BUS]        input_ram_addr,

    input   wire[`REGS_DATA_BUS]        input_ram_read_data,

    output  reg                         write_enable,
    output  reg[`REGS_ADDR_BUS]         write_addr,
    output  reg[`REGS_DATA_BUS]         write_data,

    output  reg                         write_hilo_enable,
    output  reg[`REGS_DATA_BUS]         write_hi_data,
    output  reg[`REGS_DATA_BUS]         write_lo_data,

    output  reg[`REGS_DATA_BUS]         ram_addr,
    output  wire                        ram_operation,     // 0 is read, 1 is write
    output  reg[`BYTE_SEL_BUS]          ram_select_signal,
    output  reg[`REGS_DATA_BUS]         ram_write_data,
    output  reg                         ram_chip_enable
);

    wire[`REGS_DATA_BUS]                zero32;
    reg                                 ram_operation_register;

    assign ram_operation = ram_operation_register;
    assign zero32 = 0;  // FIXME: `ZEROWORD should be used here, but 0 is used

    always @ (*) begin
        if (reset == `ENABLE) begin
            write_enable <= `DISABLE;
            write_addr <= 0;                // FIXME: 0 is used here, but NOPRegAddr is expected 
            write_data <= 0;                // FIXME: 0 is used here, but ZERO_WORD is expected 
            write_hilo_enable <= `DISABLE;
            write_hi_data <= 0;             // FIXME: 0 is used here, but NOPRegAddr is expected 
            write_lo_data <= 0;             // FIXME: 0 is used here, but ZERO_WORD is expected 
            ram_addr <= 0;                  // FIXME: 0 is used here, but ZERO_WORD is expected 
            ram_operation_register <= `DISABLE;
            ram_select_signal <= 0;         // FIXME: 0 is used here, but 4'b0000 is expected 
            ram_write_data <= 0;            // FIXME: 0 is used here, but ZERO_WORD is expected 
            ram_chip_enable <= `DISABLE;
        end else begin
            write_enable <= input_write_enable;
            write_addr <= input_write_addr;
            write_data <= input_write_data;
            write_hilo_enable <= input_write_hilo_enable;
            write_hi_data <= input_write_hi_data;
            write_lo_data <= input_write_lo_data;
            ram_operation_register <= `DISABLE;
            ram_addr <= 0;                  // FIXME: 0 is used here, but ZERO_WORD is expected 
            ram_select_signal <= 4'b1111;
            ram_chip_enable <= `DISABLE;
            case (input_alu_operator)
                `OPERATOR_LB: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_READ;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= {{24{input_ram_read_data[31]}}, input_ram_read_data[31 : 24]};
                            ram_select_signal <= 4'b1000;
                        end
                        2'b01: begin
                            write_data <= {{24{input_ram_read_data[23]}}, input_ram_read_data[23 : 16]};
                            ram_select_signal <= 4'b0100;
                        end
                        2'b10: begin
                            write_data <= {{24{input_ram_read_data[15]}}, input_ram_read_data[15 : 8]};
                            ram_select_signal <= 4'b0010;
                        end
                        2'b11: begin
                            write_data <= {{24{input_ram_read_data[7]}}, input_ram_read_data[7 : 0]};
                            ram_select_signal <= 4'b0001;
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_LBU: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_READ;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= {{24{1'b0}}, input_ram_read_data[31 : 24]};
                            ram_select_signal <= 4'b1000;
                        end
                        2'b01: begin
                            write_data <= {{24{1'b0}}, input_ram_read_data[23 : 16]};
                            ram_select_signal <= 4'b0100;
                        end
                        2'b10: begin
                            write_data <= {{24{1'b0}}, input_ram_read_data[15 : 8]};
                            ram_select_signal <= 4'b0010;
                        end
                        2'b11: begin
                            write_data <= {{24{1'b0}}, input_ram_read_data[7 : 0]};
                            ram_select_signal <= 4'b0001;
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_LH: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_READ;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= {{16{input_ram_read_data[31]}}, input_ram_read_data[31 : 16]};
                            ram_select_signal <= 4'b1100;
                        end
                        2'b10: begin
                            write_data <= {{16{input_ram_read_data[15]}}, input_ram_read_data[15 : 0]};
                            ram_select_signal <= 4'b0011;
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_LHU: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_READ;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= {{16{1'b0}}, input_ram_read_data[31 : 16]};
                            ram_select_signal <= 4'b1100;
                        end
                        2'b10: begin
                            write_data <= {{16{1'b0}}, input_ram_read_data[15 : 0]};
                            ram_select_signal <= 4'b0011;
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_LW: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_READ;
                    ram_select_signal <= 4'b1111;
                    ram_chip_enable <= `ENABLE;
                    write_data <= input_ram_read_data;
                end
                `OPERATOR_LWL: begin
                    ram_addr <= {input_ram_addr[31 : 2], 2'b00};
                    ram_operation_register <= `RAM_READ;
                    ram_select_signal <= 4'b1111;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= input_ram_read_data[31 : 0];
                        end
                        2'b01: begin
                            write_data <= {input_ram_read_data[23 : 0], input_alu_operand2[7 : 0]};
                        end
                        2'b10: begin
                            write_data <= {input_ram_read_data[15 : 0], input_alu_operand2[15 : 0]};
                        end
                        2'b11: begin
                            write_data <= {input_ram_read_data[7 : 0], input_alu_operand2[23 : 0]};
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_LWR: begin
                    ram_addr <= {input_ram_addr[31 : 2], 2'b00};
                    ram_operation_register <= `RAM_READ;
                    ram_select_signal <= 4'b1111;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            write_data <= {input_alu_operand2[31 : 8], input_ram_read_data[31 : 24]};
                        end
                        2'b01: begin
                            write_data <= {input_alu_operand2[31 : 16], input_ram_read_data[31 : 16]};
                        end
                        2'b10: begin
                            write_data <= {input_alu_operand2[31 : 24], input_ram_read_data[31 : 8]};
                        end
                        2'b11: begin
                            write_data <= input_ram_read_data;
                        end
                        default: begin
                            write_data <= 0; // FIXME: 0 is used here, but ZERO_WORD is expected 
                        end
                    endcase
                end
                `OPERATOR_SB: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_WRITE;
                    ram_write_data <= {input_alu_operand2[7 : 0], input_alu_operand2[7 : 0], 
                        input_alu_operand2[7 : 0], input_alu_operand2[7 : 0]};
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            ram_select_signal <= 4'b1000;
                        end
                        2'b01: begin
                            ram_select_signal <= 4'b0100;
                        end
                        2'b10: begin
                            ram_select_signal <= 4'b0010;
                        end
                        2'b11: begin
                            ram_select_signal <= 4'b0001;
                        end
                        default: begin
                            ram_select_signal <= 4'b0000;
                        end
                    endcase
                end
                `OPERATOR_SH: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_WRITE;
                    ram_write_data <= {input_alu_operand2[15 : 0], input_alu_operand2[15 : 0]};
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            ram_select_signal <= 4'b1100;
                        end
                        2'b10: begin
                            ram_select_signal <= 4'b0011;
                        end
                        default: begin
                            ram_select_signal <= 4'b0000;
                        end
                    endcase
                end
                `OPERATOR_SW: begin
                    ram_addr <= input_ram_addr;
                    ram_operation_register <= `RAM_WRITE;
                    ram_write_data <= input_alu_operand2;
                    ram_select_signal <= 4'b1111;
                    ram_chip_enable <= `ENABLE;
                end
                `OPERATOR_SWL: begin
                    ram_addr <= {input_ram_addr[31 : 2], 2'b00};
                    ram_operation_register <= `RAM_WRITE;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            ram_select_signal <= 4'b1111;
                            ram_write_data <= input_alu_operand2;
                        end
                        2'b01: begin
                            ram_select_signal <= 4'b0111;
                            ram_write_data <= {zero32[7 : 0], input_alu_operand2[31 : 8]};
                        end
                        2'b10: begin
                            ram_select_signal <= 4'b0011;
                            ram_write_data <= {zero32[15 : 0], input_alu_operand2[31 : 16]};
                        end
                        2'b11: begin
                            ram_select_signal <= 4'b0001;
                            ram_write_data <= {zero32[23 : 0], input_alu_operand2[31 : 24]};
                        end
                        default: begin
                            ram_select_signal <= 4'b0000;
                        end
                    endcase
                end
                `OPERATOR_SWR: begin
                    ram_addr <= {input_ram_addr[31 : 2], 2'b00};
                    ram_operation_register <= `RAM_WRITE;
                    ram_chip_enable <= `ENABLE;
                    case (input_ram_addr[1 : 0])
                        2'b00: begin
                            ram_select_signal <= 4'b1000;
                            ram_write_data <= {input_alu_operand2[7 : 0], zero32[23 : 0]};
                        end
                        2'b01: begin
                            ram_select_signal <= 4'b1100;
                            ram_write_data <= {input_alu_operand2[15 : 0], zero32[15 : 0]};
                        end
                        2'b10: begin
                            ram_select_signal <= 4'b1110;
                            ram_write_data <= {input_alu_operand2[23 : 0], zero32[7 : 0]};
                        end
                        2'b11: begin
                            ram_select_signal <= 4'b1111;
                            ram_write_data <= input_alu_operand2[31 : 0];
                        end
                        default: begin
                            ram_select_signal <= 4'b0000;
                        end
                    endcase
                end
            endcase
        end
    end

endmodule // mem
