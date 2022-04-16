`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2022 05:13:45 PM
// Design Name: 
// Module Name: FP_Div_Test
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

module booth_test;

reg [31:0] A, B;
wire DONE;
wire [31:0] result;
shortreal value; 
shortreal valueA, valueB;
real EPSILON=0.00001;
real error;  
  
integer i, fail=0, pass=0, Spass=0, Sfail=0;
  division tester( A, B, result);


initial  
begin

// CORNER CASES 0/1
A = 32'h0;  // 0.0
B = 32'h1;  // 1.0
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);


// CORNER CASES 1/0
A = 32'h3F800000;  	// 1.0
B = 32'h0;  		// 0.0
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);


// CORNER CASES 0/0
A = 32'h0;  	// 1.0
B = 32'h0;  		// 0.0
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);


  
// CORNER CASES 1/inf
A = 32'h3F800000;  	// 1.0
B = 32'h7F800000; 
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);
  
  


// GENRAL CASES
  for(i =0 ; i < 500; i=i+1) begin
#100
  valueA = $random;
  valueB = $random;
  A =$shortrealtobits(valueA);
  B =$shortrealtobits(valueB);
  #15
  value =$bitstoshortreal(result);
  error = (value - (valueA/valueB));
  error = error * error;
  
  
    if( error < EPSILON ) begin
   
    $display("Passed for A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);
  	pass = pass + 1;
    end

  else begin
    $display("Failed for A = %f and B = %f, expected : %f got : %f",valueA,valueB,valueA/valueB,value);
  	fail = fail + 1;
end
end	
  $display("No. of Passes = %f and No. of Fails = %f",pass,fail);
	
end


endmodule
