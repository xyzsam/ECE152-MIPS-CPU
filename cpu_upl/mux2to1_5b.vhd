library ieee;
use ieee.std_logic_1164.all;

entity mux2to1_5b is
	port (	in0, in1	: in std_logic_vector(4 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(4 downto 0));
end mux2to1_5b;

architecture structure of mux2to1_5b is

signal ctrl_select_5 : std_logic_vector(4 downto 0);

begin

	ctrl_gen : for i in 0 to 4 generate
		ctrl_select_5(i) <= ctrl_select;
	end generate ctrl_gen;
	
	data_out <= (( ctrl_select_5 and in1) or 
				(( not ctrl_select_5) and in0));

end structure;
