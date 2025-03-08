`include "ALU.v"
`include "RAM.v"
`include "Registers.v"
`include "JUMP_CONTROL.v"
`include "Virtual_memristor_memory.v"


module DATA_PATH ( 	input clk,
					output [31:0]bit_data_sel_1,
					output [31:0]bit_data_sel_2,
					output [31:0]control,
					output [31:0]word,
					output read_or_gate,
					output and_gate, 
					output xor_gate,
					output inv_gate,
					inout [31:0]data );

	reg [31:0]PC;
	wire[31:0]PC_INSTRUCTION;
	wire PC_JUMP_ENABLE;
	wire [31:0]PC_JUMP_DESTINATION;
	reg [31:0]D_PC;
	reg [31:0]E_PC;
	
	reg [31:0]IR_D;
	reg [31:0]IR_E;
	reg [31:0]IR_M;
	reg [31:0]IR_W;
	reg [6:0]D_OC;
	reg [6:0]E_OC;
	reg [6:0]M_OC;
	reg [6:0]W_OC;
	reg [31:0]D;
	reg [31:0]E_REG_1;
	reg [31:0]E_REG_2;
	reg [31:0]E_MEM_ADDRESS;
	reg [31:0]M_ALU_RESULT;
	reg [31:0]M_REG_1;
	reg [31:0]M_MEM_ADDRESS;
	reg [31:0]W_ALU_RESULT;
	reg [31:0]W_TO_REG_DATA;
	reg STALL;
	reg [7:0]STALL_COUNT;
	reg [7:0]STALL_COUNT_MAX;
	reg [7:0]STALL_JUNK_SEL;
	
	reg reg_write_enable;
	reg [4:0]reg_write_address;
	reg [31:0]reg_write_data;
	reg [4:0]reg_address_1;
	wire [31:0]reg_data_1;
	reg [4:0]reg_address_2;
	wire [31:0]reg_data_2;
	reg REG_WRITE_BYTE_ENABLE;
	reg REG_WRITE_HALF_WORD_ENABLE;
	reg REG_READ_BYTE_ENABLE;
	reg REG_READ_HALF_WORD_ENABLE;
	
	reg[31:0] D_RAM_ADDRESS;
	
	reg[31:0] ALU_A;
	reg[31:0] ALU_B;
	wire[31:0] ALU_RESULT;
	reg[4:0] ALU_CONTROL;
	wire ALU_EQUAL;
	wire ALU_NOT_EQUAL;
	wire ALU_GREATER_EQUAL_THAN;
	wire ALU_LESS_THAN;
	
	reg[31:0]RAM_ADDRESS;
	reg[31:0]RAM_WRITE_DATA;
	wire[31:0]RAM_READ_DATA;
	reg RAM_WRITE_ENABLE;
	reg RAM_OR_ALU_DATA_TO_REG_SEL;
	reg RAM_WRITE_BYTE_ENABLE;
	reg RAM_WRITE_HALF_WORD_ENABLE;
	reg RAM_READ_BYTE_ENABLE;
	reg RAM_READ_HALF_WORD_ENABLE;
	
	wire [31:0]REMEM_OUT_DATA_SEL_1;
	wire [31:0]REMEM_OUT_DATA_SEL_2;
	wire [31:0]REMEM_CONTROL;
	wire [31:0]REMEM_WORD;
	wire [31:0]REMEM_DATA;
	wire REMEM_READ_OR_GATE;
	wire REMEM_AND_GATE; 
	wire REMEM_XOR_GATE;
	wire REMEM_INV_GATE;
	wire REMEM_STALL;
	reg REMEM_DATA_TO_REG_SEL;
	
	always @ ( * ) begin // assign opcodes of each stat to different reg fot easier reading
		D_OC = IR_D[6:0];
		E_OC = IR_E[6:0];
		M_OC = IR_M[6:0];
		W_OC = IR_W[6:0];
	end
	
	
	
	wire [4:0]D_R1 = IR_D[19:15];		//	DEBUG PERPUSES ONLY! DELETE LATER
	wire [4:0]D_R2 = IR_D[24:20];
	wire [4:0]E_TRG = IR_E[11:7];
	wire [4:0]M_TRG = IR_M[11:7];
	wire [4:0]W_TRG = IR_W[11:7];
	wire [11:0]S_imm12 = {IR_D[31:25], IR_D[11:7]};
	
	initial begin
		STALL = 0;
		STALL_COUNT = 0;
		STALL_COUNT_MAX = 0;
	end
	always @ (posedge clk) begin
		if ( STALL == 1 && STALL_COUNT < 3 )
			STALL_COUNT = STALL_COUNT + 1;
		else 
			STALL_COUNT = 0;
	end
	always @(*) begin
		STALL <= 0;
		STALL_COUNT_MAX <= 0;
	
		if ( ( E_OC >= `ADD && E_OC <= `LB || (E_OC >= `MOR && E_OC <= `MXNOR) ) || ( (M_OC >= `ADD && M_OC <=`LB) || (M_OC >= `MOR && M_OC <= `MXNOR) ) || ( (W_OC >= `ADD && W_OC <=`LB) || (W_OC >= `MOR && W_OC <= `MXNOR) )  ) begin
			if ( (D_OC>=`ADD&&D_OC<=`SLT) || (D_OC>=`OR&&D_OC<=`NOT) || (D_OC>=`SLL&&D_OC<=`SRA) || (D_OC>=`BEQ&&D_OC<=`BLTU) || D_OC==`SLTU || D_OC==`ADDW || D_OC==`SUBW || D_OC==`MULW || D_OC==`DIVW || (D_OC>=`BEQ&&D_OC<=`BLTU) ) begin
				if ( (IR_D[19:15]==IR_E[11:7] || IR_D[19:15]==IR_M[11:7] || IR_D[19:15]==IR_W[11:7]) || (IR_D[24:20]==IR_E[11:7] || IR_D[24:20]==IR_M[11:7] || IR_D[24:20]==IR_W[11:7]) ) begin
					STALL <= 1;
					STALL_COUNT_MAX <= 1;
				end
			end
			else if ( ( D_OC >= `SLLI && D_OC <= `LB ) || ( D_OC >= `ANDI && D_OC <= `NOTI ) || ( D_OC >= `ADDI && D_OC <= `DIVI ) || D_OC==`ADDIW || D_OC==`SUBIW || D_OC==`MULIW || D_OC==`DIVIW || D_OC==`SLTI || D_OC==`SLTUI || D_OC==`JALR  ) begin
				if ( IR_D[19:15]==IR_E[11:7] || IR_D[19:15]==IR_M[11:7] || IR_D[19:15]==IR_W[11:7] ) begin
					STALL <= 1;
					STALL_COUNT_MAX <= 2;
				end
			end
		end
		
		if ( (D_OC>=`SW&&D_OC<=`SB) || D_OC==`MSW ) begin
			if ( (E_OC>=`ADD&&E_OC<=`LB && (IR_D[19:15]==IR_E[11:7] || IR_D[24:20]==IR_E[11:7])) ) begin
				STALL <= 1;
				STALL_COUNT_MAX <= 3;
			end else if ( (M_OC>=`ADD&&M_OC<=`LB && (IR_D[19:15]==IR_M[11:7] || IR_D[24:20]==IR_M[11:7])) ) begin
				STALL <= 1;
				STALL_COUNT_MAX <= 4;
			end else if ( (W_OC>=`ADD&&W_OC<=`LB && (IR_D[19:15]==IR_W[11:7] || IR_D[24:20]==IR_W[11:7])) ) begin
				STALL <= 1;
				STALL_COUNT_MAX <= 5;
			end
		end
		
		if ( REMEM_STALL ) begin // <-- NEEDS WORK
			if ( E_OC >= `MLW && E_OC <= `MXNORM ) begin
				STALL <= 1;
			end
		end
		
		if ( STALL_COUNT == 3 && REMEM_STALL == 0 )
			STALL <= 0;
	end
	
	
	
	
	
	initial begin // PC SEGMENT
		PC <= -4;
		D_PC <= 0;
		E_PC <= 0;
	end
	always @ (posedge clk) begin
		if ( !STALL ) begin
			PC <= PC + 4;
			D_PC <= PC;
			E_PC <= D_PC;
		end
		
		
		if ( PC_JUMP_ENABLE ) begin
			PC <= PC_JUMP_DESTINATION;
			D_PC <= 0;
			E_PC <= 0;
		end
	end
	
	
	
	always @ ( * ) begin
		STALL_JUNK_SEL = 0;
		
		if ( STALL == 1 && STALL_COUNT == 2 ) begin
			STALL_JUNK_SEL = 3;
		end else if ( STALL == 0 && STALL_COUNT == 2 ) begin
			STALL_JUNK_SEL = 2;
		end else if ( STALL == 0 && STALL_COUNT == 1 ) begin
			STALL_JUNK_SEL = 1;
		end 
	end
	
	always @ (posedge clk) begin
		if ( !STALL ) begin
			IR_E <= IR_D;
			IR_D <= PC_INSTRUCTION;
		end
		IR_M <= IR_E;
		IR_W <= IR_M;
		
		
		if ( PC_JUMP_ENABLE ) begin
			IR_D <= -1;
			IR_E <= -1;
			//IR_M <= -1;
		end
		
		if ( STALL_JUNK_SEL == 3 ) begin
			IR_E <= -1;
			IR_M <= -1;
			IR_W <= -1;
		end else if ( STALL_JUNK_SEL == 2 ) begin
			IR_M <= -1;
			IR_W <= -1;
		end
		if ( STALL_JUNK_SEL == 1 ) begin
			IR_M <= -1;
		end 
	end
	
	
	always @ (posedge clk) begin //E STAGE
		if ( !STALL ) begin
			E_REG_1 <= reg_data_1;
			E_REG_2 <= reg_data_2;
			E_MEM_ADDRESS <= D_RAM_ADDRESS;
		end
	end
	
	always @ (posedge clk) begin //M STAGE
		M_ALU_RESULT <= ALU_RESULT;
		M_REG_1 <= E_REG_1;  //RAM DATA
		M_MEM_ADDRESS <= E_MEM_ADDRESS;  //RAM ADDRESS
	end
	
	always @ (posedge clk) begin //W STAGE
		W_ALU_RESULT <= M_ALU_RESULT;
	end
	
	
	
	Registers reg_1(	.clk(clk),
						.write_enable( reg_write_enable ),
						.write_byte_enable( REG_WRITE_BYTE_ENABLE ),
						.write_half_word_endable( REG_WRITE_HALF_WORD_ENABLE ),
						.read_byte_enable( REG_READ_BYTE_ENABLE ),
						.read_half_word_endable( REG_READ_HALF_WORD_ENABLE ),
						.write_address( reg_write_address ),
						.write_data( reg_write_data ),
						.read_address_1( reg_address_1 ),
						.read_data_1( reg_data_1 ),
						.read_address_2( reg_address_2 ),
						.read_data_2( reg_data_2 ) );
	
	RAM ram_1( 	.clk(clk), 
				.write_enable( RAM_WRITE_ENABLE ),
				.write_byte_enable( RAM_WRITE_BYTE_ENABLE ),
				.write_half_word_endable( RAM_WRITE_HALF_WORD_ENABLE ),
				.read_byte_enable( RAM_READ_BYTE_ENABLE ),
				.read_half_word_endable( RAM_READ_HALF_WORD_ENABLE ),
				.pc_address( PC ),
				.data_address( RAM_ADDRESS ),
				.write_data( RAM_WRITE_DATA ),
				.pc_read_data( PC_INSTRUCTION ),
				.data_read_data( RAM_READ_DATA ) );
	
	ALU alu_1( 	.alu_control( ALU_CONTROL ),
				.input_A( ALU_A ),
				.input_B( ALU_B ),
				.zero(  ),
				.equal( ALU_EQUAL ),
				.not_equal( ALU_NOT_EQUAL ),
				.greater_equal_than( ALU_GREATER_EQUAL_THAN ),
				.less_than( ALU_LESS_THAN ),
				.result( ALU_RESULT ) );
				
	JUMP_CONTROL jump_control_1(	.pc_base( E_PC ),
									.e_oc( E_OC ),
									.e_reg_1( E_REG_1 ),
									.pc_offset( IR_E[31:7] ),
									.equal( ALU_EQUAL ),
									.not_equal( ALU_NOT_EQUAL ),
									.greater_equal_than( ALU_GREATER_EQUAL_THAN ), 
									.less_than( ALU_LESS_THAN ), 
									.pc_jump_destination( PC_JUMP_DESTINATION ),
									.pc_jump( PC_JUMP_ENABLE ) );		

	MEM_CONTROLLER_V3 mem_con_1 ( 	.clk(clk),
									.instruction( IR_E ),
									.in_data( E_REG_1 ),
									.in_buffer_data( REMEM_DATA ),
									.out_data_sel_1( REMEM_OUT_DATA_SEL_1 ),
									.out_data_sel_2( REMEM_OUT_DATA_SEL_2 ),
									.control( REMEM_CONTROL ),
									.word (REMEM_WORD ),
									.read_or_gate( REMEM_READ_OR_GATE ),
									.and_gate( REMEM_AND_GATE ), 
									.xor_gate( REMEM_XOR_GATE ),
									.inv_gate( REMEM_INV_GATE ),
									.STALL( REMEM_STALL ) );	

	VIRTUAL_REMEM vir_mem_1	(  	.clk( clk ),
								.bit_data_sel_1( REMEM_OUT_DATA_SEL_1 ),
								.bit_data_sel_2( REMEM_OUT_DATA_SEL_2 ),
								.control( REMEM_CONTROL ),
								.word( REMEM_WORD ),
								.read_or_gate( REMEM_READ_OR_GATE ),
								.and_gate( REMEM_AND_GATE ), 
								.xor_gate( REMEM_XOR_GATE ),
								.inv_gate( REMEM_INV_GATE ),
								.data( REMEM_DATA )	);
	
	assign bit_data_sel_1 = REMEM_OUT_DATA_SEL_1;
	assign bit_data_sel_2 = REMEM_OUT_DATA_SEL_2;
	assign control = REMEM_CONTROL;
	assign word = REMEM_WORD;
	assign read_or_gate = REMEM_READ_OR_GATE;
	assign and_gate = REMEM_AND_GATE;
	assign xor_gate = REMEM_XOR_GATE;
	assign inv_gate = REMEM_INV_GATE;
	assign data = REMEM_DATA;
	
	always @ (*) begin //W TO REGISTER STAGE NO REGISTER CHOOSES BETWEEN ALU< RAM & MEMRAM
		if ( REMEM_DATA_TO_REG_SEL ) begin		//	DATA FROM MEMRISTORS TO W STAGE
			W_TO_REG_DATA <= REMEM_DATA;
		end else if ( RAM_OR_ALU_DATA_TO_REG_SEL ) begin		//	DATA FROM RAM TO W STAGE
			W_TO_REG_DATA <= RAM_READ_DATA;
		end	else begin
			W_TO_REG_DATA <= W_ALU_RESULT;		//	DATA FROM ALUS TO W STAGE
		end
	end
	
	
	
	always @ (*) begin //REGISTER SIGNALS
		reg_write_enable = 0;
		REG_READ_BYTE_ENABLE = 0;
		REG_READ_HALF_WORD_ENABLE = 0;
		REG_WRITE_BYTE_ENABLE = 0;
		REG_WRITE_HALF_WORD_ENABLE = 0;
		
		reg_address_1 = IR_D[19:15];		//	REGISTERS ADDRESS AND DATA
		reg_address_2 = IR_D[24:20];
		reg_write_address = IR_W[11:7];
		reg_write_data = W_TO_REG_DATA;
		
		if ( W_OC == `LB ) REG_WRITE_BYTE_ENABLE = 1; 	//	LOAD TO REG BYTE/HALF WORD ENABLE SIGNAL
		if ( W_OC == `LH ) REG_WRITE_HALF_WORD_ENABLE = 1;
		
		if ( W_OC == `SB ) REG_READ_BYTE_ENABLE = 1; 	//	LOAD FROM REG BYTE/HALF WORD ENABLE SIGNAL
		if ( W_OC == `SH ) REG_READ_HALF_WORD_ENABLE = 1;
		
		if ( ( W_OC >= `ADD && W_OC <= `LB ) || W_OC == `JAL || W_OC == `JALR || W_OC == `MLW || W_OC == `MOR || W_OC == `MAND || W_OC == `MXOR || W_OC == `MNOR || W_OC == `MNAND || W_OC == `MXNOR ) begin
			reg_write_enable = 1;		//	REGISTER WRITE SIGNAL
		end
	end
	
	always @ (*) begin //RAM SIGNALS
		RAM_WRITE_ENABLE = 0;
		RAM_OR_ALU_DATA_TO_REG_SEL = 0;
		RAM_READ_BYTE_ENABLE = 0;
		RAM_READ_HALF_WORD_ENABLE = 0;
		RAM_WRITE_BYTE_ENABLE = 0;
		RAM_WRITE_HALF_WORD_ENABLE = 0;
		
		
		if ( M_OC == `LB ) RAM_READ_BYTE_ENABLE = 1;	//	LOAD FROM RAM BYTE/HALF WORD ENABLE SIGNAL
		if ( M_OC == `LH ) RAM_READ_HALF_WORD_ENABLE = 1;
		
		if ( M_OC == `SB ) RAM_WRITE_BYTE_ENABLE = 1;	//	STORE TO RAM BYTE/HALF WORD ENABLE SIGNAL
		if ( M_OC == `SH ) RAM_WRITE_HALF_WORD_ENABLE = 1;
		
		RAM_ADDRESS = M_MEM_ADDRESS;	//	RAM INPUT SIGNALS
		RAM_WRITE_DATA = M_REG_1;
		
		if ( M_OC == `SW || M_OC == `SH || M_OC == `SB ) begin	//	RAM WRITE ENABLE SIGNAL
			RAM_WRITE_ENABLE = 1;
		end
		
		if ( W_OC == `LW || W_OC == `LH || W_OC == `LB ) begin	//	W PIPELINE STAGE WILL RECIEVE DATA FROM RAM
			RAM_OR_ALU_DATA_TO_REG_SEL = 1;
		end
	end
	
	
	always @ (*) begin //ALU SIGNALS
		ALU_CONTROL = E_OC;
		ALU_A = 0;
		ALU_B = 0;
		
		// R INSTRUCTIONS
		if ( E_OC == `ADD || E_OC == `SUB || E_OC == `DIV || E_OC == `MUL || E_OC == `SLT || E_OC == `OR || E_OC == `AND || E_OC == `XOR || E_OC == `NOT || E_OC == `SRL || E_OC == `SLL || E_OC == `SRA || ( E_OC >= `BEQ && E_OC <= `BLTU ) ) begin
			ALU_A = E_REG_1;
			ALU_B = E_REG_2;
		end // I INSTRUCTIONS
		else if ( E_OC == `ADDI || E_OC == `SUBI || E_OC == `DIVI || E_OC == `MULI || E_OC == `SLTI || E_OC == `ORI || E_OC == `ANDI || E_OC == `XORI || E_OC == `NOTI || E_OC == `SRLI || E_OC == `SLLI || E_OC == `SRAI ) begin
			ALU_A = E_REG_1;
			ALU_B = { {20{IR_E[31]}}, IR_E[31:20] };
		end // U INSTRUCTIONS
		else if ( E_OC == `LUI ) begin
			ALU_A = E_REG_1;
			ALU_B = 12;
		end
		else if ( E_OC == `AUIP ) begin
			ALU_A = E_REG_1 << 12;
			ALU_B = E_PC;
		end //!!! ADD JAL/JALR
		else if ( E_OC == `JAL || E_OC == `JALR ) begin
			ALU_A = 4;
			ALU_B = E_PC;
		end 
	end
	
	
	always @ ( * ) begin 
		D_RAM_ADDRESS = 0;
		
		if ( D_OC >= `LW && D_OC <= `LB ) begin
			D_RAM_ADDRESS =  reg_data_1 + { {20{IR_D[31]}}, IR_D[31:20] };
		end else if ( D_OC >= `SW && D_OC <= `SB ) begin
			D_RAM_ADDRESS =  reg_data_1 + { {20{IR_D[31]}}, IR_D[31:25], IR_D[11:7] };
		end
	end
	
	
	always @ ( * ) begin
		REMEM_DATA_TO_REG_SEL = 0;
	
		if ( W_OC == `MLW || (W_OC >= `MOR && W_OC <= `MXNOR) ) begin
			REMEM_DATA_TO_REG_SEL = 1;
		end
	end
	
	
endmodule
