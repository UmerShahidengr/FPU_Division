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
  fpdiv tester( result, A, B);


initial  
begin
/*
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
A = 32'h0;  	// 0.0
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
  
*/
  
  
  
// SPECIAL TEST PATTERNS
// CORNER CASES +inf/negative
A = 32'h7F800000;  // +inf
B = 32'h85634992;  // any negative
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : -inf got : %f",valueA,valueB,value);

  
// CORNER CASES 0.0/something
A = 32'h0;  		// zero
B = 32'h85634992;  // something
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

  
// CORNER CASES inf/zero
A = 32'h7F800000;  	// +inf
B = 32'h0;  		// 0.0
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : inf, got : %f",valueA,valueB,value);


// CORNER CASES NaN/something
A = 32'h7FC00000;  		// NaN
B = 32'h85634993;  // something
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : nan, got : %f",valueA,valueB,value);

  
// CORNER CASES subnormal/subnormal
A = 32'h00005109;  		// subnormal
B = 32'h80034093;  		// subnormal
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);
  
// CORNER CASES subnormal/normal
A = 32'h80004093;  		// subnormal
B = 32'h85634993;  		// normal
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

  
 // CORNER CASES normal/subnormal
A = 32'h83490200;  		// normal
B = 32'h80000093;  		// subnormal
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

  
   // CORNER CASES subnormal/normal
A = 32'h00004101;  		// subnormal
B = 32'h82340093;  		// normal
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);
  
  
   // CORNER CASES
A = 32'h17810000;  		// corner
B = 32'h622C0000;  		// corner
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);
  
    
   // CORNER CASES 
A = 32'h9FDD5C3E;  		// corner
B = 32'h6A648040;  		// corner
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

  
   // CORNER CASES 
A = 32'h958E8000;  		// corner
B = 32'hE0400000;  		// corner
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

    
   // CORNER CASES
A = 32'h90000000;  		// corner
B = 32'h4E90001F;  		// corner
#15
value =$bitstoshortreal(result);
valueA = $bitstoshortreal(A);
valueB = $bitstoshortreal(B);
  $display("Special Case For A = %f and B = %f, expected : %f, got : %f",valueA,valueB,valueA/valueB,value);

  /*
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
  error = error<0 ? -error : error;
  
  
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
*/	
end


endmodule
