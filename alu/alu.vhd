library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port (	data_operandA, data_operandB 	: 	in std_logic_vector(31 downto 0);
			ctrl_ALUopcode				 	:	in std_logic_vector(2 downto 0);
			data_result						: 	out std_logic_vector(31 downto 0);
			isEqual, isGreaterThan			: 	out std_logic);
end alu;

architecture structure of alu is

component mux8to1
	port (in0, in1, in2, in3, in4, in5, in6, in7: in std_logic_vector(31 downto 0);
		  ctrl  : in std_logic_vector(2 downto 0);
		  output: out std_logic_vector(31 downto 0));		
end component;

component adder
	port (	data_addendA, data_addendB	: in std_logic_vector(31 downto 0);
			ctrl_subtract				: in std_logic;
			data_sum					: out std_logic_vector(31 downto 0);
			data_carryout				: out std_logic);
end component;

component shifter
	port (	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift : in std_logic;
			ctrl_shamt		: in std_logic_vector(4 downto 0);
			data_S	: out std_logic_vector(31 downto 0));
end component;
			
signal ctrl_subtract, ctrl_rightshift : std_logic;			
signal adder_output0, adder_output1 : std_logic_vector(31 downto 0);
signal adder_carry0, adder_carry1	: std_logic;
signal shifter_output: std_logic_vector(31 downto 0);
signal and_output, or_output : std_logic_vector(31 downto 0);
signal mux_dummy_input : std_logic_vector(31 downto 0);
signal equal 	: std_logic;
signal a_xnor_b : std_logic_vector(31 downto 0);

begin

	
	mux_dummy_input <= "00000000000000000000000000000000";
	ctrl_rightshift <= (ctrl_ALUopcode(0) xnor '1') and
					   (ctrl_ALUopcode(1) xnor '0') and
					   (ctrl_ALUopcode(2) xnor '1');
	
	adder0 : adder port map(	data_operandA, data_operandB, '0', adder_output0, adder_carry0);
	adder1 : adder port map(	data_operandA, data_operandB, '1', adder_output1, adder_carry1);
	shifter0 : shifter port map(data_operandA, ctrl_rightshift, data_operandB(4 downto 0), shifter_output);
	mux	   : mux8to1 port map(adder_output0, adder_output1, and_output, or_output, shifter_output, shifter_output, 
							  mux_dummy_input, mux_dummy_input, ctrl_ALUopcode, data_result );
	equal <= (		a_xnor_b(0) and
					a_xnor_b(1) and 
					a_xnor_b(2) and 
					a_xnor_b(3) and 
					a_xnor_b(4) and 
					a_xnor_b(5) and 
					a_xnor_b(6) and 
					a_xnor_b(7) and 
					a_xnor_b(8) and 
					a_xnor_b(9) and 
					a_xnor_b(10) and 
					a_xnor_b(11) and 
					a_xnor_b(12) and 
					a_xnor_b(13) and 
					a_xnor_b(14) and 
					a_xnor_b(15) and 
					a_xnor_b(16) and 
					a_xnor_b(17) and 
					a_xnor_b(18) and 
					a_xnor_b(19) and 
					a_xnor_b(20) and 
					a_xnor_b(21) and 
					a_xnor_b(22) and 
					a_xnor_b(23) and 
					a_xnor_b(24) and 
					a_xnor_b(25) and 
					a_xnor_b(26) and 
					a_xnor_b(27) and 
					a_xnor_b(28) and 
					a_xnor_b(29) and 
					a_xnor_b(30) and 
					a_xnor_b(31));
		
		a_xnor_b <= data_operandA xnor data_operandB;
		
		isEqual <= equal;
		isGreaterThan <= (not equal) and (adder_output1(31) xnor '1');			
		
		and_output <= data_operandA and data_operandB;
		or_output <= data_operandA or data_operandB;
		
		
end structure;