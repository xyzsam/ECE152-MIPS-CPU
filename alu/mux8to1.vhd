library ieee;
use ieee.std_logic_1164.all;

entity mux8to1 is
port (in0, in1, in2, in3, in4, in5, in6, in7: in std_logic_vector(31 downto 0);
	  ctrl  : in std_logic_vector(2 downto 0);
	  output: out std_logic_vector(31 downto 0));
end mux8to1;

architecture structure of mux8to1 is

type selector_type is array(0 to 7) of std_logic_vector(2 downto 0);
type bitmask_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal arr_a : selector_type;
signal bitmask : bitmask_type;

begin

    arr_a(0)  <= ctrl xnor "000";
    arr_a(1)  <= ctrl xnor "001";
    arr_a(2)  <= ctrl xnor "010";
    arr_a(3)  <= ctrl xnor "011";
    arr_a(4)  <= ctrl xnor "100";
    arr_a(5)  <= ctrl xnor "101";
    arr_a(6)  <= ctrl xnor "110";
    arr_a(7)  <= ctrl xnor "111";
   
    
   	bitmask_gen1 : for I in 0 to 7 generate
		bitmask_gen2 : for J in 0 to 31 generate
			bitmask(I)(J) <= (arr_a(I)(0) and arr_a(I)(1) and arr_a(I)(2));
		end generate bitmask_gen2;
	end generate bitmask_gen1;
	
	output <= 	(bitmask(0) and in0) or 
				(bitmask(1) and in1) or 
				(bitmask(2) and in2) or 
				(bitmask(3) and in3) or 
				(bitmask(4) and in4) or 
				(bitmask(5) and in5) or 
				(bitmask(6) and in6) or 
				(bitmask(7) and in7);

end structure;