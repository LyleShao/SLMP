`define REG_LENGTH 32
`define REG_NUMBER 16
`define REG_ADDR_LEN_4 4

module REG_32 (
		input clk,
		input rst,
		input read_en,
		input write_en,
		input [`REG_ADDR_LEN_4 - 1 : 0] addr,
		input [`REG_LENGTH - 1 : 0] write_data,
		output reg [`REG_LENGTH - 1 : 0] read_data
		

);

	reg [`REG_LENGTH - 1 : 0] data [`REG_NUMBER - 1 : 0];

	always @(posedge clk) begin

      	if (rst)
			read_data <= {`REG_LENGTH{1'b0}};

		// (read_en & write_en == 1) VIOLATION IS NOT ALLOWED //
		
		else if (read_en)
			read_data <= data[addr];

		else if (write_en)
			data[addr] <= write_data;

	end

endmodule

// The addr should be decoded to the bitwise accessable addr, instead of
// integer value
