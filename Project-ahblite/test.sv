
//A program block that creates the environment and initiate the stimulus
`include "environment.sv"
//`include "interface.sv"
program test(dut_if vif);
  //create environment
  //declare environment handle
  environment env;  
  //initiate the stimulus by calling run of env
  initial 
   begin
    env = new(vif);	
    env.run_all();  
  end
 
  ////For EPWave ///
   initial
    begin
      $dumpfile("dump.vcd"); $dumpvars;
    end

endprogram
