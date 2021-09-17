// 400 Mbps System Bus //
`include "REG_32.v"
`include "MEM_32.v"


`define ADDR_BUS_WIDTH 8  // this should be equal to memory depth. //



module SYS_BUS (

    input clk,
    input rst,
    input ale,
    input rd_en,
    input wr_en,

    
);

endmodule



// Data Line BUS. //
module DL_BUS (
    input clk,
    input rst,
    input ale_en,
    input read_en,
    input write_en,
    input [`MEM_WIDTH - 1 : 0] write_in,
    output reg [`MEM_WIDTH - 1 : 0] read_out
);

    reg [`MEM_WIDTH - 1 : 0] bus_data;

    always @(posedge clk ) begin

        if (rst)
            bus_data <= {`MEM_WIDTH{1'b0}};

        else if (ale_en)
            bus_data <= bus_data;

        else if (write_en)
            bus_data <= write_in;

        else if (read_en)
            read_out <= bus_data;
     
    end

endmodule



// Address line BUS. //
module AL_BUS (

    input clk, 
    input rst,
    input ale_en,
    input [`ADDR_BUS_WIDTH -1 : 0] addr_bus_in,
    output reg  [`ADDR_BUS_WIDTH -1 : 0] addr_bus_out
);

always @(posedge clk) begin

    if (rst)
        addr_bus_out <= {`ADDR_BUS_WIDTH{1'b0}};
    
    else if (ale_en)
        addr_bus_out <= addr_bus_in;

    else
        addr_bus_out <= addr_bus_out;

end

endmodule


