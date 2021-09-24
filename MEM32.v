`define MEM_WIDTH 8
`define MEM_DEPTH 8
`define WORD_NUMB 256


module MEM_256bytes (

    input  [`MEM_DEPTH - 1 : 0] addr, 
    // valid addr values for addressing memory should be certainly 16-bits. //

    input  write_en,
    input  read_en,
    input  [`MEM_WIDTH - 1 : 0] write_in,
    output reg [`MEM_WIDTH - 1 : 0] read_out
);

    reg [`MEM_WIDTH - 1 : 0] mem_array [`WORD_NUMB - 1 : 0];


    always @(*) begin

        // (read_en & write_en == 1) VIOLATION IS NOT ALLOWED //

        if (write_en)
            mem_array[addr] = write_in;

        else if (read_en)
            read_out = mem_array[addr];

        else
            read_out = {`MEM_WIDTH{1'b0}};
    
    end

endmodule
