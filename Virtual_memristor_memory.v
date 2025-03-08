module MEM_CONTROLLER_V3 ( input clk,
						input [31:0]instruction,
						input [31:0]in_data,
						input [31:0]in_buffer_data,
						output reg [31:0]out_data_sel_1,
						output reg [31:0]out_data_sel_2,
						output reg [31:0]control,
						output reg [31:0]word,
						output reg read_or_gate,
						output reg and_gate, 
						output reg xor_gate,
						output reg inv_gate,
						output reg STALL );
	
	integer i;
	
	reg [31:0]reg_instruction;
	reg [31:0]reg_in_data;
	reg ONE_STEP_GATE_PROC;
	
	
	initial begin
		reg_instruction <= 0;
		reg_in_data <= 0;
	
		ONE_STEP_GATE_PROC <=0;
		
		out_data_sel_1 <=0;
		out_data_sel_2 <=0;
		control <=0;
		word <=0;
		read_or_gate <=0;
		and_gate <=0;
		xor_gate <=0;
	end
	
	always @(posedge clk) begin
		if ( !STALL ) begin
			reg_instruction <= instruction;
			reg_in_data <= in_data;
		end
	end
	
	
	wire [6:0]opcode = reg_instruction[6:0];
	wire [2:0]mem_address_RD = reg_instruction[11:7];
	wire [2:0]mem_address_RS1 = reg_instruction[19:15];
	wire [2:0]mem_address_RS2 = reg_instruction[24:20];
	wire [11:0]imm12_I = reg_instruction[31:20];
	wire [11:0]imm12_S = { reg_instruction[31:25], reg_instruction[11:7] };
	reg return_mem_gate_result_to_mem;
	
	
	always @(*) begin		//	SIGNAL THAT SHOWS THAT THE RESULT OF A MEMRISTOR GATE WILL BE WRITTEN BACK IN TO THE MEMRISTOR MEMORY
		return_mem_gate_result_to_mem = 0;
	
		if ( opcode >= `MORM && opcode <= `MXNORM ) 
			return_mem_gate_result_to_mem = 1;
	end
	
	
	always @(*) begin		//	STALL
		STALL = 0;
	
		if ( return_mem_gate_result_to_mem == 1 && ONE_STEP_GATE_PROC != 1 ) 
			STALL = 1;
	end
	
	
	always @ (posedge clk) begin // STEP 
		if ( return_mem_gate_result_to_mem == 1 && ONE_STEP_GATE_PROC == 0 )  begin
			ONE_STEP_GATE_PROC <= 1;
			//buffer <= in_buffer_data; //$urandom_range(255,0);
		end else if ( ONE_STEP_GATE_PROC == 1 ) begin
			ONE_STEP_GATE_PROC <= 0;
			//buffer <= in_buffer_data;
		end
	end
	
	always @(*) begin // CONTROL signal
		control = 0;
		
		if ( opcode == `MLW ) begin
			control[ mem_address_RS1 ] = 1;
		end else if ( opcode == `MSW ) begin
			control[ imm12_S[4:0] ] = 1;
		end
		
		if ( ( opcode >= `MOR && opcode <= `MXNORM ) && ONE_STEP_GATE_PROC == 0 ) begin
			control[ mem_address_RS1 ] = 1;
			control[ mem_address_RS2 ] = 1;
		end else if ( ONE_STEP_GATE_PROC == 1 ) begin
			control[ mem_address_RD ] = 1;
		end
	end
	
	always @ (*) begin // WORD signal
		word = 0; // DEFAULT WORD signal
		
		if ( opcode == `MLW ) begin // READ WORD changes to '1' if performing read or a gate
			word[ mem_address_RS1 ] = 1;
		end
		
		if ( ( opcode >= `MOR && opcode <= `MXNORM ) && ONE_STEP_GATE_PROC != 1 ) begin // GATE WORD changes to '1' if performing read or a gate
			word[ mem_address_RS1 ] = 1;
			word[ mem_address_RS2 ] = 1;
		end
	end
	
	always @ (*) begin // OUT DATA signal
		out_data_sel_1 = 0;
		out_data_sel_2 = 0;
		
		if ( opcode == `MSW || ONE_STEP_GATE_PROC == 1 ) begin // passing elements normally
			out_data_sel_2 = { 32{ 1'b1 }};
			for ( i = 0; i < 31; i = i+1 ) begin
				if ( opcode == `MSW && reg_in_data[i] == 1 ) out_data_sel_1[i] = 1;
				if ( ONE_STEP_GATE_PROC == 1 && in_buffer_data[i] == 1 ) out_data_sel_1[i] = 1;
			end
		end
	end
	
	always @ (*) begin // READ OR AND XOR signal
		read_or_gate = 0;
		and_gate = 0;
		xor_gate = 0;
		inv_gate = 0;
		
		if ( (opcode == `MLW || opcode == `MOR || opcode == `MNOR || opcode == `MORM || opcode == `MNORM ) && ONE_STEP_GATE_PROC == 0 ) begin //PLACEHOLDER READ / OR
			read_or_gate = 1;
			if ( opcode == `MNOR || opcode == `MNORM ) inv_gate = 1;
		end
		
		if ( ( opcode == `MAND || opcode == `MNAND || opcode == `MANDM || opcode == `MNANDM ) && ONE_STEP_GATE_PROC == 0 ) begin //PLACEHOLDER AND
			read_or_gate = 1;
			and_gate = 1;
			if ( opcode == `MNAND || opcode == `MNANDM ) inv_gate = 1;
		end
		
		if ( ( opcode == `MXOR || opcode == `MXNOR || opcode == `MXORM || opcode == `MXNORM ) && ONE_STEP_GATE_PROC == 0 ) begin //PLACEHOLDER XOR
			xor_gate = 1;
			if ( opcode == `MXNOR || opcode == `MXNORM ) inv_gate = 1;
		end
	end
		 
endmodule



module VIRTUAL_REMEM ( 	input clk,
						input [31:0]bit_data_sel_1,
						input [31:0]bit_data_sel_2,
						input [31:0]control,
						input [31:0]word,
						input read_or_gate,
						input and_gate, 
						input xor_gate,
						input inv_gate,
						output reg [31:0]data	);
	
	integer i;
	integer j;
	
	reg [31:0] mem[31:0];
	reg wrd_flg;
	reg [31:0] word_1;
	reg [31:0] word_2;
	
	initial begin
		for ( i=0; i<8; i=i+1 ) begin
			mem[i] <= 0;
		end
		wrd_flg = 0;
	end
	
	always @ (posedge clk) begin
		if ( bit_data_sel_2 == { 32{ 1'b1 }} ) begin
			for ( i=0; i<31; i=i+1 ) begin
				if ( control[i] == 1 && word[i] == 0 ) begin
					for ( j=0; j<31; j=j+1 ) begin					
						if ( bit_data_sel_1[j] == 1 ) mem[i][j] <= 1;
						else mem[i][j] <= 0;
					end
				end
			end
		end
	end
	
	always @(*) begin
		word_1 = 0;
		word_2 = 0;
	
		if ( bit_data_sel_2 == 0 ) begin
			for ( i=0; i<31; i=i+1 ) begin
				if ( control[i] == 1 && word[i] == 1 ) begin
					if ( wrd_flg == 0 ) begin
						word_1 = mem[i];
						wrd_flg = 1;
					end else begin
						word_2 = mem[i];
						wrd_flg = 0;
					end
				end
			end
		end
		
		wrd_flg = 0;
	end
	
	always @(posedge clk) begin
		data = 0;
	
		if ( read_or_gate && !and_gate ) begin
			data <= word_1 | word_2;
		end else if ( read_or_gate && and_gate ) begin
			data <= word_1 & word_2;
		end else if ( xor_gate ) begin
			data <= word_1 ^ word_2;
		end
		
		if ( inv_gate ) data = ~ data;
	end
	
	wire [31:0]wr0; wire [31:0]wr1; wire [31:0]wr2; wire [31:0]wr3; wire [31:0]wr4; wire [31:0]wr5; wire [31:0]wr6; wire [31:0]wr7;
	assign wr0 = mem[0];
	assign wr1 = mem[1];
	assign wr2 = mem[2];
	assign wr3 = mem[3];
	assign wr4 = mem[4];
	assign wr5 = mem[5];
	assign wr6 = mem[6];
	assign wr7 = mem[7];
	
endmodule