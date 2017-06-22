module ex_div(
    input   wire                        clock,
    input   wire                        reset,

    input   wire                        is_signed,
    input   wire[`REGS_DATA_BUS]        operand1,
    input   wire[`REGS_DATA_BUS]        operand2,

    input   wire                        is_start,
    input   wire                        is_annul,

    output  reg                         is_ended,
    output  reg[`DOUBLE_REGS_DATA_BUS]  result
);

    wire[`EXT_REGS_DATA_BUS]            div_temp;
    reg[`EXT_DOUBLE_REGS_DATA_BUS]      dividend;
    reg[`REGS_DATA_BUS]                 divisor;
    reg[5 : 0]                          cycle;
    reg[1 : 0]                          state;

    assign div_temp = {1'b0, dividend[63 : 32]} - {1'b0, divisor};

    always @ (posedge clock) begin
        if (reset == `ENABLE) begin
            state <= `DIV_FREE;
            is_ended <= `FALSE;
            result <= 0; // FIXME: {`ZEROWORD, `ZEROWORD} should be used
        end else begin
            case (state)
                `DIV_FREE: begin
                    if (is_start == `TRUE && is_annul == `FALSE) begin
                        if (operand2 == 0) begin // FIXME: ZERO_WORD should be used
                            state <= `DIV_BY_ZERO;
                        end else begin
                            state <= `DIV_ON;
                            cycle <= 6'b000000;
                            dividend = 0; // FIXME: {`ZERO_WORD, `ZERO_WORD}  should be used
                            if (is_signed == `TRUE && operand1[31] == 1'b1) begin
                                dividend[32 : 1] <= ~operand1 + 1; // FIXME: may be = should be used here
                            end else begin
                                dividend[32 : 1] <= operand1;      // FIXME: may be = should be used here
                            end
                            if (is_signed == `TRUE && operand2[31] == 1'b1) begin
                                divisor <= ~operand2 + 1;
                            end else begin
                                divisor <= operand2;
                            end
                        end
                    end else begin
                        is_ended <= `FALSE;
                        result <= 0; // FIXME: {`ZEROWORD, `ZEROWORD} should be used
                    end
                end
                `DIV_BY_ZERO: begin
                    dividend <= 0; // FIXME: {`ZERO_WORD, `ZERO_WORD}  should be used
                    state <= `DIV_END;
                end
                `DIV_ON: begin
                    if (is_annul == `FALSE) begin
                        if (cycle != 6'b100000) begin
                            if (div_temp[32] == 1'b1) begin
                                dividend <= {dividend[63 : 0], 1'b0};
                            end else begin
                                dividend <= {div_temp[31 : 0], dividend[31 : 0], 1'b1};
                            end
                            cycle <= cycle + 1;
                        end else begin
                            if (is_signed && (operand1[31] ^ operand2[31])) begin
                                dividend[31 : 0] <= ~dividend[31 : 0] + 1;
                            end
                            if (is_signed && (operand1[31] ^ dividend[64])) begin
                                dividend[64 : 33] <= ~dividend[64 : 33] + 1;
                            end
                            state <= `DIV_END;
                            cycle <= 6'b000000;
                        end
                    end else begin
                        state <= `DIV_FREE;
                    end
                end
                `DIV_END: begin
                    result <= {dividend[64 : 33], dividend[31 : 0]};
                    is_ended <= `TRUE;
                    if (is_start <= `FALSE) begin
                        state <= `DIV_FREE;
                        is_ended <= `FALSE;
                        result <= 0; // FIXME: {`ZERO_WORD, `ZERO_WORD}  should be used
                    end
                end
            endcase
        end
    end

endmodule // ex_div