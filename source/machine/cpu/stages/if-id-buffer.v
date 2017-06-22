`include "macro.v"

module if_id_buffer(
    input   wire                    clock,
    input   wire                    reset,

    input   wire[`SIGNAL_BUS]       stall,

    input   wire[`INST_ADDR_BUS]    if_program_counter,
    input   wire[`INST_DATA_BUS]    if_instruction,

    output  reg[`INST_ADDR_BUS]     id_program_counter,
    output  reg[`INST_DATA_BUS]     id_instruction
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            id_program_counter <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
            id_instruction <= 0;     // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else if (stall[1] == `ENABLE && stall[2] == `DISABLE) begin
            id_program_counter <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
            id_instruction <= 0;     // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else if (stall[1] == `DISABLE) begin
            id_program_counter <= if_program_counter;
            id_instruction <= if_instruction;
        end
    end

endmodule // if_id_buffer
