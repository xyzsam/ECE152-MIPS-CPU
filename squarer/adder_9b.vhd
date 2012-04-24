library ieee;
use ieee.std_logic_1164.all;

-- infinite carry lookahead 9 bit adder
entity adder_9b is
	port (A, B : in std_logic_vector(8 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(8 downto 0);
		  c_out : out std_logic);
end adder_9b;


architecture structure of adder_9b is

component level0
	port( a : in std_logic;
		  b : in std_logic;
		  g_out, p_out : out std_logic);
end component;

signal g0, g1, g2, g3, g4, g5, g6, g7, g8 : std_logic;
signal p0, p1, p2, p3, p4, p5, p6, p7, p8 : std_logic;

signal c_out1, c_out2, c_out3, c_out4, c_out5, c_out6, c_out7, c_out8, c_out9: std_logic;

begin

	
    c_out1 <= g0 or (p0 and c_in);
    c_out2 <= g1 or (p1 and g0) or (p0 and p1 and c_in);
    c_out3 <= g2 or (p2 and g1) or (p1 and p2 and g0) or (c_in and p0 and p1 and p2);
    c_out4 <= g3 or (p3 and g2) or (p2 and p3 and g1) or (g0 and p1 and p2 and p3) or (c_in and p0 and p1 and p2 and p3);
   
    c_out5 <= g4 or (p4 and g3) or (p3 and p4 and g2) or (g1 and p2 and p3 and p4) or (g0 and p1 and p2 and p3 and p4) or (c_in and p0 and p1 and p2 and p3 and p4);
    c_out6 <= g5 or (p5 and g4) or (p4 and p5 and g3) or (g2 and p3 and p4 and p5) or (g1 and p2 and p3 and p4 and p5) or (g0 and p1 and p2 and p3 and p4 and p5) or (c_in and p0 and p1 and p2 and p3 and p4 and p5);
    c_out7 <= g6 or (p6 and g5) or (p5 and p6 and g4) or (g3 and p4 and p5 and p6) or (g2 and p3 and p4 and p5 and p6) or (g1 and p2 and p3 and p4 and p5 and p6) or (g0 and p1 and p2 and p3 and p4 and p5 and p6) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6);
    c_out8 <= g7 or (p7 and g6) or (p6 and p7 and g5) or (g4 and p5 and p6 and p7) or (g3 and p4 and p5 and p6 and p7) or (g2 and p3 and p4 and p5 and p6 and p7) or (g1 and p2 and p3 and p4 and p5 and p6 and p7) or (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7);
    c_out9 <= g8 or (p8 and g7) or (p7 and p8 and g6) or (g5 and p6 and p7 and p8) or (g4 and p5 and p6 and p7 and p8) or (g3 and p4 and p5 and p6 and p7 and p8) or (g2 and p3 and p4 and p5 and p6 and p7 and p8) or (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8) or (g0   and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8);
    
    level0_0: level0 port map (A(0), B(0), g0, p0);
    level0_1: level0 port map (A(1), B(1), g1, p1);
    level0_2: level0 port map (A(2), B(2), g2, p2);
    level0_3: level0 port map (A(3), B(3), g3, p3);
    level0_4: level0 port map (A(4), B(4), g4, p4);
    level0_5: level0 port map (A(5), B(5), g5, p5);
    level0_6: level0 port map (A(6), B(6), g6, p6);
    level0_7: level0 port map (A(7), B(7), g7, p7);
    level0_8: level0 port map (A(8), B(8), g8, p8);
      
    sum(0) <= c_in   xor A(0) xor B(0);
    sum(1) <= c_out1 xor A(1) xor B(1);
    sum(2) <= c_out2 xor A(2) xor B(2);
    sum(3) <= c_out3 xor A(3) xor B(3);
    sum(4) <= c_out4 xor A(4) xor B(4);
    sum(5) <= c_out5 xor A(5) xor B(5);
    sum(6) <= c_out6 xor A(6) xor B(6);
    sum(7) <= c_out7 xor A(7) xor B(7);
    sum(8) <= c_out8 xor A(8) xor B(8);
   
    c_out <= c_out9;
	
	
end structure;
