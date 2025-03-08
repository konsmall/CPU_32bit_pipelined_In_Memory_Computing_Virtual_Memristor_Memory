module Registers ( 	input clk, 
					input write_enable,
					input write_byte_enable,
					input write_half_word_endable,
					input read_byte_enable,
					input read_half_word_endable,
					input [4:0]write_address,
					input [31:0]write_data,
					input [4:0]read_address_1,
					output reg [31:0]read_data_1,
					input [4:0]read_address_2,
					output reg [31:0]read_data_2 );
	
	reg [31:0] mem[31:0];
	integer i;
	initial begin
		for ( i=0; i<31; i=i+1 ) begin
			mem[i] = 0;
		end
	end
	
	always @ ( posedge clk ) begin
		if ( write_enable ) begin		//	WRITE WORD, HALF WORD OR BYTE DEPENDING ON SIGNAL TO REG[I] SEQUENTIALY
			if ( write_byte_enable ) begin
				mem[ write_address ][7:0] <= write_data[7:0];
			end else if ( write_half_word_endable ) begin
				mem[ write_address ][15:0] <= write_data[15:0];
			end else begin
				mem[ write_address ] <= write_data;
			end
		end
		
		mem[0] <= 0; //REGISTER 0 IS ALWAYS 0
	end
	
	always @ ( * ) begin		//	READ WORD, HALF WORD OR BYTE DEPENDING ON SIGNAL TO REG[I] SEQUENTIALY
		read_data_1 = 0;
		read_data_2 = 0;
		
		if ( read_byte_enable ) begin
			read_data_1 = { {24{ mem[ read_address_1 ][7] }}, mem[ read_address_1 ][7:0] };
			read_data_2 = { {24{ mem[ read_address_2 ][7] }}, mem[ read_address_2 ][7:0] };
		end else if ( read_half_word_endable ) begin
			read_data_1 = { {24{ mem[ read_address_1 ][15] }}, mem[ read_address_1 ][15:0] };
			read_data_2 = { {24{ mem[ read_address_2 ][15] }}, mem[ read_address_2 ][15:0] };
		end else begin
			read_data_1 = mem[ read_address_1 ];
			read_data_2 = mem[ read_address_2 ];
		end
	end
	
	
	wire [31:0]reg0; wire [31:0]reg1; wire [31:0]reg2; wire [31:0]reg3;
	wire [31:0]reg4; wire [31:0]reg5; wire [31:0]reg6; wire [31:0]reg7;
	wire [31:0]reg8; wire [31:0]reg9; wire [31:0]reg10; wire [31:0]reg11;
	wire [31:0]reg12; wire [31:0]reg13; wire [31:0]reg14; wire [31:0]reg15;
	wire [31:0]reg16; wire [31:0]reg17; wire [31:0]reg18; wire [31:0]reg19;
	assign reg0 = mem[0]; assign reg1 = mem[1]; assign reg2 = mem[2]; assign reg3 = mem[3];
	assign reg4 = mem[4]; assign reg5 = mem[5]; assign reg6 = mem[6]; assign reg7 = mem[7];
	assign reg8 = mem[8]; assign reg9 = mem[9]; assign reg10 = mem[10]; assign reg11 = mem[11];
	assign reg12 = mem[12]; assign reg13 = mem[13]; assign reg14 = mem[14]; assign reg15 = mem[15];
	assign reg16 = mem[16]; assign reg17 = mem[17]; assign reg18 = mem[18]; assign reg19 = mem[19];
	
endmodule