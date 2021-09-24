// 400 Mbps System Bus //

`include "MEM32.v"
`include "def.v"


module SYS_BUS (

//********************* interface with controller. ************************//
    input clk,
    input rst,
    input ale_en,
    input bus_read_en,
    input bus_write_en,
    input [`BUS_ADDR_WIDTH - 1 : 0] addr_input,
    input [`MEM_WIDTH - 1 : 0] data_write,
    output reg [`MEM_WIDTH - 1 : 0] data_read,


//********************** interface with IO devices. ***********************//
    input [`MEM_WIDTH - 1 : 0] bus_data_read_premux [`BUS_IO_NUM - 1 : 0],
    output reg [`MEM_DEPTH - 1 : 0] bus_addr, // the address for IO data //
    output reg [`BUS_IO_NUM - 1 : 0] io_read_en,
    output reg [`BUS_IO_NUM - 1 : 0] io_write_en,
    output reg [`MEM_WIDTH - 1 : 0] bus_data_write

);

    parameter s_idle = 0;
    parameter s_alen = 1;
    parameter s_tras = 2;
    parameter s_recv = 3;
    parameter s_comp = 4;

//********************** Internal Registers ***********************//
    reg bus_ready;
    reg [4:0] state_now; 
    reg [4:0] state_nxt;
    reg [`BUS_ADDR_WIDTH - 1 : `MEM_DEPTH] io_addr;
    reg [`MEM_WIDTH - 1 : 0] bus_data_read_postmux;


    always @(*) begin

        case (state_now)
            5'b00001: begin // idle state //
                bus_ready <= 1'b1;
                bus_addr <= {`MEM_DEPTH{1'b0}};
                io_addr <= {(`BUS_ADDR_WIDTH - `MEM_DEPTH){1'b0}};
                io_read_en <= {`BUS_IO_NUM{1'b0}};
                io_write_en <= {`BUS_IO_NUM{1'b0}};
            end

            5'b00010: begin
                bus_ready <= 1'b0;
                bus_addr <= addr_input[`MEM_DEPTH - 1 : 0];
                io_addr <= addr_input[`BUS_ADDR_WIDTH - 1 : `MEM_DEPTH];
            end

            5'b00100: begin // read data from IO. //
                bus_ready <= 1'b0;
                io_read_en[io_addr] <= state_now[s_tras];
                bus_data_read_postmux <= bus_data_read_premux[io_addr];
            end

            5'b01000: begin // write data to IO. //
                bus_ready <= 1'b0;
                io_write_en[io_addr] <= state_now[s_recv];
                bus_data_write <= data_write;
            end

            5'b10000: begin
                data_read <= bus_data_read_postmux;
                bus_ready <= 1'b1;
                io_read_en <= {`BUS_IO_NUM{1'b0}};
                io_write_en <= {`BUS_IO_NUM{1'b0}};

            end

            default: begin
                bus_ready <= 1'b1;
                bus_addr <= {`BUS_ADDR_WIDTH{1'b0}};
                io_read_en <= {`BUS_IO_NUM{1'b0}};
                io_write_en <= {`BUS_IO_NUM{1'b0}};
            end
        endcase
    end


    // state transitions //
    always @(*) begin

        state_nxt[s_idle] = state_now[s_idle]&(~ale_en) | state_now[s_comp]&(~ale_en) | state_now[s_alen]&((bus_read_en|bus_write_en) == 0);
        state_nxt[s_alen] = state_now[s_idle]&(ale_en) | state_now[s_comp]&(ale_en);
        state_nxt[s_tras] = state_now[s_alen]&(bus_read_en); // (write_en xnor read_en) == 1 / vialation is not allowed. //
        state_nxt[s_recv] = state_now[s_alen]&(bus_write_en);
        state_nxt[s_comp] = state_now[s_tras]|state_now[s_recv];
        
    end

    always @(posedge clk) begin

        if(rst) begin
            bus_ready <= 1'b1;
            bus_addr <= {`BUS_ADDR_WIDTH{1'b0}};
            io_read_en <= 0;
            io_write_en <= 0;
            data_read <= {`MEM_WIDTH{1'b0}};

            state_now <= 5'b00001; // 1-hot, configurable. //
        end

        else begin
            state_now <= state_nxt;
        end

    end

endmodule
