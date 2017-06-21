`include "machine/machine.v"

`timescale  1ns/1ps

module openmips_benchmark();

    reg                             CLOCK_50;
    reg                             reset;

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        reset = `ENABLE;
        #195 reset = `DISABLE;
        #5000 $stop;
    end

    machine machine_instance(
        .clock(CLOCK_50),
        .reset(reset)
    );

endmodule // openmips_min_sopc_tb
