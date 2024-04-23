module FSM_Block (
    input wire ser_done,
    input wire PAR_EN,
    input wire Data_Valid,
    input wire CLK,RST ,
    output reg ser_en,
    output reg busy,
    output reg start_bit,
    output reg stop_bit,
    output reg [1:0] mux_sel
);
reg [4:0] current_state,next_state;
localparam [4:0] IDLE_STATE=5'b00001,
                START_STATE=5'b00010,
                DATA_STATE=5'b00100,
                PARITY_STATE=5'b01000,
                STOP_STATE=5'b10000;

//Sequential Block for State Transition 
always @(posedge CLK or negedge RST)
begin
    if(!RST)
        current_state<=IDLE_STATE;
    else
        current_state<=next_state;
end

//Combinational Always Block for Next State logic + Output logic
always @ (*)
 begin
    //default output values
    start_bit=1'b1;
    stop_bit=1'b0;
    ser_en=1'b0;
    busy=1'b0;
    mux_sel=2'b00;
   case(current_state)
    IDLE_STATE:
        begin
                start_bit=1'b1;
                stop_bit=1'b0;
                ser_en=1'b0;
                busy=1'b0;
                mux_sel=2'b00;
         if(!Data_Valid)
            begin
                next_state<=IDLE_STATE;
            end
         else
            begin
                next_state<=START_STATE;
            end
        end
    START_STATE:
        begin
                start_bit=1'b0;
                stop_bit=1'b0;
                ser_en=1'b0;
                busy=1'b1;
                mux_sel=2'b00;
                next_state<=DATA_STATE;
        end
    DATA_STATE:
        begin
                start_bit=1'b1;
                stop_bit=1'b0;
                busy=1'b1;
                ser_en=1'b1;
                mux_sel=2'b01;
            if(!ser_done)
                begin
                    next_state<=DATA_STATE;
                end
            else if(PAR_EN)
                begin
                        ser_en=1'b0;
                        mux_sel=2'b10;
                    next_state<=PARITY_STATE;
                end
            else
                begin
                                 ser_en=1'b0;
                        mux_sel=2'b11;
                    next_state<=STOP_STATE;
                end 
        end
    PARITY_STATE:
        begin
            start_bit=1'b1;
            stop_bit=1'b0;
            busy=1'b1;
            ser_en=1'b0;
            mux_sel=2'b10;
            next_state<=STOP_STATE;
        end
    STOP_STATE:
        begin
             start_bit=1'b1;
             stop_bit=1'b1;
             busy=1'b1;
             ser_en=1'b0;
             mux_sel=2'b11;
             if(!Data_Valid)
                next_state<=IDLE_STATE;
            else
                next_state<=START_STATE;
        end
    default:
        begin
                start_bit=1'b1;
                stop_bit=1'b0;
                ser_en=1'b0;
                busy=1'b0;
                mux_sel=2'b00;
                next_state<=IDLE_STATE;
        end
    endcase
 end
endmodule
