module ALU ( 	input [4:0]alu_control,
				input signed [31:0]input_A,
				input signed [31:0]input_B,
				output zero,
				output equal,
				output not_equal,
				output greater_equal_than,
				output less_than,
				output reg [31:0] result );
				 
	wire unsigned [31:0] unsigned_input_A = input_A;
	wire unsigned [31:0] unsigned_input_B = input_B;
	
				 
	always @(*) begin
		result = 0;
	
		case( alu_control )
			`ADD, `ADDI, `AUIP: result = input_A + input_B; // add //add `LUI
			`SUB, `SUBI: result = input_A - input_B; // sub
			`MUL, `MULI: result = input_A * input_B; // mul
			`DIV, `DIVI: result = input_A / input_B; // div
			`SLL, `SLLI, `LUI: result = input_A << input_B; //shift left logical
			`SRL, `SRLI: result = input_A >> input_B; //shift right logical
			`SRA, `SRAI: result = input_A >>> input_B; //shift right arithmetic
			`OR, `ORI: result = input_A | input_B; // or
			`AND, `ANDI: result = input_A & input_B; // and
			`XOR, `XORI: result = input_A ^ input_B; // xor
			`NOT, `NOTI: result = ~ input_A; // not
			`SLT, `SLTI: result = (input_A < input_B) ? 32'd1 : 32'd0 ; // set less than
			
			default : result = 0; // NULL result
		endcase
	end
			
	assign zero = ( result == 0 )? 1'b1: 1'b0;
	assign equal = ( input_A == input_B )? 1'b1: 1'b0;
	assign not_equal = ( input_A != input_B )? 1'b1: 1'b0;
	assign greater_equal_than = ( input_A >= input_B )? 1'b1: 1'b0;
	assign less_than = ( input_A < input_B )? 1'b1: 1'b0;
		
endmodule