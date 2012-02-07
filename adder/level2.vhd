library ieee;
use ieee.std_logic_1164.all;

entity level2 is
	port(g30, g74 : in std_logic;
		 p30, p74 : in std_logic;
		 c_in : in std_logic;
		 c_out4 : out std_logic;
		 c_out : out std_logic);
end level2;

architecture structure of level2 is

signal c4 : std_logic;

begin

	c4 <= g30 or (p30 and c_in);
	c_out4 <= c4;
	c_out <= g74 or (p74 and c4);

end structure;