module RAM ( 	input clk, 
				input write_enable,
				input write_byte_enable,
				input write_half_word_endable,
				input read_byte_enable,
				input read_half_word_endable,
				input [31:0]pc_address,
				input [31:0]data_address,
				input [31:0]write_data,
				output [31:0]pc_read_data,
				output reg [31:0]data_read_data );
				 
	reg [7:0] mem[498:0];
	integer i;
	initial begin
		for ( i=0; i<4096; i=i+1 ) begin
			mem[i] = 255;
		end
		
		$readmemb ("PATH_TO_BINARY_COMMANDS", mem);
		
		/*mem[0] = 8'b10100100; //b00001100 b10000000 b00000000 b10100100
		mem[1] = 8'b00000000;
		mem[2] = 8'b10000000;
		mem[3] = 8'b00001100;
		
		mem[4] = 8'b00100100; //b00001100 b11000000 b00000001 b00100100
		mem[5] = 8'b00000001;
		mem[6] = 8'b11000000;
		mem[7] = 8'b00001100;
		
		mem[8]  = 8'b10100100; //b00001101 b00000000 b00000001 b10100100
		mem[9]  = 8'b00000001;
		mem[10] = 8'b00000000;
		mem[11] = 8'b00001101;
		
		mem[12] = 8'b00100100; //b00001101 b01000000 b00000010 b00100100
		mem[13] = 8'b00000010;
		mem[14] = 8'b01000000;
		mem[15] = 8'b00001101;
		
		mem[16] = 8'b10000000; //b00000000 b00010000 b10000000 b10000000
		mem[17] = 8'b10000000;
		mem[18] = 8'b00010000;
		mem[19] = 8'b00000000;
		
		mem[20] = 8'b00101010; //b11111110 b00010000 b10000110 b00101010
		mem[21] = 8'b10000110;  //1111111 01100
		mem[22] = 8'b00010000;
		mem[23] = 8'b11111110;*/
		
		/*mem[100] = 1; mem[101] = 0; mem[102] = 0; mem[103] = 0;
		mem[104] = 4; mem[105] = 0; mem[106] = 0; mem[107] = 0;
		mem[108] = 12; mem[109] = 65; mem[110] = 255; mem[111] = 66;
		mem[212] = 16; mem[213] = 0; mem[214] = 0; mem[215] = 0;*/
		
	end
	
	always@(posedge clk) begin		//	WRITE WORD, HALF WORD OR BYTE DEPENDING ON SIGNAL TO MEM[I] SEQUENTIALY
		if ( write_enable ) begin
			if ( write_byte_enable ) begin
				mem[data_address] <= write_data[7:0];
			end else if ( write_half_word_endable ) begin
				mem[data_address] <= write_data[7:0];
				mem[data_address + 1] <= write_data[15:8];
			end else begin
				mem[data_address] <= write_data[7:0];
				mem[data_address + 1] <= write_data[15:8];
				mem[data_address + 2] <= write_data[23:16];
				mem[data_address + 3] <= write_data[31:24];
			end
		end
	end
	
	always@(posedge clk) begin		//	READ WORD, HALF WORD OR BYTE DEPENDING ON SIGNAL FROM MEM[I] TO OUTPUT SEQUENTIALY
			if ( read_byte_enable ) begin
				data_read_data <= { {24{ mem[data_address][7] }}, mem[data_address][7:0] };
			end else if ( read_half_word_endable ) begin
				data_read_data <= { {16{ mem[data_address][15] }}, mem[data_address][15:0] };
			end else begin
				data_read_data[7:0] <= mem[data_address];
				data_read_data[15:8] <= mem[data_address + 1];
				data_read_data[23:16] <= mem[data_address + 2];
				data_read_data[31:24] <= mem[data_address + 3];
			end
	end
	
	assign pc_read_data[7:0] = mem[pc_address];		//	PC INSTRUCTIONS ARE PASSED WHOLE (WORD) COMBINATIONALLY
	assign pc_read_data[15:8] = mem[pc_address + 1];
	assign pc_read_data[23:16] = mem[pc_address + 2];
	assign pc_read_data[31:24] = mem[pc_address + 3];
	
endmodule