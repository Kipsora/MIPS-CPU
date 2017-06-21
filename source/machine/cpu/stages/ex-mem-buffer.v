`include "macro.v"

module ex_mem_buffer(
    input   wire                    clock,
    input   wire                    reset,

    input   wire                    ex_write_enable,
    input   wire[`REGS_ADDR_BUS]    ex_write_addr,
    input   wire[`REGS_DATA_BUS]    ex_write_data,

    input   wire                    ex_write_hilo_enable,
    input   wire[`REGS_DATA_BUS]    ex_write_hi_data,
    input   wire[`REGS_DATA_BUS]    ex_write_lo_data,

    output  reg                     mem_write_enable,
    output  reg[`REGS_ADDR_BUS]     mem_write_addr,
    output  reg[`REGS_DATA_BUS]     mem_write_data,

    output  reg                     mem_write_hilo_enable,
    output  reg[`REGS_DATA_BUS]     mem_write_hi_data,
    output  reg[`REGS_DATA_BUS]     mem_write_lo_data
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            mem_write_enable <= `DISABLE;
            mem_write_data <= 0;               // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_addr <= 0;               // FIXME: NOPRegAddr should be used here, but 0 is used
            mem_write_hilo_enable <= `DISABLE;
            mem_write_hi_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
            mem_write_lo_data <= 0;            // FIXME: ZERO_WORD should be used here, but 0 is used
        end else begin
            mem_write_enable <= ex_write_enable;
            mem_write_addr <= ex_write_addr;
            mem_write_data <= ex_write_data;
            mem_write_hilo_enable <= ex_write_hilo_enable;
            mem_write_hi_data <= ex_write_hi_data;
            mem_write_lo_data <= ex_write_lo_data;
        end
    end

endmodule // ex_mem_buffer
