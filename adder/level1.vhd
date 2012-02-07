library ieee;
use ieee.std_logic_1164.all;

entity level1 is
	port(g3, g2, g1, g0: in std_logic;
		 p3, p2, p1, p0: in std_logic;
		 c_in : in std_logic;
		 g_out, p_out : out std_logic;
		 c_out1, c_out2, c_out3 : out std_logic);
end level1;

architecture structure of level1 is

signal g32, g10, p32, p10: std_logic;
signal g30, p30: std_logic;
signal g21, p21: std_logic;

begin

	g10 <= g1 or (p1 and g0);
	p10 <= p1 and p0;
	
	g21 <= g2 or (p2 and g1);
	p21 <= p2 and p1;
	
	g32 <= g3 or (p3 and g2);
	p32 <= p3 and p2;

	g_out <= g32 or (p32 and g10);
	p_out <= p32 and p10;
	
	c_out1 <= g0 or (p0 and c_in);
	c_out2 <= g10 or (p10 and c_in);
	c_out3 <= g21 or (p21 and (g0 or (p0 and c_in)));

end structure;