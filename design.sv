`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 10xEngineers
// Engineer: Umer Shahid
// 
// Create Date: 04/12/2022 09:39:13 PM
// Design Name: Floating Point Division
// Module Name: FP_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module fpdiv(

	  output logic     [31:0] z_value_o,
  	input wire logic [31:0] a_value_i,
    input wire logic [31:0] b_value_i
    

    );

    enum {IDLE, UNPACK, SPECIAL_CASES, NORMALIZE_A, NORMALIZE_B, DIVIDE_0, DIVIDE_1, DIVIDE_2, DIVIDE_3, NORMALIZE_0,
          NORMALIZE_1, ROUND, PACK, DONE} state;
	integer i=0;
    logic        [23:0] a_m, b_m, z_m;
    logic signed [9:0]  a_e, b_e, z_e;
    logic               a_s, b_s, z_s;
  logic        [50:0] quotient=0, divisor=0, dividend=0, remainder=0;
    logic        [5:0]  count;
   
    logic guard=0, round_bit=0, sticky=0;
  always@(a_value_i,b_value_i) begin
    
        state = IDLE;
    	guard=0;
    round_bit=0;
    sticky=0;
    quotient=0;
    divisor=0;
    dividend=0;
    remainder=0;
    count=0; 
     
  for(i=0;i<500;i=i+1) begin

        case (state)
            IDLE: begin
                    state = UNPACK;
            end

            UNPACK: begin
                a_m   = {1'd0, a_value_i[22:0]};
                b_m   = {1'd0, b_value_i[22:0]};
                a_e   = {2'd0, a_value_i[30:23]} - 10'd127;
                b_e   = {2'd0, b_value_i[30:23]} - 10'd127;
                a_s   = a_value_i[31];
                b_s   = b_value_i[31];
                state = SPECIAL_CASES;
            end

            SPECIAL_CASES: begin
                // if a is NaN or b is NaN return NaN
                if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
                    z_value_o[31]    = 1;
                    z_value_o[30:23] = 255;
                    z_value_o[22]    = 1;
                    z_value_o[21:0]  = 0;
                    state            = DONE;
                end
                // if a is inf and b is inf return NaN
                else if (a_e == 128 && b_e == 128) begin
                    z_value_o[31]    = 1;
                    z_value_o[30:23] = 255;
                    z_value_o[22]    = 1;
                    z_value_o[21:0]  = 0;
                    state            = DONE;
                end
                // if a is inf return inf
                else if (a_e == 128) begin
                    z_value_o[31]    = a_s ^ b_s;
                    z_value_o[30:23] = 255;
                    z_value_o[22:0]  = 0;
                    // if b is zero return NaN
                    if ((b_e == -127) && (b_m == 0)) begin
                        z_value_o[31]    = 1;
                        z_value_o[30:23] = 255;
                        z_value_o[22]    = 1;
                        z_value_o[21:0]  = 0;
                    end
                    state = DONE;
                end
                // if b is inf return zero
                else if (b_e == 128) begin
                    z_value_o[31]    = a_s ^ b_s;
                    z_value_o[30:23] = 0;
                    z_value_o[22:0]  = 0;
                    state            = DONE;
                end
                // if a is zero return zero
                else if (a_e == -127 && a_m == 0) begin
                    z_value_o[31]    = a_s ^ b_s;
                    z_value_o[30:23] = 0;
                    z_value_o[22:0]  = 0;
                    // if b is zero return NaN
                    if (b_e == -127 && b_m == 0) begin
                        z_value_o[31]    = 1;
                        z_value_o[30:23] = 255;
                        z_value_o[22]    = 1;
                        z_value_o[21:0]  = 0;                        
                    end
                    state = DONE;
                end
                // if b is zero return inf
                else if (b_e == -127 && b_m == 0) begin
                    z_value_o[31]    = a_s ^ b_s;
                    z_value_o[30:23] = 255;
                    z_value_o[22:0]  = 0;
                    state    = DONE;
                end else begin
                    // denormalized number
                    if (a_e == -127) begin
                        a_e = -126;
                    end else begin
                        a_m[23] = 1;
                    end
                    // denormalized number
                    if (b_e == -127) begin
                        b_e = -126;
                    end else begin
                        b_m[23] = 1;
                    end
                    state = NORMALIZE_A;
                end
            end

            NORMALIZE_A: begin
                if (a_m[23]) begin
                    state = NORMALIZE_B;
                end else begin
                    a_m = a_m << 1;
                    a_e = a_e - 1;
                end
            end

            NORMALIZE_B: begin
                if (b_m[23]) begin
                    state = DIVIDE_0;
                end else begin
                    b_m = b_m << 1;
                    b_e = b_e - 1;
                end
            end

            DIVIDE_0: begin
                z_s       = a_s ^ b_s;
                z_e       = a_e - b_e;
                quotient  = 0;
                remainder = 0;
                count     = 0;
                dividend  = {a_m, 27'd0};
                divisor   = {27'd0, b_m};
                state     = DIVIDE_1;            
            end

            DIVIDE_1: begin
                quotient     = quotient << 1;
                remainder    = remainder << 1;
                remainder[0] = dividend[50];
                dividend     = dividend << 1;
                state        = DIVIDE_2;
            end

            DIVIDE_2: begin
                if (remainder >= divisor) begin
                    quotient[0] = 1;
                    remainder   = remainder - divisor;
                end
                if (count == 49) begin
                    state = DIVIDE_3;
                end else begin
                    count = count + 1;
                    state = DIVIDE_1;
                end
            end

            DIVIDE_3: begin
                z_m       = quotient[26:3];
                guard     = quotient[2];
                round_bit = quotient[1];
                sticky    = quotient[0] | (remainder != 0);
                state     = NORMALIZE_0;
            end

            NORMALIZE_0: begin
                if (z_m[23] == 0 && z_e > -126) begin
                    z_e       = z_e - 1;
                    z_m       = z_m << 1;
                    z_m[0]    = guard;
                    guard     = round_bit;
                    round_bit = 0;
                end else begin
                    state     = NORMALIZE_1;
                end
            end

            NORMALIZE_1: begin
                if (z_e < -126) begin
                    z_e       = z_e + 1;
                    z_m       = z_m >> 1;
                    guard     = z_m[0];
                    round_bit = guard;
                    sticky    = sticky | round_bit;
                end else begin
                    state     = ROUND;
                end
            end

            ROUND: begin
                if (guard && (round_bit | sticky | z_m[0])) begin
                    z_m = z_m + 1;
                    if (z_m == 24'hffffff) begin
                        z_e = z_e + 1;
                    end
                end
                state = PACK;
            end

            PACK: begin
                z_value_o[22:0]  = z_m[22:0];
                z_value_o[30:23] = z_e[7:0] + 127;
                z_value_o[31]    = z_s;
                if (z_e == -126 && z_m[23] == 0) begin
                    z_value_o[30:23] = 0;
                end
                // if overflow occurs, return inf
                if (z_e > 127) begin
                    z_value_o[22:0]  = 0;
                    z_value_o[30:23] = 255;
                    z_value_o[31]    = z_s;
                end
                state = DONE;
            end

            DONE: begin
                state         = DONE;
            end
            default: state = IDLE;
        endcase
       
            end
  end
endmodule

