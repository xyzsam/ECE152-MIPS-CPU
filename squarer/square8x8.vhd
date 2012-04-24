library ieee;
use ieee.std_logic_1164.all;

entity square8x8 is
	port (	input 	: in std_logic_vector(7 downto 0);
			output 	: out std_logic_vector(15 downto 0));
end square8x8;

architecture structure of square8x8 is

component square4x4
	port (	input	: in std_logic_vector(3 downto 0);
			output	: out std_logic_vector(7 downto 0));
end component;

component mult4x4
	port (operandA, operandB : in std_logic_vector(3 downto 0);
		  product			 : out std_logic_vector(7 downto 0));
end component;

component addercs3_8b 
	port (A, B, C : in std_logic_vector(7 downto 0);
	      S : out std_logic_vector(8 downto 0); -- sum
	      c_out : out std_logic); -- carry
end component;

component CLA8bit 
	port(data_A : in std_logic_vector(7 downto 0);
		 data_B : in std_logic_vector(7 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(7 downto 0);
		 c_out  : out std_logic);
end component;

signal square_up, square_low : std_logic_vector(7 downto 0);
signal mult_out : std_logic_vector(7 downto 0);
signal addercs_in_3, adder8b_in, adder8b_sum  : std_logic_vector(7 downto 0);
signal addercs_sum : std_logic_vector(8 downto 0);
signal addercs_carry, adder8b_carry : std_logic;

begin

	square4b_0 : square4x4 port map(input(3 downto 0), square_low);
	square4b_1 : square4x4 port map(input(7 downto 4), square_up);
	
	mult4x4_0 : mult4x4 port map(input(3 downto 0), input(7 downto 4), mult_out);
	
	addercs_in_3(7 downto 4) <= "0000";
	addercs_in_3(3 downto 0) <= square_low(7 downto 4);
	
	addercs : addercs3_8b port map(mult_out, mult_out, addercs_in_3, addercs_sum, addercs_carry);
	
	adder8b_in(7 downto 5) <= "000";
	adder8b_in(4 downto 0) <= addercs_sum(8 downto 4);
	
	adder_8b_0 : CLA8bit port map(square_up, adder8b_in, '0', adder8b_sum, adder8b_carry);
	
	output(15 downto 8) <= adder8b_sum;
	output(7 downto 4) <= addercs_sum(3 downto 0);
	output(3 downto 0) <= square_low(3 downto 0);

	

end structure;