library ieee;
use ieee.std_logic_1164.all;

entity processor_ppl is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0));
end processor_ppl;

architecture structure of processor_ppl is

component ID_EX_latch
	port (	clock, reset : in std_logic;
			wb, m, ex : in std_logic;
			pc_plus_1 : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rt, instr_rs, instr_rd : in std_logic_vector(31 downto 0);
			sgn_ext_unit : in std_logic_vector(31 downto 0);
			wb_out, m_out, ex_out : out std_logic;
			pc_plus_1 : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rt_out, instr_rs_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out : out std_logic_vector(31 downto 0));
end ID_EX_latch;

component EX_MEM_latch
	port (	clock, reset : in std_logic;
			wb, m : in std_logic;
			isEqual, isGreaterThan : in std_logic;
			alu_output : in std_logic_vector(31 downto 0);
			pc_plus_one : in std_logic_vector(31 downto 0);
			branch_addr : in std_logic_vector(31 downto 0);
			wb_out, m_out : out std_logic;
			isEqual_out, isGreaterThan_out : out std_logic;
			alu_output_out : out std_logic_vector(31 downto 0);
			pc_plus_one_out : out std_logic_vector(31 downto 0);
			branch_addr_out : out std_logic_vector(31 downto 0));
end EX_MEM_latch;

component execute_stage
	port (	clock, reset : in std_logic;
			wb_memw_in, m_memw_in, ex_memw_in : in std_logic; -- mem write enable
			wb_regw_in, m_regw_in, ex_regw_in : in std_logic; -- regfile write enable
			pc_out : in std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : in std_logic_vector(31 downto 0);
			ID_EX_rs, ID_EX_rt, ID_EX_rd, EX_MEM_rd, MEM_WB_rd : in std_logic_vector(4 downto 0);
			sgn_ext_out, mem_alu_output, dmem_output_out : in std_logic_vector(31 downto 0);
			ctrl_alu_opcode, ctrl_flush : in std_logic_vector(5 downto 0);
			
			wb_regw_out, m_regw_out, wb_memw_out, m_memw_out : out std_logic;
			isEqual, isGreaterThan : out std_logic;
			alu_output : out std_logic_vector(31 downto 0);
			pc_plus_one : out std_logic_vector(31 downto 0);
			branch_addr : out std_logic_vector(31 downto 0));
end component;

---------------------- EXECUTE STAGE SIGNALS ---------------------------------
signal EX_regfile_d1, EX_regfile_d2, EX_sgn_ext_out, EX_pc_plus_1: std_logic_vector(31 downto 0);
signal EX_branch_addr : std_logic_vector(31 downto 0);
signal EX_wb_memw_in, EX_m_memw_in, EX_ex_memw_in : std_logic; -- mem write enable
signal EX_wb_regw_in, EX_m_regw_in, EX_ex_regw_in : std_logic; -- regfile write enable
signal ID_EX_rs, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal EX_ctrl_alu_opcode : std_logic_vector(5 downto 0);


----------------------- MEMORY STAGE SIGNALS ----------------------------------
signal mem_alu_output, dmem_output_out : std_logic_vector(31 downto 0);
signal EX_MEM_rd, MEM_WB_rd : std_logic_vector(4 downto 0);

begin

	------------------- FETCH STAGE  ------------------------
	
	
	------------------- IF/ID LATCH  -------------------------
	
	
	------------------- DECODE STAGE -------------------------

	
	------------------- ID/EX LATCH ---------------------------
	

	------------------- EXECUTE STAGE -----------------------
	
	branch_adder : adder port map(EX_pc_plus_1, EX_sgn_ext_out, '0', branch_addr);
	alu_unit : alu port map(alu_inputA, alu_inputB, ctrl_alu_opcode, alu_output, isEqual, isGreaterThan);
	forward: forward_unit port map(ID_EX_rs, ID_EX_rt, ID_EX_rd, EM_MEM_rd, MEM_WB_rd,
								   m_regw_in, wb_regw_in, forward_A, forward_B);
	--muxes
	alu_inputA_mux : mux4to1_32b port map(regfile_d1_out,  mem_alu_output, 
										  dmem_output_out, '0', 
										  forward_A, alu_inputA);
	alu_inputB_mux : mux4to1_32b port map(regfile_d2_out,  mem_alu_output, 
										  dmem_output_out, sgn_ext_out, 
										  forward_B, alu_inputB);										  
	wb_ctrl_reg_mux : mux2to1_1b port map(w_regw_in,  '0', ctrl_flush, wb_regw_out);
	wb_ctrl_mem_mux : mux2to1_1b port map(w_memw_in,  '0', ctrl_flush, wb_memw_out);
	m_ctrl_reg_mux : mux2to1_1b port map(m_regw_in,  '0', ctrl_flush, m_regw_out);
	m_ctrl_mem_mux : mux2to1_1b port map(m_memw_in,  '0', ctrl_flush, m_memw_out);



	
	
	-------------------- EX/MEM LATCH -----------------------------
	
	
	
	--------------------- MEMORY STAGE ------------------------------
	
	
	
	---------------------- MEM/WB LATCH ------------------------------
	
	
	
	---------------------- WRITEBACK STAGE ---------------------------
	
	
	
	
	----------------------- INTERSTAGE SIGNALS ------------------------
end structure;
