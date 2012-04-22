library ieee;
use ieee.std_logic_1164.all;

entity CLA8bit is
	port(data_A : in std_logic_vector(7 downto 0);
		 data_B : in std_logic_vector(7 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(7 downto 0);
		 c_out  : out std_logic);
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
		  g_out, p_out : out std_logic);
end component;

signal g0, g1, g2, g3, g4, g5, g6, g7 : std_logic;
signal p0, p1, p2, p3, p4, p5, p6, p7 : std_logic;
signal g30, g74, p30, p74 : std_logic;
signal c_out1, c_out2, c_out3, c_out4, c_out5, c_out6, c_out7, c_out8 : std_logic;

begin

	
    c_out1 <= g0 or (p0 and c_in);
    c_out2 <= g1 or (p1 and g0) or (p0 and p1 and c_in);
    c_out3 <= g2 or (p2 and g1) or (p1 and p2 and g0) or (c_in and p0 and p1 and p2);
    c_out4 <= g3 or (p3 and g2) or (p2 and p3 and g1) or (g0 and p1 and p2 and p3) or (c_in and p0 and p1 and p2 and p3);
   
    c_out5 <= g4 or (p4 and g3) or (p3 and p4 and g2) or (g1 and p2 and p3 and p4) or (g0 and p1 and p2 and p3 and p4) or (c_in and p0 and p1 and p2 and p3 and p4);
    c_out6 <= g5 or (p5 and g4) or (p4 and p5 and g3) or (g2 and p3 and p4 and p5) or (g1 and p2 and p3 and p4 and p5) or (g0 and p1 and p2 and p3 and p4 and p5) or (c_in and p0 and p1 and p2 and p3 and p4 and p5);
    c_out7 <= g6 or (p6 and g5) or (p5 and p6 and g4) or (g3 and p4 and p5 and p6) or (g2 and p3 and p4 and p5 and p6) or (g1 and p2 and p3 and p4 and p5 and p6) or (g0 and p1 and p2 and p3 and p4 and p5 and p6) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6);
    c_out8 <= g7 or (p7 and g6) or (p6 and p7 and g5) or (g4 and p5 and p6 and p7) or (g3 and p4 and p5 and p6 and p7) or (g2 and p3 and p4 and p5 and p6 and p7) or (g1 and p2 and p3 and p4 and p5 and p6 and p7) or (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7);
   
    level0_0: level0 port map (data_A(0), data_B(0), g0, p0);
    level0_1: level0 port map (data_A(1), data_B(1), g1, p1);
    level0_2: level0 port map (data_A(2), data_B(2), g2, p2);
    level0_3: level0 port map (data_A(3), data_B(3), g3, p3);
    level0_4: level0 port map (data_A(4), data_B(4), g4, p4);
    level0_5: level0 port map (data_A(5), data_B(5), g5, p5);
    level0_6: level0 port map (data_A(6), data_B(6), g6, p6);
    level0_7: level0 port map (data_A(7), data_B(7), g7, p7);
   
    --level1_30: level1 port map (g3, g2, g1, g0, p3, p2, p1, p0, c_in, g30, p30, c_out1, c_out2, c_out3);
    --level1_74: level1 port map (g7, g6, g5, g4, p7, p6, p5, p4, c_out4, g74, p74, c_out5, c_out6, c_out7);
   
    --level2_70: level2 port map (g30, g74, p30, p74, c_in, c_out4, c_out8);
   
    sum(0) <= c_in xor data_A(0) xor data_B(0);
    sum(1) <= c_out1 xor data_A(1) xor data_B(1);
    sum(2) <= c_out2 xor data_A(2) xor data_B(2);
    sum(3) <= c_out3 xor data_A(3) xor data_B(3);
    sum(4) <= c_out4 xor data_A(4) xor data_B(4);
    sum(5) <= c_out5 xor data_A(5) xor data_B(5);
    sum(6) <= c_out6 xor data_A(6) xor data_B(6);
    sum(7) <= c_out7 xor data_A(7) xor data_B(7);
   
    c_out <= c_out8;
	
end structure;
