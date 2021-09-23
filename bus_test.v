// 400 Mbps System Bus //
`include "MEM32.v"

`define ADDR_BUS_WIDTH 8  // this should be equal to memory depth. //
`define MEM_WIDTH 8
`define MEM_DEPTH 8



module SYS_BUS_TEST (

    input clk,
    input rst,
    input ale_en,
    input bus_read_en,
    input bus_write_en,
    input [`MEM_DEPTH - 1 : 0] addr_input,
    input [`MEM_WIDTH - 1 : 0] data_write,
    output reg [`MEM_WIDTH - 1 : 0] data_read,


    // Virtual //
    output reg [4:0] state_now,
    output reg [4:0] state_nxt,
    output reg bus_ready,
    output reg [`MEM_DEPTH - 1 : 0] bus_addr,
    output reg io_write_en,
    output reg io_read_en,
    output reg [`MEM_WIDTH - 1 : 0] bus_data_write
);

    parameter s_idle = 0;
    parameter s_alen = 1;
    parameter s_tras = 2;
    parameter s_recv = 3;
    parameter s_comp = 4;

    wire [`MEM_WIDTH - 1 : 0] bus_data_read;
    reg [`MEM_WIDTH - 1 : 0] bus_data_read_latch;

    MEM_256bytes MEM_MAIN (
        .addr(bus_addr),
        .write_en(io_write_en),
        .read_en(io_read_en),
        .write_in(bus_data_write),
        .read_out(bus_data_read)

        );


    always @(*) begin
        
        case (state_now)
            5'b00001: begin // idle state //
                bus_ready <= 1'b1;
                bus_addr <= {`MEM_DEPTH{1'b0}};
                io_read_en <= 0;
                io_write_en <= 0;
            end

            5'b00010: begin
                bus_ready <= 1'b0;
                bus_addr <= addr_input;
                io_read_en <= state_nxt[s_tras];
                io_write_en <= state_nxt[s_recv];
            end

            5'b00100: begin // read data from IO. //
                bus_ready <= 1'b0;
                bus_data_read_latch <= bus_data_read;
            end

            5'b01000: begin // write data to IO. //
                bus_ready <= 1'b0;
                bus_data_write <= data_write;
            end

            5'b10000: begin
                data_read <= bus_data_read_latch;
                bus_ready <= 1'b1;
                io_read_en <= 0;
                io_write_en <= 0;

            end

            default: begin
                bus_ready <= 1'b1;
                bus_addr <= {`MEM_DEPTH{1'b0}};
                io_read_en <= 0;
                io_write_en <= 0;
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
            bus_addr <= {`MEM_DEPTH{1'b0}};
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