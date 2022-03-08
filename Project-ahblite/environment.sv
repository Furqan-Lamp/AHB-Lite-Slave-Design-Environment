//A container class that contains Mailbox, Generator, Driver, Monitor and Scoreboard
//Connects all the components of the verification environmen
//`endi

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "monitor.sv"

class environment;
  //handles of all components
  generator gen_a;  //From Gen
  driver 	drv_a;  // TO Driver
  monitor   mon;
  scoreboard scr;
  //mailbox handles
  mailbox gen_m; //From Generator to Driver
  mailbox dut_m; //From Dut to Scoreboard 
  //virtual interface handle
  virtual dut_if vif; 
  //Constructor 
  function new(input virtual dut_if vif);
    this.vif = vif;
    gen_m = new(); // Mailbox Gen to Driver
    dut_m = new(); // Mailbox Monitor to Scoreboard
    gen_a = new(gen_m);
    drv_a = new(gen_m,vif);
    mon =  new(dut_m,vif);
    scr =  new(dut_m,vif);
  endfunction
  //declare an event
  event e1;
  //pre_test methods
  task pre_test;
    drv_a.reset();
  endtask
  //test methods
  task e_run;
    fork
    gen_a.main();  
    drv_a.main();
    mon.run();
    scr.run();
    join_any
  endtask
  //post_test methods
  task post_test();   //For Transaction to Complete
    wait(gen_a.event_g.triggered); 
    wait(gen_a.gen_count == scr.Trans_count);
  endtask
  //run methods
  task run_all;
    pre_test();
    e_run();
    post_test();
    scr.stats(); //Calling The Task of Statistics
    $finish;
 endtask  

endclass


