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
  task write(input int L1);
    i=0;
    repeat(L1)
       begin
         pre_routine();
         rPack.HWRITE = 1; 
         post_routine();
         i++;
       end 
     $display("					-----------------------------------------------");
    ->event_g;
  endtask : write 
  
  task read(input int L1);
    i=0;
    repeat(L1)
       begin
         pre_routine();
         rPack.HWRITE = 0;
         post_routine();
             i++;
       end 
     $display("					-----------------------------------------------");
    ->event_g;
    
  endtask : read
  
  /////////////////////////// Undefined length Burst  /////////////////////////
  
  task Undefined_Burst(input int loop, input int WR);
    	pre_routine();
        this.rPack.HWRITE = WR; 
    	smem[1] = this.rPack.HSIZE ;  // Non Sequential for the First
        addr = 	 this.rPack.HADDR;
    	this.rPack.HBURST = 3'b001; // For Single Burst
        post_routine();
    	loop--;
    repeat(loop)	// For Reading Data at Address 0
       begin
        pre_routine();
        this.rPack.HWRITE = WR; 
        this.rPack.HSIZE  = smem[1]; 
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HBURST = 3'b001; 
       // this.rPack.HADDR = ; 
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
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
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
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
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
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
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
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
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
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
      6 : begin 
        temp[5:0] = addr[5:0];
        temp[5:0] = temp+add_size;
        rPack.HADDR = {addr[31:6],temp[5:0]}; end
      7 : begin 
        temp[6:0] = addr[6:0];
        temp[6:0] = temp+add_size;
        rPack.HADDR = {addr[31:7],temp[6:0]}; end
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
  
  task TEST_WR(); // INCR 8
	    pre_routine();
    	this.rPack.HBURST = 3'b101; // 8 beat Incrementing Burst
        this.rPack.HTRANS = 3'b010; // First Non Sequential 
        this.rPack.HWRITE = 1; 
//         this.rPack.HADDR = 0;
    	smem[1] = this.rPack.HSIZE;
        post_routine();
    repeat(7)	
       begin
        pre_routine();
        this.rPack.HBURST = 3'b101; // 8 beat Incrementing Burst 
        this.rPack.HWRITE = 1; 
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest
//          this.rPack.HADDR = 0;
         this.rPack.HSIZE = smem[1];
         case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
         endcase 
        this.rPack.HADDR = addr+add_size;
        post_routine();
       end  
   ->event_g;
  endtask
  
  task TEST_RD(); //INCR 8
	    pre_routine();
    	this.rPack.HBURST = 3'b010; // 8 beat Incrementing Burst
        this.rPack.HTRANS = 3'b010; // First Non Sequential \
        this.rPack.HWRITE = 0; 
        this.rPack.HADDR = 0;
    	smem[1] = this.rPack.HSIZE;
        post_routine();
    repeat(3)	
       begin
         pre_routine();
         this.rPack.HADDR = 0;
        this.rPack.HBURST = 3'b010; // 8 beat Incrementing Burst 
        this.rPack.HWRITE = 0; 
        this.rPack.HTRANS = 3'b011; // Sequential for the Rest
         this.rPack.HSIZE = smem[1];
         case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
         endcase 
        this.rPack.HADDR = addr+add_size;
        post_routine();
       end  
   ->event_g;
  endtask
  
  //////////////////////////// Test Tasks
  
  task WRAPW();
        pre_routine();
//     	this.rPack.HADDR = 0;
    	this.rPack.HBURST = 3'b100; // 8 Beat Wrapping Burst
     	this.rPack.HTRANS = 3'b010; // Sequential for the Rest 
        this.rPack.HWRITE = 1; 
    	smem[1] = this.rPack.HSIZE; 	// Storing Size for Next 3 iterations 
        post_routine();
     repeat(7)		   
       begin
        pre_routine();
//         this.rPack.HADDR = 0;
        this.rPack.HBURST = 3'b100; // 8 beat Wrapping Burst
     	this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HWRITE = 1; 
        this.rPack.HSIZE  = smem[1]; // Sequential for the Rest
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
         endcase
         nbits = $clog2(add_size*8); // Taking Log with respect to SIZE
         wrapx(nbits,add_size,addr); // Passing it into a Function
//          $display(nbits); 
        post_routine();
       end  
   ->event_g;
  endtask
  
   task WRAPR();
        pre_routine();
    	this.rPack.HBURST = 3'b100; // 8 Beat Wrapping Burst
     	this.rPack.HTRANS = 3'b010; // Sequential for the Rest 
        this.rPack.HWRITE = 0; 
//                 this.rPack.HADDR = 0;
    	smem[1] = this.rPack.HSIZE; 	// Storing Size for Next 3 iterations 
        post_routine();
     repeat(7)		   
       begin
        pre_routine();
        this.rPack.HBURST = 3'b100; // 8 beat Wrapping Burst
     	this.rPack.HTRANS = 3'b011; // Sequential for the Rest 
        this.rPack.HWRITE = 0; 
                 this.rPack.HADDR = 0;
        this.rPack.HSIZE  = smem[1]; // Sequential for the Rest
        case(rPack.HSIZE)
           3'b000 : add_size = 1;
           3'b001 : add_size = 2;
           3'b010 : add_size = 4;
           3'b011 : add_size = 8;
           3'b100 : add_size = 16;
         endcase
         nbits = $clog2(add_size*8); // Taking Log with respect to SIZE
         wrapx(nbits,add_size,addr); // Passing it into a Function
//          $display(nbits); 
        post_routine();
       end  
   ->event_g;
  endtask
  
  
  ///////////////////////////////////////
  
 /* task hard_read(input int L1);
    i=0;
    repeat(L1)
       begin
         pre_routine();
         rPack.HWRITE = 0;
         rPack.HADDR  = 'h11;
         rPack.HSIZE  = 0;
         rPack.HBURST = 3'b011;
         post_routine();
    	 i++;
       end 
     $display("					-----------------------------------------------");
    ->event_g;
    
  endtask : hard_read */
  
  
  task main();
    ////////// For Single Burst //////////////
    write(150);
    read(150);
    
         //////// Undefined Burst //////////////
     Undefined_Burst(5,1);  // Length and Wirte/Read
    
    ////////// For Single Burst //////////////
   //   Undefined_Burst(5,0); 
    ////////// For INCR 4 ////////////////////
    repeat (5) INCR4(1);
    ////////// For INCR 8 ////////////////////
    repeat (5) INCR8(1);  
    ////////// For WRAP 4 ////////////////////
    repeat (5) WRAP4(1);
    ///////// For WRAP8 8 ////////////////////
    repeat (5) WRAP8(1);  
    
    Undefined_Burst(5,0); 
    ////////// For INCR 4 ////////////////////
     repeat (5) INCR4(0);
    ////////// For INCR 8 ////////////////////
     repeat (5) INCR8(0);  
    ////////// For WRAP 4 ////////////////////
      WRAP4(0);
    ///////// For WRAP8 8 ////////////////////
    WRAP8(0);   
  endtask
endclass

