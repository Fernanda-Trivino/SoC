
// ============================================================================
// TESTBENCH FOR TINYCPU
// ============================================================================

module i2c_TB ();

reg sys_clk_i, sys_rst_i;

reg I2C_clk, I2C_rst;
wire scl; // i2c clock line
wire sda; // i2c data line

reg [ 7:0] prescale; // clock prescale register
reg [ 7:0] control;  // control register
reg [ 7:0] transmit;  // transmit register
wire [ 7:0] receive;  // receive register
reg [ 7:0] command;   // command register
wire [ 7:0] status;   // status register
wire TIP;

reg rst_1;
i2c uut(
	I2C_clk, I2C_rst, rst_1,TIP,
    prescale,control,transmit,receive,command,status,
    scl,sda);



initial begin
I2C_clk   = 1;
rst_1=0;
#10 rst_1 = 1;

  I2C_rst = 1;
  #10 I2C_rst = 0;
  
 prescale= 2;
command=0;
  #2 control= 8'b10000000;
  #2 transmit=8'hA6;
  command= 8'b10010000;
  
  #3900000000000000000000000000000000000000000000000000000000000000000 transmit=8'hfa;
  command= 8'b01010000;

    #390 command= 8'b0000;

end

always I2C_clk = #1 ~I2C_clk;


initial begin: TEST_CASE
  $dumpfile("i2c_TB.vcd");
  $dumpvars(-1, uut);
  #8000 $finish;
end

endmodule
