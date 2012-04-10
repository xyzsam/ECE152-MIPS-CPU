library ieee;
use ieee.std_logic_1164.all;

entity forward_unit is
	port (	ID_EX_rs, ID_EX_rt, ID_EX_rd, 
			EX_MEM_rd, MEM_WB_rd : in std_logic_vector(4 downto 0);
			EX_MEM_regwrite, MEM_WB_regwrite, ID_EX_memwrite, EX_MEM_memwrite : in std_logic;
			forward_A, forward_B, forward_data : out std_logic_vector(1 downto 0));
end forward_unit;

architecture behavior of forward_unit is


begin

	forward_A <= "10" when (MEM_WB_regwrite = '1' and 
                                not (EX_MEM_regwrite = '1' and not (EX_MEM_rd = "00000") and
                                     EX_MEM_rd = ID_EX_rs) and
				not(MEM_WB_rd = "00000") and MEM_WB_rd = ID_EX_rs) else
         		 "01" when (EX_MEM_regwrite = '1' and not(EX_MEM_rd = "00000") and
				EX_MEM_rd = ID_EX_rs) else
			 "00";
							
	forward_B <= "10" when (MEM_WB_regwrite = '1' and 
                                not (EX_MEM_regwrite = '1' and not (EX_MEM_rd = "00000") and
                                     EX_MEM_rd = ID_EX_rt) and
				not(MEM_WB_rd = "00000") and MEM_WB_rd = ID_EX_rt) else
         		 "01" when (EX_MEM_regwrite = '1' and not(EX_MEM_rd = "00000") and
				EX_MEM_rd = ID_EX_rt and (ID_EX_memwrite = '0')) else
			 "00";
			 
	forward_data <= "10" when (MEM_WB_regwrite = '1' and (MEM_WB_rd = ID_EX_rd) and (ID_EX_memwrite = '1')) else
					"01" when (EX_MEM_regwrite = '1' and (EX_MEM_rd = ID_EX_rd) and (ID_EX_memwrite = '1')) else
					"00";
			 
end behavior;
