`include "macro.v"

module rom(
    input   wire                        chip_enable,
    input   wire[`INST_ADDR_BUS]        addr,
    output  reg[`INST_ADDR_BUS]         instruction
);

    reg[`INST_DATA_BUS]                 memory[0:`MEMO_NUM - 1];

    initial $readmemh("program.rom", memory);

    always @ (*) begin
        if (chip_enable == `DISABLE) begin
            instruction <= 0;       // FIXME: 0 is used, but expected ZERO_WORD
        end else begin
            instruction <= memory[addr[`MEMO_NUM_LOG + 1 : 2]];
        end
    end

endmodule // rom
