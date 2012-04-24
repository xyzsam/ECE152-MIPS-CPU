library ieee;
use ieee.std_logic_1164.all;

-- infinite carry lookahead 5 bit adder
entity adder_5b is
	port (A, B : in std_logic_vector(4 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(4 downto 0);
		  c_out : out std_logic);
end adder_5b;


architecture structure of adder_5b is

component level0
	port( a : in std_logic;
		  b : in std_logic;
		  g_out, p_out : out std_logic);
end component;

signal g0, g1, g2, g3, g4 : std_logic;
signal p0, p1, p2, p3, p4 : std_logic;

signal c_out1, c_out2, c_out3, c_out4, c_out5 : std_logic;

begin

	
    c_out1 <= g0 or (p0 and c_in);
    c_out2 <= g1 or (p1 and g0) or (p0 and p1 and c_in);
    c_out3 <= g2 or (p2 and g1) or (p1 and p2 and g0) or (c_in and p0 and p1 and p2);
    c_out4 <= g3 or (p3 and g2) or (p2 and p3 and g1) or (g0 and p1 and p2 and p3) or (c_in and p0 and p1 and p2 and p3); 
    c_out5 <= g4 or (p4 and g3) or (p3 and p4 and g2) or (g1 and p2 and p3 and p4) or (g0 and p1 and p2 and p3 and p4) or (c_in and p0 and p1 and p2 and p3 and p4);
       
    level0_0: level0 port map (A(0), B(0), g0, p0);
    level0_1: level0 port map (A(1), B(1), g1, p1);
    level0_2: level0 port map (A(2), B(2), g2, p2);
    level0_3: level0 port map (A(3), B(3), g3, p3);
    level0_4: level0 port map (A(4), B(4), g4, p4);  
 
    sum(0) <= c_in   xor A(0) xor B(0);
    sum(1) <= c_out1 xor A(1) xor B(1);
    sum(2) <= c_out2 xor A(2) xor B(2);
    sum(3) <= c_out3 xor A(3) xor B(3);
    sum(4) <= c_out4 xor A(4) xor B(4);
   
    c_out <= c_out5;
	
	
end structure;