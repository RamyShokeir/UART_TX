module serializer_block #(parameter IN_DATA_WIDTH=8)
(
  input wire [IN_DATA_WIDTH-1:0] P_DATA,
  input wire ser_en,
  input wire CLK,
  input wire RST,
  input wire Data_Valid,
  output reg ser_done,
  output reg ser_data
);
  reg [3:0] count_bits;
  reg [IN_DATA_WIDTH-1:0] input_store_comb;
  assign count_max =(count_bits==4'b1000);

always @(posedge CLK or negedge RST)
   begin
   if (!RST) 
    begin
      input_store_comb<='b0;
      ser_done<=1'b0;
      ser_data <= 1'b0;
      count_bits <= 4'b0;
    end
   else if(!ser_en && Data_Valid )
     begin
      input_store_comb <= P_DATA;
      ser_done<=1'b0;
    end
    else if( ser_en && !count_max)
     begin
        ser_done<=1'b0;
        ser_data <=input_store_comb>>(count_bits);
        count_bits<= count_bits+4'b1;
     end
     else if(count_max)
     begin
        ser_done<=1'b1;
        count_bits<=4'b0;
     end
     else
        begin
          ser_done<=1'b0;
        end
   end
endmodule
