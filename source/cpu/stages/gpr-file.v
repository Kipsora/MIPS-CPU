`include "../../utility.v"

module gpr_file(
    input   wire                    clock,
    input   wire                    reset,

    input   wire                    write_enable,
    input   wire[`REGS_ADDR_BUS]    waddr,
    input   wire[`REGS_DATA_BUS]    wdata,

    input   wire                    read_enable1,
    input   wire[`REGS_ADDR_BUS]    raddr1,
    output  wire[`REGS_DATA_BUS]    rdata1,

    input   wire                    read_enable2,
    input   wire[`REGS_ADDR_BUS]    raddr2,
    output  wire[`REGS_DATA_BUS]    rdata2
);

    reg[`REGS_DATA_BUS]             regs[0:`REGS_NUM - 1];

    always @ (posedge clock) begin
        if (reset == `DISABLE && write_enable == `ENABLE && waddr != `REGS_NUM_LOG'h0) begin
            regs[waddr] <= wdata;
        end
    end

    always @ (posedge clock) begin
        if (reset == `ENABLE || raddr1 == `REGS_NUM_LOG'h0) begin
            rdata1 <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else if (write_enable == `ENABLE && read_enable == `ENABLE && raddr1 == waddr) begin
            rdata1 <= wdata;
        end else if (read_enable == `ENABLE) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
        end
    end

    always @ (posedge clock) begin
        if (reset == `ENABLE || raddr2 == `REGS_NUM_LOG'h0) begin
            rdata2 <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
        end else if (write_enable == `ENABLE && read_enable == `ENABLE && raddr2 == waddr) begin
            rdata2 <= wdata;
        end else if (read_enable == `ENABLE) begin
            rdata2 <= regs[raddr2];
        end else begin
            rdata2 <= 0; // FIXME: Zero word should be used here, but 0 is used, check it later.
        end
    end

endmodule // gpr_file