
//Gets the packet from monitor, generates the expected result and compares with the actual result received from the Monitor
`include "coverage.sv"
class scoreboard;
  coverage cvg;
  //create mailbox handle
  mailbox m_box;
  virtual dut_if vif;
  transaction pkt;
  int Trans_count=0;
  int pass=0;
  int fail=0;
  int idle=0;
  int busy=0;
  int total=0;
  int i_read = 0;
  int f_read = 0;
  int write,read;
  logic [7:0 ] Temp_data;  //Declaring a Temporary Data Storage 
  logic [31:0] temp_d;
  logic [7:0 ] mem [1024]; //Creating A Memory
  //array to use as local memory
  //constructor
  function new(mailbox mbox,virtual dut_if vif);
    this.m_box = mbox;	
    this.vif = vif;
    for(int i=0; i<256 ; i++) mem[i] =i;
     this.cvg = new();
  endfunction 
  //main method 
  task run();
   forever
    begin
    pkt = new();
    m_box.get(pkt);
   // $display($time,"	-----Data in Scoreboard");
       Temp_data = pkt.HADDR;
//       pkt.printR("Scoreboard : ");
      if(pkt.ERROR == 1)  		/// Incase of Error Response
          $display("				Warning :  ERROR Bit is High");
      if(pkt.HTRANS == 2'b00)   /// Incase of IDLE Cases
        begin
          total++; idle++;
        end
      if(pkt.HTRANS == 2'b01)   /// Incase of Busy Cases
        begin
          total++; busy++;
        end
      ///  Memory Management Little Endian  ///
      
      if((pkt.HTRANS == 2'b10 || pkt.HTRANS == 2'b11) && pkt.HWRITE == 1) //If Write, Store Data
         begin
           total++;
           write++;
         case (pkt.HSIZE)
           3'b010: {mem[Temp_data+3],mem[Temp_data+2],mem[Temp_data+1],mem[Temp_data]} = pkt.HWDATA[31:0]; //Word Size
           3'b001: 
             begin
               case(pkt.HADDR[1:0])
                 2'b00: {mem[Temp_data+1],mem[Temp_data]} = pkt.HWDATA[15:0];  //Half Word  
               	 2'b10: {mem[Temp_data+1],mem[Temp_data]} = pkt.HWDATA[31:16]; //Half Word   
               endcase           
           end
           3'b000:
             case(pkt.HADDR[1:0])
               2'b00 :  {mem[Temp_data]}= pkt.HWDATA[7:0];   //Byte
               2'b01 : 	{mem[Temp_data]}= pkt.HWDATA[15:8];  //Byte
               2'b10 :  {mem[Temp_data]}= pkt.HWDATA[23:16]; //Byte
               2'b11 :  {mem[Temp_data]}= pkt.HWDATA[31:24]; //Byte
             endcase
          endcase
         end 
     
      if((pkt.HTRANS == 2'b10 || pkt.HTRANS == 2'b11) &&  pkt.HWRITE == 0) //If Read, 
        begin
        total++; read++;
         case (pkt.HSIZE)
           3'b010: begin //////////////////////// WORD //////////////////////////////////
                 case (pkt.HADDR[1:0])
                  2'b00: begin
                    temp_d[31:0] = {mem[Temp_data+3],mem[Temp_data+2],mem[Temp_data+1],mem[Temp_data]};
                    if( temp_d[31:0]==pkt.HRDATA[31:0]) begin
//                     $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:0]);
                    pass++; end
                    else begin
                    $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:0]);        
          			fail++;
                    end end
            	  2'b01: begin 
                    temp_d[31:8] = {mem[Temp_data+2],mem[Temp_data+1],mem[Temp_data]};
                    if(temp_d[31:8]==pkt.HRDATA[31:8]) 
                      begin
                      $display($time,"	Illegal Read at Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:8]);
                   i_read++;
                      end else 
                      begin
                        $display($time," 	Failed Illegal Read at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:8]);        
                     f_read++; end
                  	end
                   2'b10: begin
                     temp_d[31:16] = {mem[Temp_data+1],mem[Temp_data]};
                     if(temp_d[31:16]==pkt.HRDATA[31:16]) begin
                       $display($time,"	Illegal Read at Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:16]);
                     i_read++;  end
                    else begin
                      $display($time," 	Failed Illegal Read at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:16]);        
          			f_read++;   end
                    end
                   2'b11:  begin
                     temp_d[31:24] = {mem[Temp_data]};
                     if(temp_d[31:24]==pkt.HRDATA[31:24]) begin
                    $display($time,"	Illegal Read at Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                     i_read++; end
                    else begin
                    $display($time," 	Failed Illegal Read at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);        
          			f_read++;  end
                    end   
                 endcase
           end
           3'b001: begin ////////////////////// Half Word //////////////////////////////////////////
             case(Temp_data [1:0])
               2'b00 : begin
	             temp_d[15:0] = {mem[Temp_data+1],mem[Temp_data]};
                 if(temp_d[15:0] == pkt.HRDATA[15:0]) begin
				 $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[15:0]);
                   pass++; end
                 else begin
                 $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[15:0]);
          		 fail++;
                 end end
                2'b01 : begin
                  temp_d[23:8] = {mem[Temp_data+1],mem[Temp_data]};
                  if(temp_d[23:8] == pkt.HRDATA[23:8]) begin
				 $display($time,"	Illegal Read at Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[23:8]);
                  i_read++;
                 end else begin
                   $display($time," 	Failed Illegal Read at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[23:8]);
          		  f_read++; end 
                 end
               2'b10 : begin
                 temp_d[31:16] = {mem[Temp_data+1],mem[Temp_data]};
                 if(temp_d[31:16] == pkt.HRDATA[31:16]) begin
				 $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:16]);
                 pass++; end
                 else begin
                 $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:16]);
                 fail++; end
               end
                2'b11 : begin
                  temp_d[31:24] = {mem[Temp_data+1],mem[Temp_data]};
                  if(temp_d[31:24] == pkt.HRDATA[31:24]) begin
				 $display($time,"	Illegal Read at Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                 i_read++;
                 end
                  else begin
                 $display($time," 	Failed Illegal Read at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                 f_read++;
                  end
               end
             endcase
           end
            3'b000: begin ///////////////////////// byte //////////////////////////////////////
              case(Temp_data [1:0])
              2'b00: begin 
	          temp_d[7:0] =  {mem[Temp_data]};
                if(temp_d[7:0] == pkt.HRDATA[7:0]) begin
// 				$display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[7:0]);
                pass++; end
                else begin
                fail++;
                $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                end end
              2'b01: begin
                temp_d[15:8] =  {mem[Temp_data]};
                if( temp_d[15:8]  == pkt.HRDATA[15:8]) begin
// 				  $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[15:8]);
                  pass++; end
                  else begin
                  fail++;
                  $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[15:8]);
              end end
              2'b10: begin
                temp_d[23:16] =  mem[Temp_data] ;
                if(temp_d[23:16] == pkt.HRDATA[23:16]) begin
// 				 $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[23:16]);
                 pass++; end
                 else begin
                 fail++;
                 $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[26:16]);
                 end end
              2'b11: begin
                temp_d[31:24] =  mem[Temp_data] ;
                if( temp_d[31:24] == pkt.HRDATA[31:24]) begin
// 				 $display($time,"	The Data is Correct, Address : %0h , Data : %0h , Expected Data : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                 pass++; end
                 else begin
                 fail++; 
                 $display($time," 	Failed at Address : %0h , Data : %0h , Data in Memory : %0h",pkt.HADDR,pkt.HRDATA,temp_d[31:24]);
                 end end 
               endcase end
          endcase
        end  
//       $display("			-------------------------------------------------------------------");
      Trans_count++;
      cvg.sample(pkt);    
    end
  endtask

  task stats(); 
     $display("TEST CONCLUDED : Following are the Statistics ");
     $display("Total Number of Transactions Cases : %0d", total);
     $display("Total Number of Write Cases : %0d", write);
     $display("Total Number of Read Cases : %0d", read);
     $display("--------------------------------------------------");
     $display("Total Number of Passes : %0d", pass);
     $display("Total Number of Fail	  : %0d", fail);
     $display("Total Number of IDLE Cases : %0d", idle);
     $display("Total Number of Busy Cases : %0d", busy);
    $display("Total Number of illegal reads : %0d", i_read);
    $display("Total Number of illegal writes : %0d", f_read);
  endtask
  
endclass
