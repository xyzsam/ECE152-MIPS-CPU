library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_latch is
	port (	clock, reset : in std_logic;
			pc_plus_1 : in std_logic_vector(31 downto 0);
			curr_instr : in std_logic_vector(31 downto 0);
			IF_ID_wren : in std_logic;
			pc_out : out std_logic_vector(31 downto 0);
			curr_instr_out : out std_logic_vector(31 downto 0));
end IF_ID_latch;

architecture structure of IF_ID_latch is

component reg32
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
end component;

begin

	pc_reg : reg32 port map(clock, IF_ID_wren, reset, pc_plus_1, pc_out);
	curr_instr_reg : reg32 port map(clock, IF_ID_wren, reset, curr_instr, curr_instr_out);
			 
end structure;