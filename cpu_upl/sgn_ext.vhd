library ieee;
use ieee.std_logic_1164.all;

-- sign extension unit. Takes a 17 bit input and sign extends to 32 bits
entity sgn_ext is
	port (	input 	: in std_logic_vector(16 downto 0);
			output	: out std_logic_vector(31 downto 0));
end sgn_ext;

architecture structure of sgn_ext is

signal temp	: std_logic_vector(31 downto 0);

begin

		ext_gen : for i in 0 to 15 generate
			temp(i+16) <= input(16);
		end generate ext_gen;
		
		rest_gen : for i in 0 to 15 generate
			temp(i) <= input(i);
		end generate rest_gen;
		
		output <= temp;
		
end structure;