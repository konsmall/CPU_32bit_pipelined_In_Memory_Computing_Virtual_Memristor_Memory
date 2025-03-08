module JUMP_CONTROL ( 	input [31:0]pc_base,
						input [31:0]e_reg_1,
						input [6:0]e_oc,
						input [24:0]pc_offset,
						input equal,
						input not_equal,
						input greater_equal_than, 
						input less_than, 
						output reg signed [31:0]pc_jump_destination,
						output reg pc_jump );
	
	wire [31:0]imm20;
	wire [31:0]imm12;
	
	assign imm20 = { {12{ pc_offset[24] }}, pc_offset[24:5] };
	assign imm12 = { {20{ pc_offset[24] }}, pc_offset[24:18], pc_offset[4:0] };
	
	always @ ( * ) begin
		pc_jump = 0;
		pc_jump_destination = 0;
	
	
		if ( (e_oc == `BEQ && equal) || (e_oc == `BNE && not_equal) || (e_oc == `BGE && greater_equal_than) || (e_oc == `BGEU && greater_equal_than) || (e_oc == `BLT && less_than) || (e_oc == `BLTU && less_than) ) begin
			pc_jump = 1;
			pc_jump_destination = pc_base + imm12;
		end
		
		if ( e_oc == `JAL ) begin
			pc_jump = 1;
			pc_jump_destination = pc_base + imm20;
		end else if ( e_oc == `JALR ) begin
			pc_jump = 1;
			pc_jump_destination = e_reg_1 + imm12;
		end
	end
	
endmodule