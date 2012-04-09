library ieee;
use ieee.std_logic_1164.all;

entity mux4to1_32b is
	port (	in0, in1, in2, in3	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic_vector(1 downto 0);
			data_out	: out std_logic_vector(31 downto 0));
end mux4to1_32b;

architecture structure of mux4to1_32b is

signal ctrl_select0_32, ctrl_select1_32 : std_logic_vector(31 downto 0);
signal temp_data0, temp_data1 : std_logic_vector(31 downto 0);

begin

	ctrl_gen : for i in 0 to 31 generate
		ctrl_select0_32(i) <= ctrl_select(0);
		ctrl_select1_32(i) <= ctrl_select(1);
	end generate ctrl_gen;
	
	temp_data0 <= (( ctrl_select0_32 and in1) or 
				  (( not ctrl_select0_32) and in0));
	temp_data1 <= (( ctrl_select0_32 and in3) or 
				  (( not ctrl_select0_32) and in2));
				  
	data_out <= (( ctrl_select1_32 and temp_data1) or 
				(( not ctrl_select1_32) and temp_data0));
				
end structure;