// Keep def file up-to-date while developing //


`define BUS_ADDR_WIDTH 12 // when only has one memory at the interface, this should be equal to memory depth. //
`define BUS_IO_NUM 16 // 2^n, n is 'BUS_ADDR_WIDTH - MEM_DEPTH' //
`define BUS_IO_ADDR_WIDTH 4 // 'BUS_ADDR_WIDTH - MEM_DEPTH' //


`define MEM_WIDTH 8
`define MEM_DEPTH 8
`define MEM_WORD_NUMB 256

`define REG_LENGTH 32
`define REG_ADDR_LEN_4 4
`define REG_NUMBER 16