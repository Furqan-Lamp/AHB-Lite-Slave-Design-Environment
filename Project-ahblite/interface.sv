// Interface groups the design signals, specifies the direction (Modport) and Synchronize the signals(Clocking Block)

interface dut_if(input logic clk,resetn);
  //  Add design signals here
  //  Data and Address Signals //////
  logic [31:0]  	HADDR;   // 32 Bit For Address
  logic [31:0]  	HWDATA;  // 32 Bit For Data
  //////  Control Signals   //////
  bit 	    	HWRITE;  // WRITE Signal;
  logic [1:0] 	HTRANS;  // Type of Transaction (Non Seq)
  logic [2:0]	HSIZE;   // Signal For Size 
  logic [2:0] 	HBURST;  // Burst type (Single Burst)
  logic [3:0] 	HPROT;   // ?
  logic 		HSEL;  //
  logic 		ERR;
  //////   Output Signals   //////
  logic  [31:0]	HRDATA;
  logic 	    HRESP;
  logic 		HREADY;
    //Master Clocking block - used for Drivers
    //Monitor Clocking block - For sampling by monitor components
  
clocking cb_drv  @(posedge clk);
    default input #1 output #1; //Input and Output skews
	output HSEL,HADDR,HWDATA,HTRANS,HWRITE,HSIZE,HPROT,HBURST,ERR;
   	input HRDATA,HREADY,HRESP;
   // inputs to DUT	
  endclocking 
  
  clocking cb_mon @(posedge clk);
    default input #1 output #1; //input and Output Skews
    input HSEL,HADDR,HWDATA,HTRANS,HWRITE,HSIZE,HPROT,HBURST,ERR;
    input HRDATA,HRESP,HREADY; 
  endclocking
  
   //Add modports here
  modport Drv(    //from driver to dut
   clocking cb_drv,
   input clk,resetn);
  
  modport Mon (   //from dut to mon
   clocking cb_mon,
   input clk,resetn ); 

endinterface

