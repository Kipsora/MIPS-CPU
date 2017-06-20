`include "macro.v"

module mem(
    input   wire                    reset,

    input   wire                    input_write_enable,
    input   wire[`REGS_ADDR_BUS]    input_write_addr,
    input   wire[`REGS_DATA_BUS]    input_write_data,

    output  reg                     write_enable,
    output  reg[`REGS_ADDR_BUS]     write_addr,
    output  reg[`REGS_DATA_BUS]     write_data
);

    always @ (*) begin
        if (reset == `ENABLE) begin
            write_enable <= `DISABLE;
            write_addr <= 0;                // FIXME: 0 is used here, but NOPRegAddr is expected 
            write_data <= 0;                // FIXME: 0 is used here, but ZERO_WORD is expected 
        end else begin
            write_enable <= input_write_enable;
            write_addr <= input_write_addr;
            write_data <= input_write_data;
        end
    end

endmodule // mem
