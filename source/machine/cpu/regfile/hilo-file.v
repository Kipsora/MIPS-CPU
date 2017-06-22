`include "macro.v"

module hilo_file(
    input   wire                        clock,
    input   wire                        reset,

    input   wire                        write_hilo_enable,
    input   wire[`REGS_DATA_BUS]        write_hi_data,
    input   wire[`REGS_DATA_BUS]        write_lo_data,

    output  reg[`REGS_DATA_BUS]         hi_data,
    output  reg[`REGS_DATA_BUS]         lo_data
);

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            hi_data <= 0;  // FIXME: Zero word should be used here, but 0 is used, check it later.
            lo_data <= 0;  // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else if (write_hilo_enable == `ENABLE) begin
            hi_data <= write_hi_data;
            lo_data <= write_lo_data;
        end
    end

endmodule // hilo_file