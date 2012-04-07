library ieee;
use ieee.std_logic_1164.all;

entity EX_MEM_latch is
	port (	clock, reset : in std_logic;
			wb_regw_in, mem_memw_in : in std_logic;
			isEqual, isGreaterThan : in std_logic;
			alu_output, regfile_d2_in : in std_logic_vector(31 downto 0);
			pc_plus_1_in, branch_addr : in std_logic_vector(31 downto 0);
               kb_data_in : in std_logic_vector(31 downto 0);
               ctrl_alu_dmem_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in : in std_logic; 
			wb_regw_out, mem_memw_out : out std_logic;
			isEqual_out, isGreaterThan_out : out std_logic;
			alu_output_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			pc_plus_1_out, branch_addr_out : out std_logic_vector(31 downto 0);
               kb_data_out : out std_logic_vector(31 downto 0);
               ctrl_alu_dmem_out : out std_logic;
               ctrl_beq_out, ctrl_bgt_out : out std_logic); 
end EX_MEM_latch;

architecture structure of EX_MEM_latch is

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

	wb_regw_dffe : dffe port map(wb_regw_in, clock, not reset, '1', '1', wb_regw_out);
	mem_memw_dffe : dffe port map(mem_memw_in, clock, not reset, '1', '1', mem_memw_out);
	
	isEqual_dffe : dffe port map(isEqual, clock, not reset, '1', '1', isEqual_out);
	isGreaterThan_dffe : dffe port map(isGreaterThan, clock, not reset, '1', '1', isGreaterThan_out);
	
	alu_output_reg : reg32 port map(clock, '1', reset, alu_output, alu_output_out);
	pc_plus_one_reg : reg32 port map(clock, '1', reset, pc_plus_1_in, pc_plus_1_out);
	branch_addr_reg : reg32 port map(clock, '1', reset, branch_addr, branch_addr_out);
	kb_data_reg : reg32 port map(clock, '1', reset, kb_data_in, kb_data_out);
	
     alu_dmem_reg : dffe port map(ctrl_alu_dmem_in, clock, not reset, '1', '1', ctrl_alu_dmem_out);	
end structure;
