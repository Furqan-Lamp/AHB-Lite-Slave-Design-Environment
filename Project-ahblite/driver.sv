
//Gets the packet from generator and drive the transaction packet items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 
//`include "interface.sv"
//`include "packet.sv"

`define dcb vif.Drv.cb_drv
class driver;
  //virtual interface handle
  virtual dut_if vif;
  //create mailbox handle
  mailbox 		m_box;
  int d_count=0;
  //constructor
  function new(mailbox m_box,virtual dut_if vif);
    this.vif = vif;	
	this.m_box = m_box;
  endfunction	
  //drive methods
  transaction rPack2 =new();
  //main methods
  task run();
	   m_box.get(rPack2);
      `dcb.HSIZE   <= rPack2.HSIZE;
      `dcb.HBURST  <= rPack2.HBURST;
      `dcb.HTRANS  <= rPack2.HTRANS;
      `dcb.HWRITE  <= rPack2.HWRITE;
      `dcb.ERR     <= rPack2.ERROR;
      `dcb.HPROT   <= rPack2.HPROT;
      `dcb.HSEL    <= rPack2.HSEL;
      `dcb.HADDR   <= rPack2.HADDR;
      `dcb.HTRANS  <= rPack2.HTRANS;
     @(`dcb);
    	//#1
      `dcb.HWDATA  <= rPack2.HWDATA;
      wait(`dcb.HREADY);
    d_count++;
//     rPack2.printR("Driver 	 : ");
//     $display($time,"		-----Data Transfer Successful-----");    
  endtask
  
    task reset();
      $display($time,"		-----Reset Task has been Called-----");
       //@(vif.clk)
      wait(!vif.resetn);
      `dcb.HADDR   <= '0;
      `dcb.HWDATA  <= '0;
      `dcb.HSIZE   <= 3'b010; //H_Size_32
      `dcb.HBURST  <= 3'b000; //Single Burst
      `dcb.HTRANS  <= '0;  // IDLE
      `dcb.HWRITE  <= '0;
      `dcb.ERR     <= '0;
      `dcb.HPROT   <= '0;
      `dcb.HSEL   <=  '0;
      $display($time,"		-----Data Reset Sucessfull-----");
        wait(vif.resetn);
      //rPack2.printR();
      //$display("[Driver] 	HData : %0d And HAddr : %0d",`dcb.HWDATA,`dcb.HADDR);
  endtask     
  
  task main();
         forever run();
  endtask
  
endclass
