library ieee;
use ieee.std_logic_1164.all;

entity level0 is
	port( a : in std_logic;
		  b : in std_logic;
		  g_out, p_out : out std_logic);
end level0;

architecture structure of level0 is

begin

	g_out <= a and b;
	p_out <= a or b;
	
end structure;