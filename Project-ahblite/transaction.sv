//Fields required to generate the stimulus are declared in the transaction class
/*
class transaction;

  //Add print transaction method(optional)
   
endclass
*/
class transaction;
  
  //declare transaction items
	// Input Random Genertaed Data From Master
	rand bit   [31:0] HWDATA; //Input Data For Writing
 	rand bit   [31:0] HADDR; 	
	// Input Signals From Master
	rand bit         HWRITE;  //Write Opeartion
	rand bit   [2:0] HSIZE;	  // Size of the Burst 
	rand bit   [2:0] HBURST;  // Burst Mode Type e.g (3 Bit Burst)
	rand logic [1:0] HTRANS;  // Type Of transaction
    rand logic [3:0] HPROT; // Protection But not used currently
  	rand logic 		 ERROR; 
    rand bit		 HSEL;
  
	// Output Signals from DUT //  
    bit				  HREADY;
 	logic	   [31:0] HRDATA;   // Read data bus
  	bit 	   		  HRESP; 
  	 	
    // Setting Constraints
  constraint constraints_c1 {
   // HBURST inside {3'b000}; // No Bursts
    HSIZE  inside {3'b001, 3'b010 , 3'b000}; // Byte, HalfWord, Word
    HTRANS dist   {2'b10:=8,2'b00:=1,2'b01:=1}; // 2'b00 = IDLE , 2'b01 = H bUSY, 2'b10 = NONSEQ
    HPROT  inside {3'b001}; // Data Access Only
    ERROR  inside {1'b0  };
    HADDR  inside {[32'h0:32'h99]};
    HWRITE dist	  {1'b1:=1,1'b0:=1};
    HSEL   inside {1'b1}; // Alwayas
  }
  constraint constraints_c2 {
    HSIZE == 3'b010 -> HADDR[1:0] inside {2'b00}; 
    HSIZE == 3'b001 -> HADDR[0] inside {1'b0};
  solve HSIZE before HADDR;
  }
  
  function void printR(string Name = " ");
    $display($time,"  %s	HWDATA : %0h , HADDR : %0h , HWRITE : %0h , HSIZE : %0d , HTANS : %0d, HBURST : %0d ,HREADY : %0d , HRESP : %0d , HRDATA : %0h",Name, HWDATA, HADDR, HWRITE, HSIZE, HTRANS,HBURST,HREADY, HRESP,HRDATA);
    endfunction
  
endclass
