library ieee;
use ieee.std_logic_1164.all;

entity processor_ppl is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0));
end processor_ppl;

architecture structure of processor_ppl is

component hazard_detect
	port (	ID_EX_memRead : in std_logic;
			IF_ID_rs, IF_ID_rt : in std_logic_vector(4 downto 0);
			ID_EX_rs, ID_EX_rt : in std_logic_vector(4 downto 0);
			IF_ID_wren, stall :	out std_logic);
end component;

component IF_ID_latch
	port (	clock, reset : in std_logic;
			pc_plus_1 : in std_logic_vector(31 downto 0);
			curr_instr : in std_logic_vector(31 downto 0);
			pc_out : out std_logic_vector(31 downto 0);
			curr_instr_out : out std_logic_vector(31 downto 0));
end component;

component ID_EX_latch
	port (	clock, reset : in std_logic;
			wb_memw_in, wb_regw_in : in std_logic;
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rs, instr_rt, instr_rd : in std_logic_vector(4 downto 0);
			sgn_ext_in : in std_logic_vector(31 downto 0);
			wb_reg_kb_mux_in, ex_lcd_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in, ctrl_jump_in, ctrl_jr_in, ctrl_jal_in : in std_logic; 
               wb_ctrl_alu_dmem_in : in std_logic;
			wb_memw_out, wb_regw_out : out std_logic;
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rs_out, instr_rt_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out : out std_logic_vector(31 downto 0);
               wb_reg_kb_mux_out, ex_lc_out : out std_logic;
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

component control
     port (    instr, keyboard_in, lcd_data : in std_logic_vector(31 downto 0);

               -- regfile controls
               ctrl_reg_wren                 : out std_logic;
               ctrl_rt_mux                 : out std_logic;
               ctrl_reg_input_mux			: out std_logic;
			   
               -- alu controls 
               ctrl_sign_ex_mux              : out std_logic;
               ctrl_alu_opcode		     : out std_logic_vector(2 downto 0);

               -- branch controls
               ctrl_beq                       : out std_logic;
               ctrl_bgt						 : out std_logic;
               ctrl_pc_wren                  : out std_logic; -- kept but unused
               ctrl_jump			          : out std_logic;
               ctrl_jr                       : out std_logic;
               ctrl_jal                      : out std_logic;

               -- dmem controls
               ctrl_dmem_wren                : out std_logic ;
               ctrl_alu_dmem                 : out std_logic; -- selects between dmem output or ALU output 

               -- other controls
               ctrl_keyboard_ack             : out std_logic;
               ctrl_lcd_write                : out std_logic);
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

component mux2to1_5b
	port (	in0, in1	: in std_logic_vector(4 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(4 downto 0));
end component;

component mux2to1_1b is
	port (	in0, in1	: in std_logic;
			ctrl_select	: in std_logic;
			data_out	: out std_logic);
end component;

component sgn_ext
	port (	input 	: in std_logic_vector(16 downto 0);
			output	: out std_logic_vector(31 downto 0));
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

component regfile
    port (  clock, ctrl_writeEnable, ctrl_reset : in std_logic;
            ctrl_writeReg, ctrl_readRegA, ctrl_readRegB : in std_logic_vector(4 downto 0);
            data_writeReg    : in std_logic_vector(31 downto 0);
            data_readRegA, data_readRegB : out std_logic_vector(31 downto 0) );
end component;

---------------------- FETCH STAGE SIGNALS -----------------------------------
signal IF_next_pc, IF_cur_pc_in, IF_cur_pc_out, IF_cur_instr, IF_pc_plus_1 : std_logic_vector(31 downto 0);
signal one, zero : std_logic_vector(31 downto 0);
signal IF_pc_wren, carryout_useless : std_logic;
--signal IF_wb_memw_in, IF_m_memw_in, IF_ex_memw_in : std_logic; -- mem write enable
--signal IF_wb_regw_in, IF_m_regw_in, IF_ex_regw_in : std_logic; -- regfile write enable

---------------------- DECODE STAGE SIGNALS ----------------------------------
signal ID_pc_plus_1, ID_cur_instr, ID_regfile_d1, ID_regfile_d2,
	   ID_sgn_ext_out: std_logic_vector(31 downto 0);
signal ID_kb_data_in, ID_lcd_data_in : std_logic_vector(31 downto 0);
signal ID_wb_memw_in, ID_wb_regw_in : std_logic; -- write enable
signal ID_rs, ID_rt, ID_rd, ID_cur_instr_rd, ID_cur_instr_rs, ID_cur_instr_rt: std_logic_vector(4 downto 0);
signal ID_reg_kb_mux_in, ID_lcd_out : std_logic;
signal ID_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal ID_cur_instr_imm : std_logic_vector(16 downto 0); 
signal ctrl_jr_in, ctrl_jal_in, ctrl_jr_out, ctrl_jal_out: std_logic;
signal ctrl_dmem_wren, ctrl_reg_wren : std_logic; -- temp signals into muxes
signal ctrl_stall, ctrl_flush, ctrl_keyboard_ack, ctrl_rt_mux, ctrl_pc_wren : std_logic;

---------------------- EXECUTE STAGE SIGNALS ---------------------------------
signal EX_regfile_d1, EX_regfile_d2, EX_sgn_ext_out, EX_sgn_ext_mux_out, EX_pc_plus_1: std_logic_vector(31 downto 0);
signal EX_branch_addr, EX_kb_data_in, EX_lcd_data_in : std_logic_vector(31 downto 0);
signal EX_wb_memw_in, EX_wb_regw_in : std_logic; -- write enable
signal EX_wb_memw_out, EX_wb_regw_out : std_logic; -- write enable for next stage
signal EX_ctrl_sgn_ext, ctrl_flush_ex  : std_logic;
signal isEqual, isGreaterThan : std_logic;
signal forward_A, forward_B : std_logic_vector(1 downto 0);
signal ID_EX_rs, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal EX_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal EX_alu_inputA, EX_alu_inputB, EX_alu_output, EX_kb_data_out, EX_lcd_data_out : std_logic_vector(31 downto 0);
signal EX_lcd_out, EX_kb_ack_in, EX_kb_ack_out : std_logic;

----------------------- MEMORY STAGE SIGNALS ----------------------------------
signal mem_alu_output, dmem_output_out, MEM_kb_data_in, MEM_lcd_data_in, MEM_kb_data_out, MEM_lcd_data_out : std_logic_vector(31 downto 0);
signal EX_MEM_rd, MEM_WB_rd : std_logic_vector(4 downto 0);
signal ctrl_beq_in, ctrl_bgt_in, ctrl_beq_out, ctrl_bgt_out : std_logic; 

------------------------ WRITEBACK STAGE SIGNALS -------------------------------
signal WB_dmem_output, WB_reg_write_data, WB_kb_data_out, WB_lcd_data_out : std_logic_vector(31 downto 0);
signal ctrl_jump_in, ctrl_jump_out : std_logic;
signal WB_reg_kb_mux_in, WB_reg_kb_mux_out : std_logic;
signal WB_ctrl_alu_dmem_in, WB_ctrl_alu_dmem_out : std_logic;
signal WB_wb_regw_out, WB_wb_memw_out : std_logic;

begin

	------------------- FETCH STAGE  ------------------------

	zero <= "00000000000000000000000000000000";
	one <= "00000000000000000000000000000001"; 
	pc_reset_mux : mux2to1_32b port map(IF_next_pc, zero, reset, IF_cur_pc_in);
     pc : reg32 port map(clock, IF_pc_wren, reset, IF_cur_pc_in, IF_cur_pc_out);
    instr_mem: imem port map(IF_cur_pc_in(11 downto 0), '1', clock, IF_cur_instr); 
	adder_pc_1  : adder port map(one, IF_cur_pc_out, '0', IF_pc_plus_1, carryout_useless);
	
	
	------------------- IF/ID LATCH  -------------------------
     
    IFID_latch : IF_ID_latch port map(clock, reset,
                                      IF_cur_pc_out, IF_cur_instr,
                                      ID_pc_plus_1, ID_cur_instr);
	
	------------------- DECODE STAGE -------------------------

	ID_cur_instr_imm <= ID_cur_instr(16 downto 0);
	ID_cur_instr_rd <= ID_cur_instr(26 downto 22);
	ID_cur_instr_rs <= ID_cur_instr(21 downto 17);
	ID_cur_instr_rt <= ID_cur_instr(16 downto 12);

	reg_rs_mux: mux2to1_5b port map(ID_cur_instr_rs, ID_cur_instr_rd, ctrl_jr_in or ID_lcd_out, ID_rs);
	reg_rt_mux: mux2to1_5b port map(ID_cur_instr_rt, ID_cur_instr_rd, ctrl_rt_mux, ID_rt);
	reg_jal_in_mux: mux2to1_5b port map(ID_cur_instr_rd, "11111", ctrl_jal_in, ID_rd);
	
	-- mem signals
	ctrl_dmem_wren_mux: mux2to1_1b port map(ctrl_dmem_wren, '0', ctrl_stall or ctrl_flush, ID_wb_memw_in);
	--ctrl_beq_mux: mux2to1_1b port map(ctrl_beq, '0', ctrl_stall or ctrl_flush, ctrl_beq_out);
	--ctrl_bgt_mux: mux2to1_1b port map(ctrl_bgt, '0', ctrl_stall or ctrl_flush, ctrl_bgt_out);

	-- wb signals
--	ctrl_jal_in_mux: mux2to1_1b port map(ctrl_jal_in, '0', ctrl_stall or ctrl_flush, ctrl_jal_in_out);
--	ctrl_reg_input_mux_mux: mux2to1_1b port map(ctrl_reg_input_mux, '0', ctrl_stall or ctrl_flush, ctrl_reg_input_mux_out);
--	ctrl_alu_dmem_mux: mux2to1_1b port map(ctrl_alu_dmem, '0', ctrl_stall or ctrl_flush, ctrl_alu_dmem_out);
	ctrl_reg_wren_mux: mux2to1_1b port map(ctrl_reg_wren, '0', ctrl_stall or ctrl_flush, ID_wb_regw_in);
	
	-- ex signals
--	ctrl_sign_ex_mux_mux: mux2to1_1b port map(ctrl_sign_ex_mux, '0', ctrl_stall or ctrl_flush, ctrl_sign_ex_mux_out);
    ctrl_pc_wren_mux: mux2to1_1b port map(ctrl_pc_wren, '0', ctrl_stall or ctrl_flush, IF_pc_wren);
--	ctrl_jump_in_mux: mux2to1_1b port map(ctrl_jump_in, '0', ctrl_stall or ctrl_flush, ctrl_jump_in_out);
--	ctrl_jr_in_mux: mux2to1_1b port map(ctrl_jr_in, '0', ctrl_stall or ctrl_flush, ctrl_jr_in_out);
	
	-- processor output signals	
	ctrl_keyboard_ack_mux: mux2to1_1b port map(ctrl_keyboard_ack, '0', ctrl_stall or ctrl_flush, EX_kb_ack_in);
	EX_lcd_in_mux: mux2to1_1b port map(ID_lcd_out, '0', ctrl_stall or ctrl_flush, EX_lcd_out);
	
	registerfile: regfile port map(clock, WB_wb_regw_out, reset, ID_rd, ID_rs, ID_rt,
								   WB_reg_write_data, ID_regfile_d1, ID_regfile_d2);
								   
	sgn_ext_unit: sgn_ext port map(ID_cur_instr_imm, EX_sgn_ext_out);
	
	hazards: hazard_detect port map(EX_wb_memw_out, ID_cur_instr_rs, ID_cur_instr_rt, ID_EX_rs, ID_EX_rt);
	
	control_unit : control port map(ID_cur_instr, ID_kb_data_in, ID_lcd_data_in,
                                   ctrl_reg_wren, -- this is an input to a mux
                                   ctrl_rt_mux,
                                   ID_reg_kb_mux_in,
                                   ID_sgn_ext_out,
                                   ID_ctrl_alu_opcode,
                                   ctrl_beq_in,
                                   ctrl_bgt_in,
                                   ctrl_pc_wren,
                                   ctrl_jump_in,
                                   ctrl_jr_in,
                                   ctrl_jal_in,
                                   ctrl_dmem_wren, -- this is an input to a mux
                                   WB_ctrl_alu_dmem_in,
                                   ctrl_keyboard_ack,
                                   ID_lcd_out);
									
									
	------------------- ID/EX LATCH ---------------------------
	
	IDEX_latch : ID_EX_latch port map(clock, reset, 
                                       ID_wb_memw_in, ID_wb_regw_in,
                                       ID_pc_plus_1,
                                       ID_regfile_d1, ID_regfile_d2,
                                       ID_cur_instr_rs, ID_cur_instr_rt, ID_cur_instr_rd,
                                       ID_sgn_ext_out, ID_kb_data_in, ID_lcd_data_in, 
                                       WB_reg_kb_mux_in,
                                       ctrl_beq_in, ctrl_bgt_in, ctrl_jump_in, ctrl_jr_in, ctrl_jal_in,
                                       WB_ctrl_alu_dmem_in,
                                       EX_wb_memw_in, EX_wb_regw_in, 
                                       EX_pc_plus_1, 
                                       EX_regfile_d1, EX_regfile_d2,
                                       ID_EX_rs, ID_EX_rt, ID_EX_rd,
                                       EX_sgn_ext_out, EX_kb_data_in, EX_lcd_data_in,
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
