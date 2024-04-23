module parityCalc_block #(parameter IN_DATA_WIDTH=8)(
input wire [IN_DATA_WIDTH-1:0] P_DATA,
input wire Data_Valid,
input wire PAR_TYP,
output reg par_bit
);
always @(*)
begin
 if(Data_Valid)
  begin
   if(PAR_TYP==1'b0)
    par_bit<=(^P_DATA);
   else
    par_bit<=(~^P_DATA);
  end
 else
    par_bit<=par_bit;
end
endmodule
