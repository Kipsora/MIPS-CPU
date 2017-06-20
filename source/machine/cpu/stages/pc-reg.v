`include "macro.v"

module pc_reg(
    input   wire                    clock,
    input   wire                    reset,
    output  reg[`INST_ADDR_BUS]     program_counter,
    output  reg                     chip_enable
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            chip_enable <= `DISABLE;
        end else begin
            chip_enable <= `ENABLE;
        end
    end

    always @ (posedge clock) begin
        if (chip_enable == `DISABLE) begin
            program_counter <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else begin
            program_counter <= program_counter + 4'h4;
        end
    end

endmodule // pc_reg
