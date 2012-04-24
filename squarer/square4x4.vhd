library ieee;
use ieee.std_logic_1164.all;

entity square4x4 is
	port (	input	: in std_logic_vector(3 downto 0);
			output	: out std_logic_vector(7 downto 0));
end square4x4;

architecture structure of square4x4 is

component square2x2
	port (	input 	: in std_logic_vector(1 downto 0);
			output	: out std_logic_vector(3 downto 0));
end component;

component mult2x2
	port (A, B : in std_logic_vector(1 downto 0);
		  R			 : out std_logic_vector(3 downto 0));
end component;

component addercs3_4b
	port (A, B, C : in std_logic_vector(3 downto 0);
	      S : out std_logic_vector(4 downto 0); -- sum
	      c_out : out std_logic); -- carry
end component;

component adder_4b
	port (A, B : in std_logic_vector(3 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(3 downto 0);
		  c_out : out std_logic);
end component;


signal square_up, square_low : std_logic_vector(3 downto 0);
signal mult_out : std_logic_vector(3 downto 0);
signal addercs_in_3, adder4b_in, adder4b_sum  : std_logic_vector(3 downto 0);
signal addercs_sum : std_logic_vector(4 downto 0);
signal addercs_carry, adder4b_carry : std_logic;

begin

	square2b_0 : square2x2 port map(input(1 downto 0), square_low);
	square2b_1 : square2x2 port map(input(3 downto 2), square_up);
	
	mult2x2_0 : mult2x2 port map(input(1 downto 0), input(3 downto 2), mult_out);
	
	addercs_in_3(3 downto 2) <= "00";
	addercs_in_3(1 downto 0) <= square_low(3 downto 2);
	
	addercs : addercs3_4b port map(mult_out, mult_out, addercs_in_3, addercs_sum, addercs_carry);
	
	adder4b_in(3) <= '0';
	adder4b_in(2 downto 0) <= addercs_sum(4 downto 2);
	
	adder_4b_0 : adder_4b port map(square_up, adder4b_in, '0', adder4b_sum, adder4b_carry);
	
	output(7 downto 4) <= adder4b_sum;
	output(3 downto 2) <= addercs_sum(1 downto 0);
	output(1 downto 0) <= square_low(1 downto 0);

end structure;