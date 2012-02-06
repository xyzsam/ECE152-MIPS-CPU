library ieee;
use ieee.std_logic_1164.all;

entity shift4 is
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end shift4;

architecture structure of shift4 is

signal ctrl_rightshift_32 	: std_logic_vector(31 downto 0);
signal data_rightshifted  	: std_logic_vector(31 downto 0);
signal data_leftshifted		: std_logic_vector(31 downto 0);

begin

	ctrl_gen: for i in 0 to 31 generate
		ctrl_rightshift_32(i) <= ctrl_rightshift;
	end generate ctrl_gen;

	-- shift
	
	left_shift: for i in 0 to 27 generate
		data_leftshifted(i+4) <= data_A(i);
	end generate left_shift;

	right_shift: for i in 0 to 27 generate
		data_rightshifted(i) <= data_A(i+4);
	end generate right_shift;
	
	-- zero the remaining bits
	
	left_shift_zero : for i in 0 to 3 generate
		data_leftshifted(i) <= '0';
	end generate left_shift_zero;
	
	right_shift_zero : for i in 28 to 31 generate
		data_rightshifted(i) <= '0';
	end generate right_shift_zero;
	
	data_S <= 	(ctrl_rightshift_32 and data_rightshifted) or
				(data_leftshifted  and (not ctrl_rightshift_32));
	
end structure;