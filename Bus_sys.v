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
    reg bus_addr_temp;
    reg bus_data_temp;


    always @(*) begin

        case state_now:
            5'b00001: begin
                bus_ready <= 1'b1;
                bus_addr_temp <= 0;
                bus_data_temp <= 0;
            end

            5'b00010: begin
                bus_ready <= 1'b0;
                bus_addr_temp <= addr_input;
            end

            5'b00100: begin
                bus_ready <= 1'b0;
                data_read <= 


            end





        
    end



    // state transitions //
    always @(*) begin

        state_nxt[s_idle] = state[s_idle]&(~ale_en) | state[s_comp]&(~ale_en);
        state_nxt[s_alen] = state[s_idle]&(s_alen);
        state_nxt[s_tras] = state[s_alen]&(bus_read_en);
        state_nxt[s_recv] = state[s_alen]&(bus_write_en);
        state_nxt[s_comp] = state[s_tras]&bus_ready | state[s_recv]&bus_ready;
        
    end

    always @(posedge clk) begin

        if(rst) begin
            data_output <= 0;
            state_now <= 5'b00001; // 1-hot, configurable. //
        end

        else begin
            state_now <= state_nxt;
        end

    end



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


