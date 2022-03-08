class coverage;
  transaction rPack;	
  
  covergroup cover_set;
    option.per_instance = 1;
    option.name = "Test 1";
    address	: coverpoint rPack.HADDR
    { bins addr[12] = {[8'h0 :8'h99]}; 	
    }
    hsel	: coverpoint rPack.HSEL;
    trans 	: coverpoint rPack.HTRANS
    { bins IDEL    = {3'b000}; 
      bins BUSY    = {3'b001};
      bins SEQ 	   = {3'b010};
      bins NON_SEQ = {3'b011};
    } // IDLE, BUSY, SEQ, NON, SEQ
    write   : coverpoint rPack.HWRITE;
    protec  : coverpoint rPack.HPROT
    {
      bins PROT  	= {3'b001}; 
    }
 	size	: coverpoint rPack.HSIZE
    { bins BYTE  	  = {3'b000}; 
      bins HALF_WORD  = {3'b001}; 
      bins WORD  	  = {3'b010}; 
    }
    burst	: coverpoint rPack.HBURST
    { 
     bins SINGLE = {3'b000};
     bins INCR   = {3'b001};
     bins WRAP4  = {3'b010};
     bins INCR4  = {3'b011};
     bins WRAP8  = {3'b100};
     bins INCR8  = {3'b101};
    } // from Single burst to INCR 8
    
    resp 	: coverpoint rPack.HRESP;
    ready  	: coverpoint rPack.HREADY;
    
  endgroup : cover_set
  
  function new();
    this.cover_set = new();
  endfunction
  
  task sample(transaction rPack);
	this.rPack = rPack;
    cover_set.sample();
  endtask:sample
  
endclass
