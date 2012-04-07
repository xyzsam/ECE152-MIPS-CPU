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
			mem_memw_in, wb_regw_in : in std_logic;
			pc_plus_1_in : in std_logic_vector(31 downto 0);
			regfile_d1, regfile_d2 : in std_logic_vector(31 downto 0);
			instr_rs, instr_rt, instr_rd : in std_logic_vector(4 downto 0);
			sgn_ext_in, wb_kb_data_in, wb_lcd_data_in : in std_logic_vector(31 downto 0);
			wb_reg_kb_mux_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in : in std_logic; 
               wb_ctrl_alu_dmem_in : in std_logic;
			mem_memw_out, wb_regw_out : out std_logic;
			pc_plus_1_out : out std_logic_vector(31 downto 0);
			regfile_d1_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			instr_rs_out, instr_rt_out, instr_rd_out : out std_logic_vector(4 downto 0);
			sgn_ext_out, wb_kb_data_out, wb_lcd_data_out : out std_logic_vector(31 downto 0);
               wb_reg_kb_mux_out, ex_lc_out : out std_logic;
               ctrl_beq_out, ctrl_bgt_out : out std_logic; 
               wb_ctrl_alu_dmem_out : out std_logic);
end component;

component EX_MEM_latch
	port (	clock, reset : in std_logic;
			wb_regw_in, mem_memw_in : in std_logic;
			isEqual, isGreaterThan : in std_logic;
			alu_output, regfile_d2_in : in std_logic_vector(31 downto 0);
			pc_plus_1_in, branch_addr : in std_logic_vector(31 downto 0);
               ctrl_alu_dmem_in : in std_logic;
               ctrl_beq_in, ctrl_bgt_in : in std_logic; 
			wb_regw_out, mem_memw_out : out std_logic;
			isEqual_out, isGreaterThan_out : out std_logic;
			alu_output_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			pc_plus_1_out, branch_addr_out : out std_logic_vector(31 downto 0);
               ctrl_alu_dmem_out : out std_logic;
               ctrl_beq_out, ctrl_bgt_out : out std_logic); 
end component;

component MEM_WB_latch 
	port (	clock, reset : in std_logic;
			wb_regw_in : in std_logic;
			dmem_output_in, alu_output_in, pc_plus_1_in : in std_logic_vector(31 downto 0);
			kb_data_in : in std_logic_vector(31 downto 0);
               ctrl_alu_dmem_in, ctrl_jal_in, ctrl_kb_ack_in : in std_logic;
               reg_input_mux_in : std_logic;
			wb_regw_out : out std_logic;
			dmem_output_out, alu_output_out, pc_plus_1_out : out std_logic_vector(31 downto 0);
			kb_data_out : out std_logic_vector(31 downto 0);
               ctrl_alu_dmem_out, ctrl_jal_out, ctrl_kb_ack_out : out std_logic;
               reg_input_mux_out : out std_logic);
end component;


