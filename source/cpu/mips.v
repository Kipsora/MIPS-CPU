`include "../utility.v"

module mips(
    input   wire                    clock;  
    input   wire                    reset;

    input   wire[`REGS_DATA_BUS]    rom_data;

    output  wire[`REGS_DATA_BUS]    rom_addr;
    output  wire[`REGS_DATA_BUS]    rom_chip_enable;
);

    wire    [`INST_ADDR_BUS]        program_counter;
    wire    [`INST_ADDR_BUS]        

endmodule // mips