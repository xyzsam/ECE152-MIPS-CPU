library ieee;
use ieee.std_logic_1164.all;

entity mux2to1_1b is
	port (	in0, in1	: in std_logic;
			ctrl_select	: in std_logic;
			data_out	: out std_logic;
end mux2to1_1b;

architecture structure of mux2to1_add is

begin

	data_out <= (( ctrl_select and in1) or 
				(( not ctrl_select) and in0));

end structure;