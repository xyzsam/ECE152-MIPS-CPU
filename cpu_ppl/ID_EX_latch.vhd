library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_latch is
	port (	clock, reset : in std_logic;
			wb_memw_in, m_memw_in, ex_memw_in : in std_logic;
			wb_regw_in, m_regw_in, ex_regw_in : in std_logic;
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rs, instr_rt, instr_rd : in std_logic_vector(4 downto 0);
			sgn_ext_in : in std_logic_vector(31 downto 0);
			wb_reg_kb_mux_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in, ctrl_jump_in, ctrl_jr_in, ctrl_jal_in : in std_logic; 
               wb_ctrl_alu_dmem_in : in std_logic;
			wb_memw_out, m_memw_out, ex_memw_out : out std_logic;
			wb_regw_out, m_regw_out, ex_regw_out : out std_logic;
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rs_out, instr_rt_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out : out std_logic_vector(31 downto 0);
               wb_reg_kb_mux_out : out std_logic;
               ctrl_beq_out, ctrl_bgt_out, ctrl_jump_out, ctrl_jr_out, ctrl_jal_out : out std_logic; 
               wb_ctrl_alu_dmem_out : out std_logic);
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

	wb_memw_dffe : dffe port map(wb_memw_in, clock, not reset, '1', '1', wb_memw_out);
	m_memw_dffe : dffe port map(m_memw_in, clock, not reset, '1', '1', m_memw_out);
	ex_memw_dffe : dffe port map(ex_memw_in, clock, not reset, '1', '1', ex_memw_out);
	
	wb_regw_dffe : dffe port map(wb_regw_in, clock, not reset, '1', '1', wb_regw_out);
	m_regw_dffe : dffe port map(m_regw_in, clock, not reset, '1', '1', m_regw_out);
	ex_regw_dffe : dffe port map(ex_regw_in, clock, not reset, '1', '1', ex_regw_out);

	kb_mux_dffe : dffe port map(wb_reg_kb_mux_in, clock, not reset, '1', '1', wb_reg_kb_mux_out);
	alu_dmem_dffe : dffe port map(wb_ctrl_alu_dmem_in, clock, not reset, '1', '1', wb_ctrl_alu_dmem_out);

     ctrl_beq_dffe : dffe port map(ctrl_beq_in, clock, not reset, '1', '1', ctrl_beq_out);
     ctrl_bgt_dffe : dffe port map(ctrl_bgt_in, clock, not reset, '1', '1', ctrl_bgt_out);
     ctrl_jump_dffe : dffe port map(ctrl_jump_in, clock, not reset, '1', '1', ctrl_jump_out);
     ctrl_jal_dffe : dffe port map(ctrl_jal_in, clock, not reset, '1', '1', ctrl_jal_out);
     ctrl_jr_dffe : dffe port map(ctrl_jr_in, clock, not reset, '1', '1', ctrl_jr_out);


	pc_reg : reg32 port map(clock, '1', reset, pc_plus_1_in, pc_plus_1_out);
	regfile_d1_reg : reg32 port map(clock, '1', reset, regfile_d1, regfile_d1_out);
	regfile_d2_reg : reg32 port map(clock, '1', reset, regfile_d2, regfile_d2_out);
	instr_reg : reg32 port map(clock, '1', reset, instr_regs, instr_regs_out);
	sgn_ext_reg : reg32 port map(clock, '1', reset, sgn_ext_in, sgn_ext_out);
	
     	
	instr_rt_out <= instr_regs_out(14 downto 10);
	instr_rs_out <= instr_regs_out(9 downto 5);
	instr_rd_out <= instr_regs_out(4 downto 0);

end structure;
