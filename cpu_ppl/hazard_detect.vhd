library ieee;
use ieee.std_logic_1164.all;

entity hazard_detect is
	port (	ID_EX_memRead : in std_logic;
			IF_ID_rs, IF_ID_rt : in std_logic_vector(4 downto 0);
			ID_EX_rs, ID_EX_rt : in std_logic_vector(4 downto 0);
			IF_ID_wren, stall :	out std_logic);
end hazard_detect;

architecture behavior of hazard_detect is

signal isHazard : std_logic;
--signal rtrs_temp, rtrt_temp, overall : std_logic_vector(4 downto 0);

begin

	isHazard <= '1' when ((ID_EX_memRead = '1') and ((ID_EX_rt = IF_ID_rs) or (ID_EX_rt = IF_ID_rt))) else
			     '0';
			 
--	temp_gen : for i in 0 to 4 generate
--			 rtrs_temp(i) <= ID_EX_rt(i) and IF_ID_rs(i);
--			 rtrt_temp(i) <= ID_EX_rt(i) and IF_ID_rt(i);
--			 overall(i) <= rtrs_temp(i) or rtrt_temp(i);
--	end generate temp_gen;
	
--	isHazard <= ID_EX_memRead and 
--				overall(0) and
--				overall(1) and
--				overall(2) and
--				overall(3) and
--				overall(4);
				
	IF_ID_wren <= not isHazard;
	stall <= isHazard;
			 
end behavior;