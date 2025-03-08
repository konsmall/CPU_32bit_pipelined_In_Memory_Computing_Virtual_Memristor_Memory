`include "defines.v"
`include "DATA_PATH.v"

module CPU_32bit_pipeline_TB ( output [31:0]bit_data_sel_1,
							output [31:0]bit_data_sel_2,
							output [31:0]control,
							output [31:0]word,
							output read_or_gate,
							output and_gate, 
							output xor_gate,
							output inv_gate,
							input [31:0]data );
	reg CLK;
	reg [31:0] COUNTER;
	
	wire [31:0]TOP_OUT_DATA_SEL_1;
	wire [31:0]TOP_OUT_DATA_SEL_2;
	wire [31:0]TOP_CONTROL;
	wire [31:0]TOP_WORD;
	wire TOP_READ_OR_GATE;
	wire TOP_AND_GATE; 
	wire TOP_XOR_GATE;
	wire TOP_INV_GATE;
	wire [31:0]TOP_DATA;
	
	initial 
   begin
	    $dumpfile("VCD_FILE.vcd");
		$dumpvars(0, CPU_32bit_pipeline_TB);
		COUNTER <= -1;
		CLK <= 1;
     #250000;
		$finish;
   end
	
	always 
	begin
		#2.5 CLK = ~CLK;
	end
	
	always@(posedge CLK) begin
		COUNTER <= COUNTER + 1;
	end
	
	
	assign bit_data_sel_1 = TOP_OUT_DATA_SEL_1;
	assign bit_data_sel_2 = TOP_OUT_DATA_SEL_2;
	assign control = TOP_CONTROL;
	assign word = TOP_WORD;
	assign read_or_gate = TOP_READ_OR_GATE;
	assign and_gate = TOP_AND_GATE;
	assign xor_gate = TOP_XOR_GATE;
	assign inv_gate = TOP_INV_GATE;
	assign data = TOP_DATA;
	
	
	DATA_PATH dt_pth_1( .clk( CLK ),
						.bit_data_sel_1( TOP_OUT_DATA_SEL_1 ),
						.bit_data_sel_2( TOP_OUT_DATA_SEL_2 ),
						.control( TOP_CONTROL ),
						.word( TOP_WORD ),
						.read_or_gate( TOP_READ_OR_GATE ),
						.and_gate( TOP_AND_GATE ), 
						.xor_gate( TOP_XOR_GATE ),
						.inv_gate( TOP_INV_GATE ),
						.data( TOP_DATA ) );
endmodule



