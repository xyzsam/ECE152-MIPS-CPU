library ieee;
use ieee.std_logic_1164.all;

entity adder_16b is
	port(data_A : in std_logic_vector(15 downto 0);
		 data_B : in std_logic_vector(15 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(15 downto 0);
		 c_out  : out std_logic);
end adder_16b;

architecture structure of adder_16b is

component level0
	port( a : in std_logic;
		  b : in std_logic;
		  g_out, p_out : out std_logic);
end component;

signal g0, g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12, g13, g14, g15 : std_logic;
signal p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15 : std_logic;
signal c_out1, c_out2, c_out3, c_out4, c_out5, c_out6, c_out7, c_out8, c_out9, c_out10, c_out11, c_out12, c_out13, c_out14, c_out15, c_out16 : std_logic;

begin

	
    c_out1 <= g0 or (p0 and c_in);
    c_out2 <= g1 or (p1 and g0) or (p0 and p1 and c_in);
    c_out3 <= g2 or (p2 and g1) or (p1 and p2 and g0) or (c_in and p0 and p1 and p2);
    c_out4 <= g3 or (p3 and g2) or (p2 and p3 and g1) or (g0 and p1 and p2 and p3) or (c_in and p0 and p1 and p2 and p3);
   
    c_out5 <= g4 or (p4 and g3) or (p3 and p4 and g2) or (g1 and p2 and p3 and p4) or (g0 and p1 and p2 and p3 and p4) or (c_in and p0 and p1 and p2 and p3 and p4);
    c_out6 <= g5 or (p5 and g4) or (p4 and p5 and g3) or (g2 and p3 and p4 and p5) or (g1 and p2 and p3 and p4 and p5) or (g0 and p1 and p2 and p3 and p4 and p5) or (c_in and p0 and p1 and p2 and p3 and p4 and p5);
    c_out7 <= g6 or (p6 and g5) or (p5 and p6 and g4) or (g3 and p4 and p5 and p6) or (g2 and p3 and p4 and p5 and p6) or (g1 and p2 and p3 and p4 and p5 and p6) or (g0 and p1 and p2 and p3 and p4 and p5 and p6) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6);
    c_out8 <= g7 or (p7 and g6) or (p6 and p7 and g5) or (g4 and p5 and p6 and p7) or (g3 and p4 and p5 and p6 and p7) or (g2 and p3 and p4 and p5 and p6 and p7) or (g1 and p2 and p3 and p4 and p5 and p6 and p7) or (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7) or (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7);
    
    c_out9 <=  g8 or  (p8 and g7) or   (p7 and p8 and g6) or   (g5 and p6 and p7 and p8) or   (g4 and p5 and p6 and p7 and p8) or   (g3 and p4 and p5 and p6 and p7 and p8) or   (g2 and p3 and p4 and p5 and p6 and p7 and p8) or   (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8) or   (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8) or   (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8);
    c_out10 <= g9 or  (p9 and g8) or   (p8 and p9 and g7) or   (g6 and p7 and p8 and p9) or   (g5 and p6 and p7 and p8 and p9) or   (g4 and p5 and p6 and p7 and p8 and p9) or   (g3 and p4 and p5 and p6 and p7 and p8 and p9) or   (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9) or   (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9) or   (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9) or   (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9);
	c_out11 <= g10 or (p10 and g9) or  (p9 and p10 and g8) or  (g7 and p8 and p9 and p10) or  (g6 and p7 and p8 and p9 and p10) or  (g5 and p6 and p7 and p8 and p9 and p10) or  (g4 and p5 and p6 and p7 and p8 and p9 and p10)  or (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10) or  (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10) or  (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10) or  (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10) or  (c_in and p0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10);
	c_out12 <= g11 or (p11 and g10) or (p10 and p11 and g9) or (g8 and p9 and p10 and p11) or (g7 and p8 and p9 and p10 and p11) or (g6 and p7 and p8 and p9 and p10 and p11) or (g5 and p6 and p7 and p8 and p9 and p10 and p11) or (g4 and p5 and p6 and p7 and p8 and p9 and p10 and p11) or (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11) or (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11) or (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11) or (g0 and   p1 and p2 and p2 and p3 and p4 and p6 and p7 and p8 and p9 and p10 and p11) or (c_in and g0 and  p1 and p2 and p2 and p3 and p4 and p6 and p7 and p8 and p9 and p10 and p11);
	
	c_out13 <= g12 or (p12 and g11) or (p11 and p12 and g10) or (g9 and p10 and p11 and p12) or   (g8 and p9 and p10 and p11 and p12) or   (g7 and p8 and p9 and p10 and p11 and p12) or    (g6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12) or     (c_in and p0 and p1 and  p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12);
	c_out14 <= g13 or (p13 and g12) or (p12 and p13 and g11) or (g10 and p11 and p12 and p13) or  (g9 and p10 and p11 and p12 and p13) or  (g8 and p9 and p10 and p11 and p12 and p13) or   (g7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13) or    (c_in and g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13);
	c_out15 <= g14 or (p14 and g13) or (p13 and p14 and g12) or (g11 and p12 and p13 and p14) or  (g10 and p11 and p12 and p13 and p14) or (g9 and p10 and p11 and p12 and p13 and p14) or  (g8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14) or   (c_in and g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14);
	c_out16 <= g15 or (p15 and g14) or (p14 and p15 and g13) or (g12 and p13 and p14 and p15) or  (g11 and p12 and p13 and p14 and p15) or (g10 and p11 and p12 and p13 and p14 and p15) or (g9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15) or  (c_in and g0 and p1 and p2 and p3 and p4 and p5 and p6 and p7 and p8 and p9 and p10 and p11 and p12 and p13 and p14 and p15);
	
    level0_0:  level0 port map (data_A(0), data_B(0), g0, p0);
    level0_1:  level0 port map (data_A(1), data_B(1), g1, p1);
    level0_2:  level0 port map (data_A(2), data_B(2), g2, p2);
    level0_3:  level0 port map (data_A(3), data_B(3), g3, p3);
    level0_4:  level0 port map (data_A(4), data_B(4), g4, p4);
    level0_5:  level0 port map (data_A(5), data_B(5), g5, p5);
    level0_6:  level0 port map (data_A(6), data_B(6), g6, p6);
    level0_7:  level0 port map (data_A(7), data_B(7), g7, p7);
    level0_8:  level0 port map (data_A(8), data_B(8), g8, p8);
    level0_9:  level0 port map (data_A(9), data_B(9), g9, p9);
    level0_10: level0 port map (data_A(10), data_B(10), g10, p10);
    level0_11: level0 port map (data_A(11), data_B(11), g11, p11);
    level0_12: level0 port map (data_A(12), data_B(12), g12, p12);
    level0_13: level0 port map (data_A(13), data_B(13), g13, p13);
    level0_14: level0 port map (data_A(14), data_B(14), g14, p14);
    level0_15: level0 port map (data_A(15), data_B(15), g15, p15);
   
    sum(0) <= c_in xor     data_A(0) xor  data_B(0);
    sum(1) <= c_out1 xor   data_A(1) xor  data_B(1);
    sum(2) <= c_out2 xor   data_A(2) xor  data_B(2);
    sum(3) <= c_out3 xor   data_A(3) xor  data_B(3);
    sum(4) <= c_out4 xor   data_A(4) xor  data_B(4);
    sum(5) <= c_out5 xor   data_A(5) xor  data_B(5);
    sum(6) <= c_out6 xor   data_A(6) xor  data_B(6);
    sum(7) <= c_out7 xor   data_A(7) xor  data_B(7);
    sum(8) <= c_out8 xor   data_A(8) xor  data_B(8);
    sum(9) <= c_out9 xor   data_A(9) xor  data_B(9);
    sum(10) <= c_out10 xor data_A(10) xor data_B(10);
    sum(11) <= c_out11 xor data_A(11) xor data_B(11);
    sum(12) <= c_out12 xor data_A(12) xor data_B(12);
    sum(13) <= c_out13 xor data_A(13) xor data_B(13);
    sum(14) <= c_out14 xor data_A(14) xor data_B(14);
    sum(15) <= c_out15 xor data_A(15) xor data_B(15);
   
    c_out <= c_out16;
	
end structure;