component control
     port (    instr, keyboard_in, lcd_data : in std_logic_vector(31 downto 0);

               -- regfile controls
               ctrl_reg_wren                 : out std_logic;
               ctrl_rt_mux                 : out std_logic;
               ctrl_reg_input_mux			: out std_logic;
			   
               -- alu controls 
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

component dmem
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

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

component branch_unit
	port (	alu_is_equal, alu_is_greater : in std_logic;
			ctrl_beq, ctrl_bgt : in std_logic;
			pc_plus_1, branch_addr : in std_logic_vector(31 downto 0);
			next_pc_br : out std_logic_vector(31 downto 0);
			flush : out std_logic);
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
--signal IF_mem_memw_in, IF_m_memw_in, IF_ex_memw_in : std_logic; -- mem write enable
--signal IF_wb_regw_in, IF_m_regw_in, IF_ex_regw_in : std_logic; -- regfile write enable

---------------------- DECODE STAGE SIGNALS ----------------------------------
signal ID_pc_plus_1, ID_cur_instr, ID_regfile_d1, ID_regfile_d2,
	   ID_sgn_ext_out: std_logic_vector(31 downto 0);
signal ID_kb_data_in, ID_lcd_data_in : std_logic_vector(31 downto 0);
signal ID_mem_memw_in, ID_wb_regw_in : std_logic; -- write enable
signal ID_rs, ID_rt, ID_rd, ID_cur_instr_rd, ID_cur_instr_rs, ID_cur_instr_rt: std_logic_vector(4 downto 0);
signal ID_reg_kb_mux_in, ID_lcd_out, ID_sgn_ext_mux : std_logic;
signal ID_ctrl_alu_dmem_in : std_logic;
signal ID_ctrl_kb_ack : std_logic;
signal ID_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal ID_cur_instr_imm : std_logic_vector(16 downto 0); 
signal ID_ctrl_beq_in, ID_ctrl_bgt_in, ID_ctrl_jump_in, ID_ctrl_jr_in, ID_ctrl_jal_in  : std_logic; 
signal ctrl_dmem_wren, ctrl_reg_wren : std_logic; -- temp signals into muxes
signal ctrl_stall, ctrl_flush, ctrl_rt_mux, ctrl_pc_wren : std_logic;

---------------------- EXECUTE STAGE SIGNALS ---------------------------------
signal EX_regfile_d1, EX_regfile_d2, EX_sgn_ext_out, EX_sgn_ext_mux_out, EX_pc_plus_1: std_logic_vector(31 downto 0);
signal EX_branch_addr, EX_kb_data_in, EX_lcd_data_in : std_logic_vector(31 downto 0);
signal EX_mem_memw_in, EX_wb_regw_in : std_logic; -- write enable
signal EX_mem_memw_out, EX_wb_regw_out : std_logic; -- write enable for next stage
signal EX_ctrl_sgn_ext, ctrl_flush_ex  : std_logic;
signal EX_isEqual, EX_isGreaterThan : std_logic;
signal forward_A, forward_B : std_logic_vector(1 downto 0);
signal ID_EX_rs, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal EX_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal EX_alu_inputA, EX_alu_inputB, EX_alu_output, EX_kb_data_out, EX_lcd_data_out : std_logic_vector(31 downto 0);
signal EX_kb_ack_in : std_logic;
signal EX_ctrl_alu_dmem_in, EX_ctrl_alu_dmem_out : std_logic;
signal EX_ctrl_jump_in, EX_ctrl_jr_in, EX_ctrl_jal_in, EX_ctrl_beq_in, EX_ctrl_bgt_in : std_logic; 

----------------------- MEMORY STAGE SIGNALS ----------------------------------
signal MEM_alu_output, MEM_dmem_output, MEM_kb_data_in, 
		MEM_branch_addr, MEM_next_pc_br, MEM_regfile_d2_in, MEM_pc_plus_1 : std_logic_vector(31 downto 0);
signal EX_MEM_rd, MEM_WB_rd : std_logic_vector(4 downto 0);
signal MEM_ctrl_beq_in, MEM_ctrl_bgt_in, MEM_ctrl_beq_out, MEM_ctrl_bgt_out : std_logic; 
signal MEM_wb_regw_in, MEM_mem_memw : std_logic;
signal MEM_isEqual, MEM_isGreaterThan : std_logic;
signal MEM_ctrl_alu_dmem_in, MEM_ctrl_kb_ack, MEM_reg_kb_mux : std_logic;
signal MEM_ctrl_jump_in, MEM_ctrl_jr_in, MEM_ctrl_jal_in : std_logic; 

------------------------ WRITEBACK STAGE SIGNALS -------------------------------
signal WB_dmem_output, WB_reg_write_data, WB_kb_data, WB_alu_output, WB_pc_plus_1 , WB_alu_dmem_output, WB_jal_output, WB_regfile_data : std_logic_vector(31 downto 0);
signal ctrl_jump_in, ctrl_jump_out : std_logic;
signal WB_reg_kb_mux, WB_ctrl_alu_dmem, WB_ctrl_kb_ack : std_logic;
signal WB_wb_regw_out : std_logic;
signal WB_ctrl_jal : std_logic; 
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

	reg_rs_mux: mux2to1_5b port map(ID_cur_instr_rs, ID_cur_instr_rd, ID_ctrl_jr_in or ID_lcd_out, ID_rs);
	reg_rt_mux: mux2to1_5b port map(ID_cur_instr_rt, ID_cur_instr_rd, ctrl_rt_mux, ID_rt);
	reg_jal_in_mux: mux2to1_5b port map(ID_cur_instr_rd, "11111", ID_ctrl_jal_in, ID_rd);
	
	-- mem signals
	ctrl_dmem_wren_mux: mux2to1_1b port map(ctrl_dmem_wren, '0', ctrl_stall or ctrl_flush, ID_mem_memw_in);

	-- wb signals
	ctrl_reg_wren_mux: mux2to1_1b port map(ctrl_reg_wren, '0', ctrl_stall or ctrl_flush, ID_wb_regw_in);
	
	-- ex signals
    ctrl_pc_wren_mux: mux2to1_1b port map(ctrl_pc_wren, '0', ctrl_stall or ctrl_flush, IF_pc_wren);
	
	-- processor output signals	
	ctrl_keyboard_ack_mux: mux2to1_1b port map(ID_ctrl_kb_ack, '0', ctrl_stall or ctrl_flush, EX_kb_ack_in);
	
	registerfile: regfile port map(clock, WB_wb_regw_out, reset, ID_rd, ID_rs, ID_rt,
								   WB_reg_write_data, ID_regfile_d1, ID_regfile_d2);
								   
	sgn_ext_unit: sgn_ext port map(ID_cur_instr_imm, ID_sgn_ext_out);
	
	hazards: hazard_detect port map(EX_mem_memw_out, ID_cur_instr_rs, ID_cur_instr_rt, ID_EX_rs, ID_EX_rt);
	
	control_unit : control port map(ID_cur_instr, ID_kb_data_in, ID_lcd_data_in,
                                   ctrl_reg_wren, -- this is an input to a mux
                                   ctrl_rt_mux,
                                   ID_reg_kb_mux_in,
                                   ID_ctrl_alu_opcode,
                                   ID_ctrl_beq_in,
                                   ID_ctrl_bgt_in,
                                   ctrl_pc_wren,
                                   ID_ctrl_jump_in,
                                   ID_ctrl_jr_in,
                                   ID_ctrl_jal_in,
                                   ctrl_dmem_wren, -- this is an input to a mux
                                   WB_ctrl_alu_dmem,
                                   ID_ctrl_kb_ack,
                                   ID_lcd_out);
									
									
	------------------- ID/EX LATCH ---------------------------
	
	IDEX_latch : ID_EX_latch port map(clock, reset, 
                                       ID_mem_memw_in, ID_wb_regw_in,
                                       ID_pc_plus_1,
                                       ID_regfile_d1, ID_regfile_d2,
                                       ID_cur_instr_rs, ID_cur_instr_rt, ID_cur_instr_rd,
                                       ID_sgn_ext_out, ID_kb_data_in, ID_lcd_data_in, 
                                       ID_reg_kb_mux_in,
                                       ID_ctrl_beq_in, ID_ctrl_bgt_in,
                                       WB_ctrl_alu_dmem,
                                       EX_mem_memw_in, EX_wb_regw_in, 
                                       EX_pc_plus_1, 
                                       EX_regfile_d1, EX_regfile_d2,
                                       ID_EX_rs, ID_EX_rt, ID_EX_rd,
                                       EX_sgn_ext_out, EX_kb_data_in, EX_lcd_data_in,
                                       WB_reg_kb_mux,
                                       EX_ctrl_beq_in, EX_ctrl_bgt_in,
                                       EX_ctrl_alu_dmem_in);

	------------------- EXECUTE STAGE -----------------------
	
	branch_adder : adder port map(EX_pc_plus_1, EX_sgn_ext_out, '0', EX_branch_addr);
	alu_unit : alu port map(EX_alu_inputA, EX_alu_inputB, EX_ctrl_alu_opcode, EX_alu_output, EX_isEqual, EX_isGreaterThan);
	forward: forward_unit port map(ID_EX_rs, ID_EX_rt, ID_EX_rd, EX_MEM_rd, MEM_WB_rd,
						      MEM_wb_regw_in, WB_wb_regw_out, forward_A, forward_B);
	--muxes
	alu_inputA_mux : mux4to1_32b port map(EX_regfile_d1,  MEM_alu_output, 
								  WB_dmem_output, zero, forward_A, EX_alu_inputA);
	alu_inputB_mux : mux4to1_32b port map(EX_sgn_ext_mux_out,  MEM_alu_output, 
								  WB_dmem_output, zero, forward_B, EX_alu_inputB);										  
	wb_ctrl_reg_mux : mux2to1_1b port map(EX_wb_regw_in,  '0', ctrl_flush_ex, EX_wb_regw_out);
	mem_ctrl_mem_mux : mux2to1_1b port map(EX_mem_memw_in,  '0', ctrl_flush_ex, EX_mem_memw_out);
--	m_ctrl_reg_mux : mux2to1_1b port map(EX_m_regw_in,  '0', ctrl_flush_ex, EX_m_regw_out);
--	m_ctrl_mem_mux : mux2to1_1b port map(EX_m_memw_in,  '0', ctrl_flush_ex, EX_m_memw_out);
	sgn_ext_mux : mux2to1_32b port map(EX_regfile_d2, EX_sgn_ext_out, EX_ctrl_sgn_ext, EX_sgn_ext_mux_out);
	

	---------------------- EX/MEM LATCH -----------------------------
     EXMEM_latch : EX_MEM_latch port map(clock, reset,
                                         EX_mem_memw_out, EX_wb_regw_out,
                                         EX_isEqual, EX_isGreaterThan,
                                         EX_alu_output, EX_regfile_d2,
                                         EX_pc_plus_1, EX_branch_addr, 
                                         EX_ctrl_alu_dmem_out,
                                         EX_ctrl_beq_in, EX_ctrl_bgt_in,
                                         MEM_mem_memw, MEM_wb_regw_in, 
                                         MEM_isEqual, MEM_isGreaterThan,
                                         MEM_alu_output, MEM_regfile_d2_in,
                                         MEM_pc_plus_1, MEM_branch_addr,
                                         MEM_ctrl_alu_dmem_in,
                                         MEM_ctrl_beq_in, MEM_ctrl_bgt_in);

	
	
	----------------------- MEMORY STAGE ------------------------------

     dmem_unit : dmem port map(MEM_alu_output(11 downto 0), not clock, MEM_regfile_d2_in, MEM_mem_memw, MEM_dmem_output);
	branching_unit : branch_unit port map(MEM_isEqual, MEM_isGreaterThan, MEM_ctrl_beq_in, MEM_ctrl_bgt_in, MEM_pc_plus_1,
										  MEM_branch_addr, MEM_next_pc_br, ctrl_flush);
										  
--	EX_MEM_rd_out <= EX_MEM_rd;
	
	
	
	
	----------------------- MEM/WB LATCH ------------------------------

     MEMWB_latch : MEM_WB_latch port map(clock, reset,
                                         MEM_wb_regw_in, 
                                         MEM_dmem_output, MEM_alu_output, MEM_pc_plus_1,
                                         MEM_kb_data_in,
                                         MEM_ctrl_alu_dmem_in, MEM_ctrl_jal_in, MEM_ctrl_kb_ack,
                                         MEM_reg_kb_mux,
                                         WB_wb_regw_out,
                                         WB_dmem_output, WB_alu_output, WB_pc_plus_1,
                                         WB_kb_data,
                                         WB_ctrl_alu_dmem, WB_ctrl_jal, WB_ctrl_kb_ack,
                                         WB_reg_kb_mux);



	-- WB signals
	--ctrl_alu_dmem_out <= ctrl_alu_dmem;
	--ctrl_jal_out <= ctrl_jal;
	--ctrl_reg_input_mux_out <= ctrl_reg_input_mux;

	--ctrl_keyboard_ack_out <= ctrl_keyboard_ack;
	--ctrl_lcd_write_out <= ctrl_lcd_write;
	
	
	---------------------- WRITEBACK STAGE ---------------------------
	
	alu_dmem_mux: mux2to1_32b port map(WB_alu_output, WB_dmem_output, WB_ctrl_alu_dmem, WB_alu_dmem_output);
	jal_mux: mux2to1_32b port map(WB_alu_dmem_output, WB_pc_plus_1, WB_ctrl_jal, WB_jal_output);
	keyboard_mux: mux2to1_32b port map(WB_jal_output, WB_kb_data, WB_reg_kb_mux, WB_regfile_data);

	----------------------- INTERSTAGE SIGNALS ------------------------

     
end structure;
