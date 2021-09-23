// 400 Mbps System Bus //
`include "REG_32.v"
`include "MEM_32.v"


`define ADDR_BUS_WIDTH 8  // this should be equal to memory depth. //



module SYS_BUS (
// THINK ABOUT A INTERRUPT-DRIVEN STATE MACHINE. //

    input clk,
    input rst,
    input ale_en,
    input bus_read_en,
    input bus_write_en,
    input addr_input,
    input data_write,
    output reg data_read
);

    parameter s_idle = 0;
    parameter s_alen = 1;
    parameter s_tras = 2;
    parameter s_recv = 3;
    parameter s_comp = 4;


    reg [4:0] state_now; 
    reg [4:0] state_nxt;
    reg bus_ready;

    reg bus_addr;
    reg io_write_en;
    reg io_read_en;
    reg bus_data_write;
    reg bus_data_read; // connected to outputs of IO. //


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
                bus_addr <= 0;
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
                io_read_en <= 1'b1;
            end

            5'b01000: begin // write data to IO. //
                bus_ready <= 1'b0;
                io_write_en <= 1'b1;
            end

            5'b10000: begin
                bus_ready <= 1'b1;
                io_read_en <= 0;
                io_write_en <= 0;
                data_read <= bus_data_read;

            end

            default: begin
                bus_ready <= 1'b1;
                bus_addr <= 0;
                io_read_en <= 0;
                io_write_en <= 0;
            end
        endcase
    end



    // state transitions //
    always @(*) begin

        state_nxt[s_idle] = state_now[s_idle]&(~ale_en) | state_now[s_comp]&(~ale_en);
        state_nxt[s_alen] = state_now[s_idle]&(s_alen) | state_now[s_comp]&(s_alen);
        state_nxt[s_tras] = state_now[s_alen]&(bus_read_en);
        state_nxt[s_recv] = state_now[s_alen]&(bus_write_en);
        state_nxt[s_comp] = state_now[s_tras]|state_now[s_recv];
        
    end

    always @(posedge clk) begin

        if(rst) begin
            bus_ready <= 1'b1;
            bus_addr <= 0;
            io_read_en <= 0;
            io_write_en <= 0;
            data_read <= 0;

            state_now <= 5'b00001; // 1-hot, configurable. //
        end

        else begin
            state_now <= state_nxt;
        end

    end



endmodule












//  ******************************* ABSTRACT ****************************** //
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


