library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_latch is
	port (	clock, reset : in std_logic;
			wb, m, ex : in std_logic;
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rs, instr_rt, instr_rd : in std_logic_vector(31 downto 0);
			sgn_ext_unit : in std_logic_vector(31 downto 0);
			wb_out, m_out, ex_out : out std_logic;
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rs_out, instr_rt_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out : out std_logic_vector(31 downto 0));
end ID_EX_latch;
architecture structure of ID_EX_latch is

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

signal instr_regs, instr_regs_out : std_logic_vector(31 downto 0);

begin

	instr_regs(14 downto 10) <= instr_rt;
	instr_regs(9 downto 5) <= instr_rs;
	instr_regs(4 downto 0) <= instr_rd;

	wb_dffe : dffe port map(wb, clock, not reset, '1', '1', wb_out);
	m_dffe : dffe port map(m, clock, not reset, '1', '1', m_out);
	ex_dffe : dffe port map(ex, clock, not reset, '1', '1', ex_out);
	
	pc_reg : reg32 port map(clock, '1', reset, pc_plus_1_in, pc_plus_1_out);
	regfile_d1_reg : reg32 port map(clock, '1', reset, regfile_d1, regfile_d1_out);
	regfile_d2_reg : reg32 port map(clock, '1', reset, regfile_d2, regfile_d2_out);
	instr_reg : reg32 port map(clock, '1', reset, instr_regs, instr_regs_out);
	sgn_ext_reg : reg32 port map(clock, '1', reset, sgn_ext_unit, sgn_ext_out);
	
	
	instr_rt_out <= instr_regs_out(14 downto 0);
	instr_rs_out <= instr_regs_out(9 downto 5);
	instr_rd_out <= instr_regs_out(4 downto 0);

end structure;
