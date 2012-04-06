library ieee;
use ieee.std_logic_1164.all;

entity processor_ppl is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0));
end processor_ppl;

architecture structure of processor_ppl is

component IF_ID_latch
	port (	clock, reset : in std_logic;
			pc_plus_1 : in std_logic_vector(31 downto 0);
			curr_instr : in std_logic_vector(31 downto 0);
			pc_out : out std_logic_vector(31 downto 0);
			curr_instr_out : out std_logic_vector(31 downto 0));
end component;

component ID_EX_latch
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
end component;

component EX_MEM_latch
	port (	clock, reset : in std_logic;
			wb, m : in std_logic;
			isEqual, isGreaterThan : in std_logic;
			alu_output : in std_logic_vector(31 downto 0);
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			branch_addr : in std_logic_vector(31 downto 0);
			wb_out, m_out : out std_logic;
			isEqual_out, isGreaterThan_out : out std_logic;
			alu_output_out : out std_logic_vector(31 downto 0);
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			branch_addr_out : out std_logic_vector(31 downto 0));
end component;

component imem
	PORT
	( 
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component reg32
	port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
			data_writeReg : in std_logic_vector(31 downto 0);
			data_readReg : out std_logic_vector(31 downto 0));
end component;
 
component mux4to1_32b
	port (	in0, in1, in2, in3	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic_vector(1 downto 0);
			data_out	: out std_logic_vector(31 downto 0));
end component;

component mux2to1_32b
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

component mux2to1_1b is
	port (	in0, in1	: in std_logic;
			ctrl_select	: in std_logic;
			data_out	: out std_logic);
end component;

component adder
	port (	data_addendA, data_addendB	: in std_logic_vector(31 downto 0);
			ctrl_subtract				: in std_logic;
			data_sum					: out std_logic_vector(31 downto 0);
			data_carryout				: out std_logic);
end component;

component alu
	port (	data_operandA, data_operandB 	: 	in std_logic_vector(31 downto 0);
			ctrl_ALUopcode				 	:	in std_logic_vector(2 downto 0);
			data_result						: 	out std_logic_vector(31 downto 0);
			isEqual, isGreaterThan			: 	out std_logic);
end component;

component forward_unit
	port (	ID_EX_rs, ID_EX_rt, ID_EX_rd, 
			EX_MEM_rd, MEM_WB_rd : in std_logic_vector(4 downto 0);
			EX_MEM_regwrite, MEM_WB_regwrite : in std_logic;
			forward_A, forward_B : out std_logic_vector(1 downto 0));	
end component;

---------------------- FETCH STAGE SIGNALS -----------------------------------
signal IF_next_pc, IF_cur_pc_in, IF_cur_pc_out, IF_cur_instr, IF_pc_plus_1 : std_logic_vector(31 downto 0);
signal one, zero : std_logic_vector(31 downto 0);
signal pc_wren, carryout_useless : std_logic;
--signal IF_wb_memw_in, IF_m_memw_in, IF_ex_memw_in : std_logic; -- mem write enable
--signal IF_wb_regw_in, IF_m_regw_in, IF_ex_regw_in : std_logic; -- regfile write enable

---------------------- DECODE STAGE SIGNALS ----------------------------------
signal ID_pc_plus_1, ID_cur_instr, ID_regfile_d1, ID_regfile_d2,
	   ID_sgn_ext_out: std_logic_vector(31 downto 0);
signal ID_wb_memw_in, ID_m_memw_in, ID_ex_memw_in : std_logic;
signal ID_wb_regw_in, ID_m_regw_in, ID_ex_regw_in : std_logic; -- regfile write enable
signal ctrl_jr_in, ctrl_jal_in, ctrl_jr_out, ctrl_jal_out: std_logic;
signal ID_rs, ID_rt, ID_rd : std_logic_vector(4 downto 0);

---------------------- EXECUTE STAGE SIGNALS ---------------------------------
signal EX_regfile_d1, EX_regfile_d2, EX_sgn_ext_out, EX_sgn_ext_mux_out, EX_pc_plus_1: std_logic_vector(31 downto 0);
signal EX_branch_addr : std_logic_vector(31 downto 0);
signal EX_wb_memw_in, EX_m_memw_in, EX_ex_memw_in : std_logic; -- mem write enable
signal EX_wb_regw_in, EX_m_regw_in, EX_ex_regw_in : std_logic; -- regfile write enable
signal EX_wb_memw_out, EX_m_memw_out : std_logic; -- mem write enable for next stage
signal EX_wb_regw_out, EX_m_regw_out : std_logic; -- regfile write enable for next stage
signal EX_ctrl_sgn_ext, ctrl_flush_ex  : std_logic;
signal isEqual, isGreaterThan : std_logic;
signal forward_A, forward_B : std_logic_vector(1 downto 0);
signal ID_EX_rs, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal EX_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal EX_alu_inputA, EX_alu_inputB, EX_alu_output : std_logic_vector(31 downto 0);


