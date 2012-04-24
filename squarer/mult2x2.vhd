library ieee;
use ieee.std_logic_1164.all;

-- multiplies 2 2-bit numbers using Vedic multiplication
entity mult2x2 is
	port (A, B : in std_logic_vector(1 downto 0);
		  R			 : out std_logic_vector(3 downto 0));
end mult2x2;

architecture structure of mult2x2 is

signal c : std_logic;
begin

	R(0) <= A(0) and B(0);
	R(1) <= (A(0) and B(1)) xor (A(1) and B(0));
	c <= A(0) and A(1) and B(0) and B(1);
	R(2) <= c xor (A(1) and B(1));
	R(3) <= c and A(1) and B(1);
	
	
end structure;