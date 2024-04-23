module MUX_Block(
input wire start_bit,
input wire ser_data,
input wire par_bit,
input wire stop_bit,
input wire [1:0] mux_sel,
output reg S_DATA
);
//Combinational always 
always @(*)
begin
    case(mux_sel)
      ('b00):S_DATA<=start_bit;
      ('b01):S_DATA<=ser_data;
      ('b10):S_DATA<=par_bit;
      ('b11):S_DATA<=stop_bit;
    endcase
end
endmodule
