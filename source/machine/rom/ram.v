`include "macro.v"

module ram(
    input   wire                        clock,
    input   wire                        chip_enable,
    input   wire                        operation,
    input   wire[`INST_ADDR_BUS]        addr,
    input   wire[`BYTE_SEL_BUS]         select_signal,
    input   wire[`INST_DATA_BUS]        write_data,
    output  reg[`INST_DATA_BUS]         read_data
);

    reg[`BYTE_WIDTH]                    data_mem0[0 : `RAM_NUM - 1];
    reg[`BYTE_WIDTH]                    data_mem1[0 : `RAM_NUM - 1];
    reg[`BYTE_WIDTH]                    data_mem2[0 : `RAM_NUM - 1];
    reg[`BYTE_WIDTH]                    data_mem3[0 : `RAM_NUM - 1];

    always @ (posedge clock) begin
        if (chip_enable == `ENABLE && operation == `RAM_WRITE) begin
            if (select_signal[3]) begin
                data_mem3[addr[`RAM_NUM_LOG + 1 : 2]] <= write_data[31 : 24];
            end
            if (select_signal[2]) begin
                data_mem2[addr[`RAM_NUM_LOG + 1 : 2]] <= write_data[23 : 16];
            end
            if (select_signal[1]) begin
                data_mem1[addr[`RAM_NUM_LOG + 1 : 2]] <= write_data[15 : 8];
            end
            if (select_signal[0]) begin
                data_mem0[addr[`RAM_NUM_LOG + 1 : 2]] <= write_data[7 : 0];
            end
        end
    end

    always @ (*) begin
        if (chip_enable == `DISABLE) begin
            read_data <= 0; // FIXME: 0 is used instead of ZERO_WORD
        end else if (operation == `RAM_READ) begin
            read_data = {
                data_mem3[addr[`RAM_NUM_LOG + 1 : 2]],
                data_mem2[addr[`RAM_NUM_LOG + 1 : 2]],
                data_mem1[addr[`RAM_NUM_LOG + 1 : 2]],
                data_mem0[addr[`RAM_NUM_LOG + 1 : 2]]
            };
        end else begin
            read_data <= 0; // FIXME: 0 is used instead of ZERO_WORD
        end
    end

endmodule // ram