//Top most file which connets DUT, interface and the test

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
//`include "test1.sv"
//`include "test2.sv"
//`include "test3.sv"
//----------------------------------------------------------------
`include "interface.sv"
`include "test.sv"
module testbench_top;
  //declare clock and reset signal
    timeunit 1ns;
	timeprecision 1ns;
  logic clk;
  logic resetn;
  //clock generation
  always
    begin 
    #5 clk = ~clk;
    end 
  //reset generation
  initial 
    begin
    	clk <= 0;
		resetn <= 0;
		#10 resetn <= 1;
	end
  
  //Interface instance, inorder to connect DUT and testcase
  dut_if intf(clk,resetn);
  //Testcase instance, interface handle is passed to test as an argument
  test t(intf);
  //DUT instance, interface signals are connected to the DUT ports
 amba_ahb_slave dut(
   .hclk	(intf.clk	),  // Clock
   .hresetn (intf.resetn),  // Reset
    
   .haddr	(intf.HADDR	), 	// 32 bit Address 	 //
   .hwdata	(intf.HWDATA), 	// 32 bit Write Data //
    
   .hwrite	(intf.HWRITE),	// Write Signal //
    .htrans	(intf.HTRANS),	// Transaction 	//
    .hsize	(intf.HSIZE	),	// Size 		//
    .hburst	(intf.HBURST),	// Burst Type	//
    .hprot	(intf.HPROT ),
    .hsel	(intf.HSEL  ),  // Zabardasti ki Bits
    .error	(intf.ERR	),	// Yeh wali bhi
    
    .hready	(intf.HREADY),  // Output "Transfer Done"
    .hrdata	(intf.HRDATA),  // Output "Read Data Bus"
    .hresp 	(intf.HRESP	)   // ANOTHER Output! 
  );
  
endmodule
