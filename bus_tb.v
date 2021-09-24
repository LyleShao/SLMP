`timescale 1 ns / 100 ps

`define MEM_WIDTH 8
`define MEM_DEPTH 8


module bus_tb();
  
  //  input stimulus //
  reg clk, rst, ale_en;
  reg bus_read_en, bus_write_en;
  reg [`MEM_DEPTH - 1 : 0] addr_input;
  reg [`MEM_WIDTH - 1 : 0] data_write;


  // output regs //
  wire [`MEM_WIDTH - 1 : 0] data_read;
  wire [4:0] state_now; 
  wire [4:0] state_nxt;
  wire bus_ready;
  wire [`MEM_DEPTH - 1 : 0] bus_addr;
  wire io_write_en;
  wire io_read_en;
  wire [`MEM_WIDTH - 1 : 0] bus_data_write;
  
  
  SYS_BUS_TEST DUT (
      .clk(clk),
      .rst(rst),
      .ale_en(ale_en),
      .bus_read_en(bus_read_en),
      .bus_write_en(bus_write_en),
      .addr_input(addr_input),
      .data_write(data_write),
      .data_read(data_read),
      .state_now(state_now),
      .state_nxt(state_nxt),
      .bus_ready(bus_ready),
      .bus_addr(bus_addr),
      .io_write_en(io_write_en),
      .io_read_en(io_read_en),
      .bus_data_write(bus_data_write)

  );
  
   initial begin
   $dumpfile("dump.vcd");
   $dumpvars;
   $display($time, " << Starting the Simulation >>");

     
   clk = 0;
   rst = 0;
   ale_en = 0;
   bus_read_en = 0;
   bus_write_en = 0;
   addr_input = 8'h00;
   data_write = 8'h00;

   #10 rst = 1;

   #10 rst = 0;

   #10 ale_en = 1;

   #10 bus_write_en = 1;
       bus_read_en = 0;
       ale_en = 0;
       addr_input = 8'h04;



   #10 bus_write_en = 0;
       bus_read_en = 0;
       data_write = 8'hff;
       addr_input = 8'h00;

   #10 data_write = 8'h00;

                            // phase-2 //

   #10 ale_en = 1;

   #10 ale_en = 0;
       bus_read_en = 1;
       addr_input = 8'h04;

   #10 bus_read_en = 0;
       bus_write_en = 0;
       addr_input = 8'h00;
       
     
   #100 $finish;
   
   end


  
  always #5 clk = ~clk;



  
endmodule
    
  
  
  
