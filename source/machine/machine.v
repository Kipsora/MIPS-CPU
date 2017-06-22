`include "macro.v"
`include "machine/cpu/mips.v"
`include "machine/rom/rom.v"
`include "machine/rom/ram.v"

module machine(
    input   wire                        clock,
    input   wire                        reset
);

    wire[`INST_ADDR_BUS]                rom_addr;
    wire[`INST_DATA_BUS]                rom_instruction;
    wire                                rom_chip_enable;

    wire                                ram_operation;
    wire[`INST_ADDR_BUS]                ram_addr;
    wire[`BYTE_SEL_BUS]                 ram_select_signal;
    wire[`INST_DATA_BUS]                ram_write_data;
    wire[`INST_DATA_BUS]                ram_read_data;
    wire                                ram_chip_enable;

    mips                                mips_instance(
        .clock(clock),
        .reset(reset),
        .rom_data(rom_instruction),
        .ram_read_data(ram_read_data),
        .rom_addr(rom_addr),
        .rom_chip_enable(rom_chip_enable),
        .ram_operation(ram_operation),
        .ram_select_signal(ram_select_signal),
        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_chip_enable(ram_chip_enable)
    );

    rom                                 rom_instance(
        .chip_enable(rom_chip_enable),
        .addr(rom_addr),
        .instruction(rom_instruction)
    );

    ram                                 ram_instance(
        .clock(clock),
        .chip_enable(ram_chip_enable),
        .operation(ram_operation),
        .addr(ram_addr),
        .select_signal(ram_select_signal),
        .write_data(ram_write_data),
        .read_data(ram_read_data)
    );

    /* DEBUG AREA OUTPUT BEGIN*/
    integer idx;
    initial begin
        $dumpfile("wave.lxt");
        $dumpvars(0, mips_instance);
        $dumpvars(0, rom_instance);
        $dumpvars(0, ram_instance);
        for (idx = 0; idx < 32; idx = idx + 1) begin
            $dumpvars(0, mips_instance.gpr_file_instance.regs[idx]);
        end
    end
    /* DEBUG AREA OUTPUT END*/

endmodule
