library ieee;
use ieee.std_logic_1164.all;

entity square16x16 is
	port (	input 	: in std_logic_vector(15 downto 0);
			output 	: out std_logic_vector(31 downto 0));
end square16x16;

architecture structure of square16x16 is

component square8x8
	port (	input	: in std_logic_vector(7 downto 0);
			output	: out std_logic_vector(15 downto 0));
end component;

component mult8x8
	port (A, B : in std_logic_vector(7 downto 0);
		  P  : out std_logic_vector(15 downto 0));
end component;

component addercs3_16b 
	port (A, B, C : in std_logic_vector(15 downto 0);
	      S : out std_logic_vector(16 downto 0); -- sum
	      c_out : out std_logic); -- carry
end component;

component CLA16bit 
	port (data_A, data_B : in std_logic_vector(15 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(15 downto 0);
		  c_out : out std_logic);
end component;

signal square_up, square_low : std_logic_vector(15 downto 0);
signal mult_out : std_logic_vector(15 downto 0);
signal addercs_in_3, adder16b_in, adder16b_sum  : std_logic_vector(15 downto 0);
signal addercs_sum : std_logic_vector(16 downto 0);
signal addercs_carry, adder16b_carry : std_logic;

begin

	square8b_0 : square8x8 port map(input(7 downto 0), square_low);
	square8b_1 : square8x8 port map(input(15 downto 8), square_up);
	
	mult8x8_0 : mult8x8 port map(input(7 downto 0), input(15 downto 8), mult_out);
	
	addercs_in_3(15 downto 8) <= "00000000";
	addercs_in_3(7 downto 0) <= square_low(15 downto 8);
	
	addercs : addercs3_16b port map(mult_out, mult_out, addercs_in_3, addercs_sum, addercs_carry);
	
	adder16b_in(15 downto 9) <= "0000000";
	adder16b_in(8 downto 0) <= addercs_sum(16 downto 8);
	
	adder_16b_0 : CLA16bit port map(square_up, adder16b_in, '0', adder16b_sum, adder16b_carry);
	
	output(31 downto 16) <= adder16b_sum;
	output(15 downto 8) <= addercs_sum(7 downto 0);
	output(7 downto 0) <= square_low(7 downto 0);

end structure;