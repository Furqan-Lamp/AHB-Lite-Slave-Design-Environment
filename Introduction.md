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

![Screenshot from 2022-03-08 10-58-10](https://user-images.githubusercontent.com/62382286/157176327-e0a0b5e3-f3b3-4b4d-9ca3-2832f19e1264.png)


Following are the key components of a design verification environment:
**Transaction**
- The Transaction class is used as a way of communication between Generator-Driver and
Monitor-Scoreboard. Fields/Signals required to generate the stimulus are declared in this
class.
**Interface**
- It contains design signals that can be driven or monitored.
**Generator**
- Generates the stimulus (create and randomize the transaction class) and send it to Driver
**Driver**
- Receives the stimulus (transaction) from a generator and drives the packet level data
inside the transaction into the DUT through the interface.
**Monitor**
- Observes the activity on interface signals and converts into packet level data which is
sent to the scoreboard.
**Scoreboard**
- Receives data items from monitors and compares them with expected values. Expected
values can be either golden reference values or generated from the reference model.
**Environment**
- The environment is a container class for grouping all components like generator, driver,
monitor and scoreboard.
**Test**
- The test is responsible for creating the environment and initiating the stimulus driving.
**Testbench Top**
- This is the topmost file, which connects the DUT and Test. It consists of DUT, Test and
interface instances. The interface connects the DUT and Test.


Key Concepts : 
  - Master judges how to send the trasnaction and slave is responsible for doing the job. Slave can only initiate wait states. _Error Response_
  - Wrapping is done respect to size and adding the lower bits and discarding the carry.
  - The Following is the link to the full project on EDA Tool : https://www.edaplayground.com/x/DDqU
