library ieee;
use ieee.std_logic_1164.all;

entity forward_unit is
	port (	ID_EX_rs, ID_EX_rt, ID_EX_rd, 
			EX_MEM_rd, MEM_WB_rd : in std_logic_vector(4 downto 0);
			EX_MEM_regwrite, MEM_WB_regwrite : in std_logic;
			forward_A, forward_B : out std_logic_vector(1 downto 0));	
end forward_unit;

architecture behavior of forward_unit is


begin

	forward_A <= "01" when (MEM_WB_regwrite = '1' and EX_MEM_regwrite = '0' and
							not(MEM_WB_rd = "00000") and not(EX_MEM_rd = "00000") and
							not(EX_MEM_rd = ID_EX_rs) and MEM_WB_rd = ID_EX_rs) else
				 "10" when (EX_MEM_regwrite = '1' and not(EX_MEM_rd = "00000") and
							EX_MEM_rd = ID_EX_rs) else
				 "00";
							
	forward_B <= "01" when (MEM_WB_regwrite = '1' and EX_MEM_regwrite = '0' and
							not(MEM_WB_rd = "00000") and not(EX_MEM_rd = "00000") and
							not(EX_MEM_rd = ID_EX_rt) and MEM_WB_rd = ID_EX_rt) else
				 "10" when (EX_MEM_regwrite = '1' and not(EX_MEM_rd = "00000") and
							EX_MEM_rd = ID_EX_rt) else
				 "00";
end behavior;