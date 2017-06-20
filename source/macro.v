`define ENABLE 1'b1
`define DISABLE 1'b0
`define VALID 1'b1
`define INVALID 1'b0

/* Definition with instructions */
`define ALU_OPERATOR_BUS 7:0
`define ALU_CATEGORY_BUS 2:0

`define CATEGORY_LOGIC 3'b001
`define CATEGORY_NOP 3'b000

`define OPERATOR_OR 8'b00100101
`define OPERATOR_NOP 8'b00000000

`define INST_ORI_ID 6'b001101
`define INST_ORI_CATEGORY `CATEGORY_LOGIC
`define INST_ORI_OPERATOR `OPERATOR_OR

`define INST_NOP_ID 6'b000000
`define INST_NOP_CATEGORY `CATEGORY_NOP
`define INST_NOP_OPERATOR `OPERATOR_NOP

`define INST_ADDR_BUS 31:0
`define INST_DATA_BUS 31:0

/* Definition with ROM */
`define MEMO_NUM 4
`define MEMO_NUM_LOG 2

/* Definition with register file */
`define REGS_NUM 32
`define REGS_NUM_LOG 5
`define REGS_ADDR_BUS 4:0
`define REGS_DATA_BUS 31:0
`define REGS_SIZE 5
