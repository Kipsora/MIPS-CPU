`include "utility/utility.v"
`include "machine/cpu/mips.v"
`include "machine/rom/rom.v"

module machine(
    input   wire                    clock,
    input   wire                    reset
);

    wire[`INST_ADDR_BUS]            addr;
    wire[`INST_DATA_BUS]            instruction;
    wire                            chip_enable;

    mips                            mips_instance(
        .clock(clock),
        .reset(reset),
        .rom_data(instruction),
        .rom_addr(addr),
        .rom_chip_enable(chip_enable)
    );

    rom                             rom_instance(
        .chip_enable(chip_enable),
        .addr(addr),
        .instruction(instruction)
    );

endmodule