----------------------- MEMORY STAGE SIGNALS ----------------------------------
signal mem_alu_output, dmem_output_out : std_logic_vector(31 downto 0);
signal EX_MEM_rd, MEM_WB_rd : std_logic_vector(4 downto 0);
signal ctrl_beq_in, ctrl_bgt_in, ctrl_beq_out, ctrl_bgt_out : std_logic; 

------------------------ WRITEBACK STAGE SIGNALS -------------------------------
signal WB_dmem_output : std_logic_vector(31 downto 0);
signal ctrl_jump_in, ctrl_jump_out : std_logic;
signal WB_reg_kb_mux_in, WB_reg_kb_mux_out : std_logic;
signal WB_ctrl_alu_dmem_in, WB_ctrl_alu_dmem_out : std_logic;



begin

	------------------- FETCH STAGE  ------------------------

	zero <= "00000000000000000000000000000000";
	one <= "00000000000000000000000000000001"; 
	pc_reset_mux : mux2to1_32b port map(IF_next_pc, zero, reset, IF_cur_pc_in);
	pc : reg32 port map(clock, pc_wren, reset, IF_cur_pc_in, IF_cur_pc_out);
    instr_mem: imem port map(IF_cur_pc_in(11 downto 0), '1', clock, IF_cur_instr); 
	adder_pc_1  : adder port map(one, IF_cur_pc_out, '0', IF_pc_plus_1, carryout_useless);
	
	
	------------------- IF/ID LATCH  -------------------------
     
    IFID_latch : IF_ID_latch port map(clock, reset,
                                      IF_cur_pc_out, IF_cur_instr,
                                      ID_pc_plus_1, ID_cur_instr);
	
	------------------- DECODE STAGE -------------------------

	
	------------------- ID/EX LATCH ---------------------------
	
	IDEX_latch : ID_EX_latch port map(clock, reset, 
                                       ID_wb_memw_in, ID_m_memw_in, ID_ex_memw_in,
                                       ID_wb_regw_in, ID_m_regw_in, ID_ex_regw_in,
                                       ID_pc_plus_1,
                                       ID_regfile_d1, ID_regfile_d2,
                                       ID_rs, ID_rt, ID_rd,
                                       ID_sgn_ext_out,
                                       WB_reg_kb_mux_in,
                                       ctrl_beq_in, ctrl_bgt_in, ctrl_jump_in, ctrl_jr_in, ctrl_jal_in,
                                       WB_ctrl_alu_dmem_in,
                                       EX_wb_memw_in, EX_m_memw_in, EX_ex_memw_in,
                                       EX_wb_regw_in, EX_m_regw_in, EX_ex_regw_in,
                                       EX_pc_plus_1, 
                                       EX_regfile_d1, EX_regfile_d2,
                                       ID_EX_rs, ID_EX_rt, ID_EX_rd,
                                       EX_sgn_ext_out,
                                       WB_reg_kb_mux_out,
                                       ctrl_beq_out, ctrl_bgt_out, ctrl_jump_out, ctrl_jr_out, ctrl_jal_out,

                                       WB_ctrl_alu_dmem_out);
	------------------- EXECUTE STAGE -----------------------
	
	branch_adder : adder port map(EX_pc_plus_1, EX_sgn_ext_out, '0', EX_branch_addr);
	alu_unit : alu port map(EX_alu_inputA, EX_alu_inputB, EX_ctrl_alu_opcode, EX_alu_output, isEqual, isGreaterThan);
	forward: forward_unit port map(ID_EX_rs, ID_EX_rt, ID_EX_rd, EX_MEM_rd, MEM_WB_rd,
						      EX_m_regw_in, EX_wb_regw_in, forward_A, forward_B);
	--muxes
	alu_inputA_mux : mux4to1_32b port map(EX_regfile_d1,  MEM_alu_output, 
								  WB_dmem_output, zero, forward_A, EX_alu_inputA);
	alu_inputB_mux : mux4to1_32b port map(EX_sgn_ext_mux_out,  MEM_alu_output, 
								  WB_dmem_output, zero, forward_B, EX_alu_inputB);										  
	wb_ctrl_reg_mux : mux2to1_1b port map(EX_wb_regw_in,  '0', ctrl_flush_ex, EX_wb_regw_out);
	wb_ctrl_mem_mux : mux2to1_1b port map(EX_wb_memw_in,  '0', ctrl_flush_ex, EX_wb_memw_out);
	m_ctrl_reg_mux : mux2to1_1b port map(EX_m_regw_in,  '0', ctrl_flush_ex, EX_m_regw_out);
	m_ctrl_mem_mux : mux2to1_1b port map(EX_m_memw_in,  '0', ctrl_flush_ex, EX_m_memw_out);
	sgn_ext_mux : mux2to1_32b port map(EX_regfile_d2, EX_sgn_ext_out, EX_ctrl_sgn_ext, EX_sgn_ext_mux_out);
	
	---------------------- EX/MEM LATCH -----------------------------
	
	
	
	----------------------- MEMORY STAGE ------------------------------
	
	
	
	----------------------- MEM/WB LATCH ------------------------------
	
	
	
	---------------------- WRITEBACK STAGE ---------------------------
	
	
	
	
	----------------------- INTERSTAGE SIGNALS ------------------------
end structure;
