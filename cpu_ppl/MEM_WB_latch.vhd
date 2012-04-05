library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_latch is
	port (	clock, reset : in std_logic;
			wb : in std_logic;
			dmem_output : in std_logic_vector(31 downto 0);
			alu_output : in std_logic_vector(31 downto 0);
			wb_out : out std_logic;
			dmem_output_out : out std_logic_vector(31 downto 0);
			alu_output_out : out std_logic_vector(31 downto 0);
			);
end MEM_WB_latch;

architecture structure of MEM_WB_latch is

component reg32
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
end component;

component dffe
port (	d   : in std_logic;
        clk  : in std_logic;
        clrn : in std_logic;
        prn  : in std_logic;
        ena  : in std_logic;
        q    : out std_logic);
end component;

begin

	wb_dffe : dffe port map(wb, clock, not reset, '1', '1', wb_out);

	dmem_output_reg : reg32 port map(clock, '1', reset, dmem_output, dmem_output_out);
	alu_output_reg : reg32 port map(clock, '1', reset, alu_output, alu_output_out);
	
	-- meta info :
	
end structure;