`include  "MUX.v"
`include "Parity_Calc.v"
`include "Serializer.v"
`include "FSM.v"
module UART_TX #(parameter P_DATA_WIDTH=8)
(
    input wire [P_DATA_WIDTH-1:0] P_DATA,
    input wire CLK,RST,
    input wire Data_Valid,
    input wire PAR_EN,PAR_TYP,
    output wire busy,
    output wire S_DATA
);
//Internal Signals
wire ser_done,ser_en,ser_data;
wire [1:0] mux_sel;
wire par_bit;
wire start_bit,stop_bit;

parityCalc_block #(.IN_DATA_WIDTH(P_DATA_WIDTH)) U0_Parity (
.P_DATA(P_DATA),
//.CLK(CLK),
.Data_Valid(Data_Valid),
.PAR_TYP(PAR_TYP),
.par_bit(par_bit)
);
serializer_block #(.IN_DATA_WIDTH(P_DATA_WIDTH)) U0_serializer(
.P_DATA(P_DATA),
.ser_en(ser_en),
.CLK(CLK),
.RST(RST),
.Data_Valid(Data_Valid),
.ser_done(ser_done),
.ser_data(ser_data)
);
FSM_Block U0_FSM(
.ser_done(ser_done),
.PAR_EN(PAR_EN),
.Data_Valid(Data_Valid),
.CLK(CLK),
.RST(RST),
.ser_en(ser_en),
.start_bit(start_bit),
.stop_bit(stop_bit),
.busy(busy),
.mux_sel(mux_sel)
);
MUX_Block U0_MUX(
.ser_data(ser_data),
.par_bit(par_bit),
.mux_sel(mux_sel),
.start_bit(start_bit),
.stop_bit(stop_bit),
.S_DATA(S_DATA)
);
endmodule
