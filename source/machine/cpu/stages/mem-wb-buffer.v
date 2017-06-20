`include "macro.v"

module mem_wb_buffer(
    input   wire                    clock,
    input   wire                    reset,

    input   wire                    mem_write_enable,
    input   wire[`REGS_ADDR_BUS]    mem_write_addr,
    input   wire[`REGS_DATA_BUS]    mem_write_data,

    output  reg                     wb_write_enable,
    output  reg[`REGS_ADDR_BUS]     wb_write_addr,
    output  reg[`REGS_DATA_BUS]     wb_write_data
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            wb_write_enable <= `DISABLE;
            wb_write_addr <= 0;             // FIXME: 0 is used, but expected NOPRegAddr
            wb_write_data <= 0;             // FIXME: 0 is used, but expected ZERO_WORD
        end else begin
            wb_write_enable <= mem_write_enable;
            wb_write_addr <= mem_write_addr;
            wb_write_data <= mem_write_data;
        end
    end

endmodule // mem_wb_buffer
