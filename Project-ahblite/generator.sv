//Generates randomized transaction packets and put them in the mailbox to send the packets to driver 
class generator;
   int ok;
  //declare transaction class
  transaction rPack;
  int gen_count = 0;
  int i;
  int addr,add_size,nbits; 
  //create mailbox handle
  mailbox genbox;
  logic [31:0] rmem [1023:0]; 
  logic [2:0]  smem [1023:0];
  logic temp;  
  //declare an event
  event event_g;
  //constructor
	function new(input mailbox m_box);
	 this.genbox = m_box;
	endfunction 
  //main methods
  task random(input int L1);
    repeat(L1)
       begin
         pre_routine();
         rPack.HSEL = 1; 
         post_routine();
       end 
     $display("					-----------------------------------------------");
    ->event_g;
  endtask : random  
  
  /////////////////////////// Single Burst  /////////////////////////
  
  task Single_Burst(input int loop, input int WR);
    	pre_routine();
        this.rPack.HWRITE = WR; 
    	smem[1] = this.rPack.HSIZE ;  // Non Sequential for the First
        addr = 	 this.rPack.HADDR;
    	this.rPack.HBURST = 3'b000; // For Single Burst
        post_routine();
    	loop--;
    repeat(loop)	// For Reading Data at Address 0
       begin
        pre_routine();
        this.rPack.HWRITE = WR; 
        this.rPack.HSIZE  = smem[1]; 
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HBURST = 3'b000; 
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
         endcase 
        this.rPack.HADDR = addr+add_size;
        post_routine();
       end  
   ->event_g;
  endtask
  
  //////////////////////////// INCR4 ////////////////////////////////
  
  task INCR4(input wr_data);
	    pre_routine();
    	this.rPack.HBURST = 3'b011; //4 beat Incrementing Burst
        this.rPack.HWRITE = wr_data; 
        this.rPack.HTRANS = 3'b010; // Non-Sequential 
    	smem[1]=this.rPack.HSIZE;
        post_routine();
    repeat(3)	
       begin
        pre_routine();
        this.rPack.HWRITE = wr_data; 
        this.rPack.HBURST = 3'b011; //4 beat Incrementing Burst
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest
        this.rPack.HSIZE = smem[1];
         case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
         endcase 
        this.rPack.HADDR = addr+add_size;
        post_routine();
       end  
   ->event_g;
  endtask
  
  ///////////////////// INCR 8 ///////////////////////
  
  task INCR8(input wr_data);
	    pre_routine();
    	this.rPack.HBURST = 3'b101; // 8 beat Incrementing Burst
        this.rPack.HTRANS = 3'b010; // First Non Sequential 
        this.rPack.HWRITE = wr_data; 
    	smem[1] =this.rPack.HSIZE;
        post_routine();
    repeat(7)	
       begin
        pre_routine();
        this.rPack.HBURST = 3'b101; // 8 beat Incrementing Burst 
        this.rPack.HWRITE = wr_data; 
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest
         this.rPack.HSIZE = smem[1];
         case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
         endcase 
        this.rPack.HADDR = addr+add_size;
        post_routine();
       end  
   ->event_g;
  endtask
  
  
  //////////////////////// Wrap 4 //////////////////////////
  
   task WRAP4(input wr_data);
        pre_routine();
    	this.rPack.HBURST = 3'b010; // 4 Beat Wrapping Burst
     	this.rPack.HTRANS = 3'b010; // Sequential for the Rest 
        this.rPack.HWRITE = wr_data; 
    	smem[1] = this.rPack.HSIZE; 	// Storing Size for Next 3 iterations 
        post_routine();
     repeat(3)		   
       begin
        pre_routine();
        this.rPack.HBURST = 3'b010; // 4 beat Wrapping Burst
     	this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HWRITE = wr_data; 
        this.rPack.HSIZE  = smem[1]; // Sequential for the Rest
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
         endcase
         nbits = $clog2(add_size*4); // Taking Log with respect to SIZE
         wrapx(nbits,add_size,addr); // Passing it into a Function
         post_routine();
       end  
   ->event_g;
  endtask
  
  //////////////////// WRAP8 ///////////////////////////
  
   task WRAP8(input wr_data);
        pre_routine();
    	this.rPack.HBURST = 3'b100; // 8 Beat Wrapping Burst
     	this.rPack.HTRANS = 3'b010; // Sequential for the Rest 
        this.rPack.HWRITE = wr_data; 
    	smem[1] = this.rPack.HSIZE; 	// Storing Size for Next 3 iterations 
        post_routine();
     repeat(7)		   
       begin
        pre_routine();
        this.rPack.HBURST = 3'b100; // 8 beat Wrapping Burst
     	this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HWRITE = wr_data; 
        this.rPack.HSIZE  = smem[1]; // Sequential for the Rest
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
         endcase
         nbits = $clog2(add_size*8); // Taking Log with respect to SIZE
         wrapx(nbits,add_size,addr); // Passing it into a Function
//          $display(nbits); 
        post_routine();
       end  
   ->event_g;
  endtask
  
  task wrapx(input int n_bits,add_size,addr);
    int temp;
    case(n_bits)
      2 : begin 
        temp[1:0] = addr[1:0];
        temp[1:0] = temp+add_size;
        rPack.HADDR = {addr[31:2],temp[1:0]}; end
      3 : begin 
        temp[2:0] = addr[2:0];
        temp[2:0] = temp+add_size;
        rPack.HADDR = {addr[31:3],temp[2:0]}; end
      4 : begin 
        temp[3:0] = addr[3:0];
        temp[3:0] = temp+add_size;
        rPack.HADDR = {addr[31:4],temp[3:0]}; end
      5 : begin 
        temp[4:0] = addr[4:0];
        temp[4:0] = temp+add_size;
        rPack.HADDR = {addr[31:5],temp[4:0]}; end
    endcase
  endtask
  
 /////////// Pre and Post Routines ////////////// 
  task pre_routine();
    	 rPack = new();
	     ok = this.rPack.randomize();
  endtask  
  
  task post_routine();
        addr = rPack.HADDR;
        genbox.put(rPack);   
        rPack.printR("Generator ");
        gen_count++;
  endtask
  
  
  
 /////////// / Main Tasks ///////////////////////
  
  task main();
    ////////// For Single Burst //////////////
    random(100);	
    for(int i=0;i<10;i++)
      begin
    ////////// For Single Burst //////////////
        Single_Burst(5,1);  // Length and Wirte/Read
    ////////// For INCR 4 ////////////////////
      INCR4(1);
    ////////// For INCR 8 ////////////////////
      INCR8(1);
    ////////// For WRAP 4 ////////////////////
      WRAP4(1);
    ////////// For WRAP 8 ////////////////////
      WRAP8(1); 
      end
    
    for(int i=0;i<10;i++) //Read
      begin
    ////////// For Single Burst //////////////
        Single_Burst(5,0); 
    ////////// For INCR 4 ////////////////////
      INCR4(0);
    ////////// For INCR 8 ////////////////////
      INCR8(0);  
    ////////// For WRAP 4 ////////////////////
      WRAP4(0);
    ////////// For WRAP8 8 ////////////////////
      WRAP8(0); 
      end
  endtask
endclass

