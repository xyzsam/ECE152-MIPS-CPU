library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_latch is
	port (	clock, reset : in std_logic;
			mem_memw_in, wb_regw_in, mem_read_in : in std_logic;
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rs, instr_rt, instr_rd : in std_logic_vector(4 downto 0);
			sgn_ext_in, wb_kb_data_in : in std_logic_vector(31 downto 0);
			wb_reg_kb_mux_in, ctrl_sgn_ext_mux_in : in std_logic;
			kb_ack_in, lcd_write_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in, ctrl_jump_in, ctrl_jal_in, ctrl_jr_in : in std_logic; 
               wb_ctrl_alu_dmem_in : in std_logic;
               id_ctrl_alu_opcode_out : std_logic_vector(2 downto 0);
			mem_memw_out, wb_regw_out, mem_read_out : out std_logic;
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rs_out, instr_rt_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out, wb_kb_data_out: out std_logic_vector(31 downto 0);
               wb_reg_kb_mux_out, ctrl_sgn_ext_mux_out : out std_logic;
               kb_ack_out, lcd_write_out : out std_logic;
               ctrl_beq_out, ctrl_bgt_out, ctrl_jump_out, ctrl_jal_out, ctrl_jr_out : out std_logic; 
               wb_ctrl_alu_dmem_out : out std_logic;
               ex_ctrl_alu_opcode_in : out std_logic_vector(2 downto 0));
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

	-- Using initial value X (don't care) for net "instr_regs[31...15]"
	instr_regs(31 downto 15) <= "00000000000000000";
	
	instr_regs(14 downto 10) <= instr_rt;
	instr_regs(9 downto 5) <= instr_rs;
	instr_regs(4 downto 0) <= instr_rd;

	wb_memw_dffe : dffe port map(mem_memw_in, clock, not reset, '1', '1', mem_memw_out);
	
--	m_memw_dffe : dffe port map(m_memw_in, clock, not reset, '1', '1', m_memw_out);
--	ex_memw_dffe : dffe port map(ex_memw_in, clock, not reset, '1', '1', ex_memw_out);
	mem_read_dffe : dffe port map(mem_read_in, clock, not reset, '1', '1', mem_read_out);
	wb_regw_dffe : dffe port map(wb_regw_in, clock, not reset, '1', '1', wb_regw_out);
--	m_regw_dffe : dffe port map(m_regw_in, clock, not reset, '1', '1', m_regw_out);
--	ex_regw_dffe : dffe port map(ex_regw_in, clock, not reset, '1', '1', ex_regw_out);

	kb_ack_dffe : dffe port map(kb_ack_in, clock, not reset, '1', '1', kb_ack_out);
     lcd_write_dffe : dffe port map(lcd_write_in, clock, not reset, '1', '1', lcd_write_out);
	kb_mux_dffe : dffe port map(wb_reg_kb_mux_in, clock, not reset, '1', '1', wb_reg_kb_mux_out);
	alu_dmem_dffe : dffe port map(wb_ctrl_alu_dmem_in, clock, not reset, '1', '1', wb_ctrl_alu_dmem_out);
     ctrl_sgn_ext_dffe: dffe port map(ctrl_sgn_ext_mux_in, clock, not reset, '1', '1', ctrL_sgn_ext_mux_out);
     ctrl_beq_dffe : dffe port map(ctrl_beq_in, clock, not reset, '1', '1', ctrl_beq_out);
     ctrl_bgt_dffe : dffe port map(ctrl_bgt_in, clock, not reset, '1', '1', ctrl_bgt_out);
     ctrl_jump_dffe : dffe port map(ctrl_jump_in, clock, not reset, '1', '1', ctrl_jump_out);
     ctrl_jal_dffe : dffe port map(ctrl_jal_in, clock, not reset, '1', '1', ctrl_jal_out);
     ctrl_jr_dffe : dffe port map(ctrl_jr_in, clock, not reset, '1', '1', ctrl_jr_out);


     --- ctrl_alu_opcode dffes
     alu_opcode_0 : dffe port map(id_ctrl_alu_opcode_out(0), clock, not reset, '1', '1', ex_ctrl_alu_opcode_in(0));
     alu_opcode_1 : dffe port map(id_ctrl_alu_opcode_out(1), clock, not reset, '1', '1', ex_ctrl_alu_opcode_in(1));
     alu_opcode_2 : dffe port map(id_ctrl_alu_opcode_out(2), clock, not reset, '1', '1', ex_ctrl_alu_opcode_in(2));

	wb_kb_data_reg : reg32 port map(clock, '1', reset, wb_kb_data_in, wb_kb_data_out);
	pc_reg : reg32 port map(clock, '1', reset, pc_plus_1_in, pc_plus_1_out);
	regfile_d1_reg : reg32 port map(clock, '1', reset, regfile_d1, regfile_d1_out);
	regfile_d2_reg : reg32 port map(clock, '1', reset, regfile_d2, regfile_d2_out);
	instr_reg : reg32 port map(clock, '1', reset, instr_regs, instr_regs_out);
	sgn_ext_reg : reg32 port map(clock, '1', reset, sgn_ext_in, sgn_ext_out);
	
     	
	instr_rt_out <= instr_regs_out(14 downto 10);
	instr_rs_out <= instr_regs_out(9 downto 5);
	instr_rd_out <= instr_regs_out(4 downto 0);

end structure;
