`timescale 1us/1ns
`include "UART_TX_RTL.v"
module UART_TX_TB #(parameter P_DATA_WIDTH_TB=8) ();
//Defining INPUTS and OUTPUTS
reg [P_DATA_WIDTH_TB-1:0] P_DATA_TB;
reg Data_Valid_TB;
reg CLK_TB;
reg RST_TB;
reg PAR_EN_TB;
reg PAR_TYP_TB;
//Those 2 Output Signals to be checked for test cases
wire S_DATA_TB;
wire busy_TB;

parameter CLK_PERIOD=8.68;

//First Packet
parameter [P_DATA_WIDTH_TB-1:0] data_1 ='b01011010;
//Second Packet
parameter [P_DATA_WIDTH_TB-1:0] data_2='b01101011;

//INITIAL BLOCK

initial 
begin
    //System Commands
    $dumpfile("Output.vcd");
    $dumpvars;
    //Initialize 
    initialize();
    //No Parity
    parity_configuration(1'b0,1'b1);
    //Reset
    reset();
    
    load_parallel_data(data_1);
//Data Cycles
    check_serial_data(data_1);
//Busy Signal Activated during the data cycles
    check_busy_signal();
//Busy Signal is Activated during the Stop Cycle
    check_busy_signal();

    load_parallel_data(data_2);
//Data Cycles
    check_serial_data(data_2);
//Busy Signal Activated during the Data Cycles
    check_busy_signal();
//Busy Signal is Activated during the Stop Cycle
    check_busy_signal();

//Enabling Parity and choosing the type as odd
    parity_configuration(1'b1,1'b1);
    load_parallel_data(data_1);
//Data Cycles
    check_serial_data(data_1);
//Busy Signal Activated during the data cycles
    check_busy_signal();
//Busy Signal Activated during the Parity Cycle
    check_busy_signal();
//Busy Signal is Activated during the Stop Cycle
    check_busy_signal();

    load_parallel_data(data_2);
//Data Cycles
    check_serial_data(data_2);
//Busy Signal Activated during the data cycles
    check_busy_signal();
//Busy Signal Activated during the Parity Cycle
    check_busy_signal();
//Busy Signal is Activated during the Stop Cycle
    check_busy_signal();

    #CLK_PERIOD
    $finish;
end

//TASKS

//Initialization
task initialize;
begin
    Data_Valid_TB=1'b0;
    CLK_TB=1'b0;
    RST_TB=1'b1;
    P_DATA_TB='b0;
end
endtask
//Reset
task reset;
begin
    #CLK_PERIOD 
    RST_TB=1'b0;//100 low
    #CLK_PERIOD
    RST_TB=1'b1;//200 high
end
endtask

//Loading Parallel data
task load_parallel_data;
input [P_DATA_WIDTH_TB-1:0] p_data;
begin
Data_Valid_TB=1'b1;
#(CLK_PERIOD/2)
P_DATA_TB=p_data;
#(CLK_PERIOD/2)
Data_Valid_TB=1'b0;
P_DATA_TB='b0;
end
endtask

//Checking busy Signal
task check_busy_signal;
#CLK_PERIOD
if(busy_TB==1'b1)
    $display("Activated Busy Signal");
else
    $display("Deactivated Busy Signal");
endtask

//Checking Serial bits at Output
task check_serial_data;
integer count;
input [P_DATA_WIDTH_TB-1:0] p_data;
begin
    #CLK_PERIOD
    for(count=0;count<=P_DATA_WIDTH_TB-1;count=count+1)
    begin
        #CLK_PERIOD
        if(S_DATA_TB==p_data[count])
        $display("Bit number %d Succeeded = %b",count+1,S_DATA_TB);
        else
        $display("Bit number %d Failed = %b",count+1,S_DATA_TB);
    end
end
endtask
task parity_configuration;
input parity_enable;
input parity_type;
begin
    //Configuration make PAR_EN equal 1 if parity needed and 0 if not needed
    PAR_EN_TB=parity_enable;
    //Configuration make PAR_TYP equal 0 for even parity and 1 for odd parity
    PAR_TYP_TB=parity_type;
end
endtask

//CLOCK GENERATOR
always #(CLK_PERIOD/2) CLK_TB=~CLK_TB;
// Instantiation
UART_TX #(.P_DATA_WIDTH(P_DATA_WIDTH_TB)) DUT(
.P_DATA(P_DATA_TB),
.Data_Valid(Data_Valid_TB),
.PAR_EN(PAR_EN_TB),
.PAR_TYP(PAR_TYP_TB),
.CLK(CLK_TB),
.RST(RST_TB),
.S_DATA(S_DATA_TB),
.busy(busy_TB)
);
endmodule
