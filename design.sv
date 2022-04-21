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


module get_sign(A, B, sign); // this is to get the sign of the output
  input A, B;
  output sign;

  xor(sign,A,B);
endmodule

module division (i_divisor, i_dividend, result, expo, expA, expB);
  //reg [23:0];
  input wire [7:0] expA, expB;
  input [31:0]i_dividend, i_divisor;
  reg [23:0]quotient=0;
  reg [7:0]exponent_diff = 8'd0;
  output reg [7:0]expo=0;
  reg first_bit = 1'b0;
  reg done = 1'b0;
  output reg [22:0]result=0;
  reg [32:0] dividend=0, divisor=0;
  integer i;
  reg[1:0] stateA, next_stateA, stateB, next_stateB;
  
  
  always @ ( i_divisor, i_dividend, expA, expB) begin 
    dividend = i_dividend;
    divisor = i_divisor;
    done = 0;
    quotient=0;
    exponent_diff = 0;
    first_bit = 0;
    stateA=0;
    stateB=0;
    next_stateA=0;
    next_stateB=0;
        
    
    
    
    if (divisor[31:0] == 32'b0 && expB[7:0] == 8'b0 && done == 1'b0) begin
      done = 1'b1;
      result = 23'b0;
      expo = 8'b0;
    end
    if (dividend[31:0] == 32'b0 && expA[7:0] == 8'b0 && done == 1'b0) begin
      result = 23'b0;
      expo = 8'b0;
      done = 1'b1;
    end
    if(done == 1'b0) begin
      
      for(i=0; i<32; i=i+1) begin
      stateA=next_stateA;
      case (stateA)
      0: next_stateA=1;
      1: begin
      
      if (quotient[23] != 1'b1) begin
        next_stateA=1;
        if (dividend >= divisor) begin
          dividend = dividend - divisor;    // here we just subtract the divisor from the dividend and shift the dividend left.
          dividend = dividend << 1;
          quotient = {quotient[22:0], 1'b1}; // this is to shift the quotient left and add 1 to the lsb.
          if (first_bit == 1'b0) begin
            first_bit = 1'b1;
          end
        end else begin
          dividend = dividend << 1;
          quotient = {quotient[22:0], 1'b0};
          if (first_bit == 1'b0) begin             //until we get the first bit i.e. the first time the divisor is less than the dividend the exponent value will decrease
            exponent_diff = exponent_diff + 1;
          end
        end
        end
      else
            next_stateA=2;
      end    
      2: next_stateA=2;
      default: next_stateA=0;
      endcase      
      end

        
        if (dividend[31:0] == 32'b0 && done == 1'b0) begin
        for(i=0; i<32; i=i+1) begin
        stateB=next_stateB;
        case (stateB)
        0: next_stateB=1;
        1: begin
        
          if (quotient[23] != 1'b1) begin
            next_stateB=1;
            quotient = quotient << 1;
            if(first_bit == 1'b0) begin           // if we haven got a first_bit by now give output 0.
              result = 23'b0;
              expo = 8'b0;
              done = 1'b1;
              //break;
            end
          end
          
          else
              next_stateB=2;
          end    
          2: next_stateB=2;
          default: next_stateB=0;
          endcase      
         end
          
          
        end
      
      
      
      end
      
      if (done == 1'b0) begin
        expo = expA - expB +8'd127;
        //get_exp exp_out (.A(expA), .B(expB), .exp(expo));
        expo = expo - exponent_diff;
        if (expo[7] == 0 && expA >= 128 && expB < 128) begin
          done = 1'b1;
        end else if (expo[7] == 1 && expA < 128 && expB >= 128) begin
          done = 1'b1;
        end
        if (quotient[23] == 1) begin
          result = quotient[22:0];
          done = 1'b1;
        end
      end
    end
  


endmodule // division

//This module is the main module where all the sub modules will be included

module fpdiv(AbyB, InputA, InputB);
input [31:0] InputA, InputB;
output [31:0] AbyB;
wire [7:0]  expAbyB;
wire [22:0]  mantAbyB;
wire  signAbyB;
wire [32:0] temp_divisor, temp_dividend;
wire case0, casePinf, caseNinf, caseNaN;

// Special Case if B=0 & A is any positive number; (answer=+inf)
  assign casePinf = (InputB==32'h00000000 && InputA[31]==0) ? 1 : 0;
         
// Special Case if B=0 & A is any negative number; (answer=-inf)
  assign caseNinf = (InputB==32'h00000000 & InputA[31]==1) ? 1 : 0;

// Special Case if B=0 & A=0; (answer=NaN)
  assign caseNaN = (InputB[30:0]==0 & InputA[30:0]==0) ? 1 : 0;

// Special Case if B=+inf & A is any positive number; (answer=+0.0)
// Special Case if B=-inf & A is any negative number; (answer=0.0)
// Special Case if A=0; (answer=0.0)
  
  assign case0 = (InputA==32'h0) | (InputA==32'h80000000) | (InputB==32'h7F800000) | (InputB==32'hFF800000) ? 1 : 0;




assign temp_divisor = {1'b1,InputB[23:0],7'd0};
assign temp_dividend = {1'b1,InputA[23:0],7'd0};
get_sign s_out (.A(InputA[31]), .B(InputB[31]), .sign(signAbyB));
division divide (.i_divisor({1'b1,InputB[22:0],8'd0}), 
                 .i_dividend({1'b1,InputA[22:0],8'd0}), 
                 .result(mantAbyB), 
                 .expo(expAbyB), 
                 .expA(InputA[30:23]), .expB(InputB[30:23]));
                 
                    // ZERO = 32'h0;
                    // Pinf = 32'h7F800000
                    // Ninf = 32'hFF800000
                    // NaN = 32'hFFFFFFFFF
                 
                 // GENERAL CASE
assign AbyB = case0 ? 0 :  casePinf ? 32'h7F800000 : caseNinf ? 32'hFF800000 : caseNaN ? 32'h7FFFFFF0 :  {signAbyB,expAbyB,mantAbyB};

//assign AbyB = {signAbyB,expAbyB,mantAbyB};

endmodule
