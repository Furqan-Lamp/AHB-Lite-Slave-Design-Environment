# AHB-Lite-Slave-Design-Verification-Environment
Following is the Design Verification Environment for AHB Lite Slave. 
A Memory is integrated as the peripheral attached to the respective slave.


The Verification Environment is composed of a hierarchy. 
**Top Module is our testbench.**
A **Program Block** runs the internal envornment.
A **Transaction Class** is where all our signals are present. 
The **Environment** contains the **Generator** which generates the transaction and sends it to the driver. 
**Driver** forwards it to interface and it is forwarded to DUT.
**Monitor** Receives input from the DUT and sends it to scoreboard.
**Scoreboard** checks the valid input. 
A Final result status is printed at the end.

The Following Project Covers **Sequential** and **Non-Sequential** Cases.
