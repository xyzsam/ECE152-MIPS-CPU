library ieee;
use ieee.std_logic_1164.all;

entity CLA8bit is
	port(data_A : in std_logic_vector(7 downto 0);
		 data_B : in std_logic_vector(7 downto 0);
		 carry_in : in std_logic;
		 sum    : out std_logic_vector(7 downto 0);
		 carry_out  : out std_logic);
end CLA8bit;

architecture structure of CLA8bit is

component level2
	port(g30, g74 : in std_logic;
		 p30, p74 : in std_logic;
		 c_in : in std_logic;
		 c_out4 : out std_logic;
		 c_out : out std_logic);
end component;

component level1
	port(g3, g2, g1, g0: in std_logic;
		 p3, p2, p1, p0: in std_logic;
		 c_in : in std_logic;
		 g_out, p_out : out std_logic;
		 c_out1, c_out2, c_out3 : out std_logic);
end component;

component level0
	port( a : in std_logic;
		  b : in std_logic;
		  c_in   : in std_logic;
		  g_out, p_out : out std_logic);
end component;

begin

end structure;