library ieee;
use ieee.std_logic_1164.all;

entity CLA16bit is
	port (data_A, data_B : in std_logic_vector(15 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(16 downto 0);
		  c_out : out std_logic);
end CLA16bit;

architecture structure of CLA16bit is

component CLA8bit
	port(data_A : in std_logic_vector(7 downto 0);
		 data_B : in std_logic_vector(7 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(7 downto 0);
		 c_out  : out std_logic);
end component;

signal c8 : std_logic;

begin

	bits70 : CLA8bit port map (data_A(7 downto 0), data_B(7 downto 0), c_in, sum(7 downto 0), c8);
	bits158 : CLA8bit port map (data_A(15 downto 8), data_B(15 downto 8), c8, sum(15 downto 8), c_out);

end structure;