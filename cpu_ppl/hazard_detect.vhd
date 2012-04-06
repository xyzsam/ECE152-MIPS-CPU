library ieee;
use ieee.std_logic_1164.all;

entity hazard_detect is
	port (	ID_EX_memRead : in std_logic;
			IF_ID_rs, IF_ID_rt : in std_logic_vector(4 downto 0);
			ID_EX_rs, ID_EX_rt : in std_logic_vector(4 downto 0);
			IF_ID_wren, stall :	out std_logic);
end hazard_detect;

architecture behavior of hazard_detect is

signal isHazard : out std_logic;

begin

	isHazard <= '1' when ((ID_EX_memRead = '1') and ((ID_EX_rt = IF_ID_rs) or (ID_EX_rt = IF_ID_rs))) else
			     '0';
			     
	IF_ID_wren <= not isHazard;
	stall <= isHazard;
			 
end behavior;