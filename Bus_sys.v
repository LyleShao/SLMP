// 400 Mbps System Bus //
`include "REG_32.v"
`include "MEM_32.v"


`define ADDR_BUS_WIDTH 8  // this should be equal to memory depth. //



module SYS_BUS (
// THINK ABOUT A INTERRUPT-DRIVEN STATE MACHINE. //

    input clk,
    input rst,
    input bus_read_en,
    input bus_write_en,
    input data_input,
    output reg data_output,

);

    reg bus_data_temp;

endmodule



// Data Line BUS. //
module DL_BUS (
    input clk,
    input rst,
    input ale_en,
    input read_en,
    input write_en,
    input [`MEM_WIDTH - 1 : 0] dl_bus_write_in,
    output reg [`MEM_WIDTH - 1 : 0] dl_bus_read_out
);

    reg [`MEM_WIDTH - 1 : 0] dl_bus_data;

    always @(posedge clk ) begin

        if (rst) begin
            dl_bus_data <= {`MEM_WIDTH{1'b0}};
            dl_bus_read_out <= {`MEM_WIDTH{1'b0}};
        end

        else if (ale_en) begin
            dl_bus_data <= {`MEM_WIDTH{1'b0}};
            dl_bus_read_out <= {`MEM_WIDTH{1'b0}};
        end

        else if (write_en) begin
            dl_bus_data <= dl_bus_write_in;
            dl_bus_read_out <= {`MEM_WIDTH{1'b0}};
        end

        else if (read_en)
            dl_bus_read_out <= dl_bus_data;
     
    end

endmodule



// Address line BUS. //
module AL_BUS (
    
    input clk, 
    input rst,
    input ale_en,
    input read_en,
    input [`ADDR_BUS_WIDTH -1 : 0] al_bus_write_in,
    output reg  [`ADDR_BUS_WIDTH -1 : 0] al_bus_read_out
);
    reg [`ADDR_BUS_WIDTH -1 : 0] al_bus_data;

always @(posedge clk) begin

    if (rst) begin
        al_bus_data <= {`ADDR_BUS_WIDTH{1'b0}};
        al_bus_read_out <= {`ADDR_BUS_WIDTH{1'b0}};
    end
    
    else if (~read_en & ale_en) begin
        al_bus_data <= al_bus_write_in;
        al_bus_read_out <= {`ADDR_BUS_WIDTH{1'b0}};        
    end


    else if (read_en & ~ale_en) begin
        al_bus_read_out <= al_bus_data;        
    end

    else
        al_bus_read_out <= {`ADDR_BUS_WIDTH{1'b0}};
end

endmodule


