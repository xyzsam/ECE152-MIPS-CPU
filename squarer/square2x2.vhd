library ieee;
use ieee.std_logic_1164.all;

entity square2x2 is
	port (	input 	: in std_logic_vector(1 downto 0);
			output	: out std_logic_vector(3 downto 0));
end square2x2;

architecture structure of square2x2 is

signal inner : std_logic;

begin

	inner <= input(1) and input(0);
	output(0) <= input(0);
	output(1) <= '0';
	output(2) <= inner xor input(1);
	output(3) <= inner and input(1);

end structure;