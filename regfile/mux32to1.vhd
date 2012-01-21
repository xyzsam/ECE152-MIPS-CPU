library ieee;
use ieee.std_logic_1164.all;

entity mux32to1 is
port (in0, in1, in2, in3, in4, in5, in6, in7,
	  in8, in9, in10, in11, in12, in13, in14, in15,
	  in16, in17, in18, in19, in20, in21, in22, in23,
	  in24, in25, in26, in27, in28, in29, in30, in31, in32: in std_logic_vector(31 downto 0);
	  ctrl  : in std_logic_vector(4 downto 0);
	  output: out std_logic_vector(31 downto 0));
end mux32to1;

architecture structure of mux32to1 is

type selector_type is array(0 to 31) of std_logic_vector(4 downto 0);
type bitmask_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal arr_a : selector_type;
signal bitmask : bitmask_type;

begin

    arr_a(0)  <= ctrl xnor "00000";
    arr_a(1)  <= ctrl xnor "00001";
    arr_a(2)  <= ctrl xnor "00010";
    arr_a(3)  <= ctrl xnor "00011";
    arr_a(4)  <= ctrl xnor "00100";
    arr_a(5)  <= ctrl xnor "00101";
    arr_a(6)  <= ctrl xnor "00110";
    arr_a(7)  <= ctrl xnor "00111";
    arr_a(8)  <= ctrl xnor "01000";
    arr_a(9)  <= ctrl xnor "01001";
    arr_a(10) <= ctrl xnor "01010";
    arr_a(11) <= ctrl xnor "01011";
    arr_a(12) <= ctrl xnor "01100";
    arr_a(13) <= ctrl xnor "01101";
    arr_a(14) <= ctrl xnor "01110";
    arr_a(15) <= ctrl xnor "01111";
    arr_a(16) <= ctrl xnor "10000";
    arr_a(17) <= ctrl xnor "10001";
    arr_a(18) <= ctrl xnor "10010";
    arr_a(19) <= ctrl xnor "10011";
    arr_a(20) <= ctrl xnor "10100";
    arr_a(21) <= ctrl xnor "10101";
    arr_a(22) <= ctrl xnor "10110";
    arr_a(23) <= ctrl xnor "10111";
    arr_a(24) <= ctrl xnor "11000";
    arr_a(25) <= ctrl xnor "11001";
    arr_a(26) <= ctrl xnor "11010";
    arr_a(27) <= ctrl xnor "11011";
    arr_a(28) <= ctrl xnor "11100";
    arr_a(29) <= ctrl xnor "11101";
    arr_a(30) <= ctrl xnor "11110";
    arr_a(31) <= ctrl xnor "11111";
   
    
   	bitmask_gen1 : for I in 0 to 31 generate
		bitmask_gen2 : for J in 0 to 31 generate
			bitmask(I)(J) <= (arr_a(I)(0) and arr_a(I)(1) and arr_a(I)(2) and arr_a(I)(3) and arr_a(I)(4));
		end generate bitmask_gen2;
	end generate bitmask_gen1;
	
	output <= 	(bitmask(0) and in0) or 
				(bitmask(1) and in1) or 
				(bitmask(2) and in2) or 
				(bitmask(3) and in3) or 
				(bitmask(4) and in4) or 
				(bitmask(5) and in5) or 
				(bitmask(6) and in6) or 
				(bitmask(7) and in7) or
				(bitmask(8) and in8) or
				(bitmask(9) and in9) or
				(bitmask(10) and in10) or
				(bitmask(11) and in11) or
				(bitmask(12) and in12) or
				(bitmask(13) and in13) or
				(bitmask(14) and in14) or
				(bitmask(15) and in15) or
				(bitmask(16) and in16) or
				(bitmask(17) and in17) or
				(bitmask(18) and in18) or
				(bitmask(19) and in19) or
				(bitmask(20) and in20) or
				(bitmask(21) and in21) or
				(bitmask(22) and in22) or
				(bitmask(23) and in23) or
				(bitmask(24) and in24) or
				(bitmask(25) and in25) or
				(bitmask(26) and in26) or
				(bitmask(27) and in27) or
				(bitmask(28) and in28) or
				(bitmask(29) and in29) or
				(bitmask(30) and in30) or
				(bitmask(31) and in31);


end structure;