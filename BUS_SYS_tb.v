`timescale 1 ns / 100 ps

`define MEM_WIDTH 8
`define MEM_DEPTH 8


module bus_tb();
  
  //  controller //
  reg clk, rst, ale_en;
  reg bus_read_en, bus_write_en;
  reg [`BUS_ADDR_WIDTH - 1 : 0] addr_input;
  reg [`MEM_WIDTH - 1 : 0] data_write;
  wire [`MEM_WIDTH - 1 : 0] data_read;


  // IO interface //
  reg  [`MEM_WIDTH - 1 : 0] bus_data_read_premux [`BUS_IO_NUM - 1 : 0];
  wire [`MEM_DEPTH - 1 : 0] bus_addr;
  wire [`BUS_ADDR_WIDTH - 1 : `MEM_DEPTH] io_addr;
  wire [`BUS_IO_NUM - 1 : 0] io_read_en;
  wire [`BUS_IO_NUM - 1 : 0] io_write_en;
  wire [`MEM_WIDTH - 1 : 0] bus_data_write;

  
  // simulation outputs //
  wire [4:0] state_now; 
  wire [4:0] state_nxt;
  wire bus_ready;
  wire [`MEM_WIDTH - 1 : 0] bus_data_read_postmux;
  
  
  SYS_BUS_TEST DUT (
      .clk(clk),
      .rst(rst),
      .ale_en(ale_en),
      .bus_read_en(bus_read_en),
      .bus_write_en(bus_write_en),
      .addr_input(addr_input),
      .data_write(data_write),
      .data_read(data_read),

      .bus_data_read_premux(bus_data_read_premux),
      .bus_addr(bus_addr),
      .io_addr(io_addr),
      .io_read_en(io_read_en),
      .io_write_en(io_write_en),
      .bus_data_write(bus_data_write),

      .state_now(state_now),
      .state_nxt(state_nxt),
      .bus_ready(bus_ready),
      .bus_data_read_postmux(bus_data_read_postmux)

  );

  MEM_256bytes MEM_0 (
      .addr(bus_addr),
      .write_en(io_write_en[0]),
      .read_en(io_read_en[0]),
      .write_in(bus_data_write),
      .read_out(bus_data_read_premux[0])

  );

  MEM_256bytes MEM_1 (
      .addr(bus_addr),
      .write_en(io_write_en[1]),
      .read_en(io_read_en[1]),
      .write_in(bus_data_write),
      .read_out(bus_data_read_premux[1])

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
   addr_input = 12'h000;
   data_write = 8'h00;

   #10 rst = 1;

   #10 rst = 0;

   #10 ale_en = 1;

   #10 bus_write_en = 1;
       bus_read_en = 0;
       ale_en = 0;
       addr_input = 12'h004;



   #10 bus_write_en = 0;
       bus_read_en = 0;
       data_write = 8'hff;
       addr_input = 12'h000;

   #10 data_write = 8'h00;

                            // phase-2 //

   #10 ale_en = 1;

   #10 ale_en = 0;
       bus_read_en = 1;
       addr_input = 12'h004;

   #10 bus_read_en = 0;
       bus_write_en = 0;
       addr_input = 12'h000;
       
     
   #100 $finish;
   
   end


  
  always #5 clk = ~clk;



  
endmodule
    
  
  
  
