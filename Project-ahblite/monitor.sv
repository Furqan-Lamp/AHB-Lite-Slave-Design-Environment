
//Samples the interface signals, captures into transaction packet and sends the packet to scoreboard.
`define mcb vif.Mon.cb_mon
class monitor;
	virtual dut_if vif;
    transaction pkt;
  	int mon_count;
  //create mailbox handle
  mailbox m1 = new();
  //constructor
  function new(mailbox mbox,virtual dut_if vif);
  	this.m1	= mbox;
    this.vif = vif;
   endfunction
  //main method
  task run();
 @(`mcb)
    forever begin
      pkt = new(); //Clocking block event (at posedge of Clock)
       this.pkt.HADDR  = `mcb.HADDR;
       this.pkt.HWRITE = `mcb.HWRITE;
       this.pkt.HSIZE  = `mcb.HSIZE;
       this.pkt.HTRANS = `mcb.HTRANS;
       this.pkt.HPROT  = `mcb.HPROT;
       this.pkt.HSEL   = `mcb.HSEL;
       this.pkt.HBURST = `mcb.HBURST;
       this.pkt.ERROR = `mcb.ERR;

      @(`mcb); //Clocking block event (at posedge of Clock)
       this.pkt.HWDATA = `mcb.HWDATA;
       this.pkt.HRDATA = `mcb.HRDATA;
	   this.pkt.HRESP  = `mcb.HRESP;
       this.pkt.HREADY = `mcb.HREADY; 
       //$display($time,"		-----Output Data has been recieved by Monitor-----");
       m1.put(pkt);
//         pkt.printR("Monitor    : ");
    end
  endtask 
  
  
endclass
