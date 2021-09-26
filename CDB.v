// Common Data Bus //

`include "def.v"
`include "Bus_sys.v"

module CDB (
    clk,
    rst,
    cdb_data_input,
    cdb_data_output,
    cdb_addr
);