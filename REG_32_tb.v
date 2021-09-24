`timescale 1 ns / 100 ps

`define REG_LENGTH 32
`define REG_ADDR_LEN_4 4

module REG_32_tb();
  
  reg clk, rst;
  reg read_en, write_en;
  reg [`REG_ADDR_LEN_4 - 1 : 0] addr;
  reg [`REG_LENGTH - 1 : 0] write_data;
  wire [`REG_LENGTH - 1 : 0] read_data;
  
  
  REG_32 DUT (.clk(clk),
              .rst(rst),
              .read_en(read_en),
              .write_en(write_en),
              .addr(addr),
              .write_data(write_data),
              .read_data(read_data)
             );
  
   initial begin
   $display($time, " << Starting the Simulation >>");
     
   clk = 0;
   rst = 0;
   addr = 4'b0000;
   write_data = 32'h43211234;


   read_en = 0;
   write_en = 1;
     
   #20 rst = 1'b1;

   #20 rst = 1'b0;
     
   end
  
  always #10 clk = ~clk;

  always begin
    
    #20 
    read_en = ~read_en; 
    write_en = ~write_en;

  end

  always begin
    
    #40

    addr = addr + 4'b0001;
    write_data = write_data + 32'h48791234;

  end



  
endmodule
    
  
  
  
