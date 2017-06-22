`include "macro.v"

module control(
    input   wire                    reset,
    input   wire                    stall_from_id,
    input   wire                    stall_from_ex,
    output  reg[`SIGNAL_BUS]        stall
);

    always @ (*) begin
        if (reset == `ENABLE) begin
            stall <= 0;       // FIXME: 0 is used, but 6'b000000 is expected
        end else if (stall_from_ex == `ENABLE) begin
            stall <= 6'b001111;
        end else if (stall_from_id == `ENABLE) begin
            stall <= 6'b000111;
        end else begin
            stall <= 0;       // FIXME: 0 is used, but 6'b000000 is expected
        end
    end

endmodule // control