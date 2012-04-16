library ieee;
use ieee.std_logic_1164.all;

entity processor is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0);
     
	--IF_cur_instr_db : out std_logic_vector(31 downto 0);
	--IF_cur_instr_pc_db : out std_logic_vector(11 downto 0);
	IF_jump_db : out std_logic;
	ID_jump_db : out std_logic;
	--IF_cur_pc_out_db,
	ID_cur_instr_db, ID_pc_plus_1_db, ID_regfile_d1_db, ID_regfile_d2_db,
       EX_alu_inputA_db, EX_alu_inputB_db,
	EX_alu_output_db, IF_next_pc_db : out std_logic_vector(31 downto 0);
	WB_regfile_data_db : out std_logic_vector(31 downto 0);
               ID_rs_db, ID_rt_db, ID_rd_db, EX_rs_db, EX_rt_db, EX_rd_db, MEM_rd_db, WB_rd_db    : out std_logic_vector(4 downto 0);
               --ID_ctrl_alu_opcode_db    : out std_logic_vector(2 downto 0);
               ID_mem_memw_db, ID_wb_regw_db, MEM_regw_db, WB_regw_db, ID_ctrl_mem_read_db, ID_ctrl_sgn_ext_db, EX_ctrl_sgn_ext_db : out std_logic; 
               MEM_mem_memw_db  : out std_logic;
               ctrl_stall_db, ctrl_flush_db, ctrl_bubble_db : out std_logic;
               ctrl_rt_mux_db : out std_logic_vector(1 downto 0);
               WB_wb_regw_out_db, WB_ctrl_alu_dmem_db : out std_logic; 
               forwardA_db, forwardB_db : out std_logic_vector(1 downto 0)
               
          );
end processor;

architecture structure of processor is

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
			IF_ID_wren : in std_logic;
			pc_out : out std_logic_vector(31 downto 0);
			curr_instr_out : out std_logic_vector(31 downto 0));
end component;

component ID_EX_latch
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
end component;

component EX_MEM_latch
	port (	clock, reset : in std_logic;
			wb_regw_in, mem_memw_in : in std_logic;
			isEqual, isGreaterThan : in std_logic;
			alu_output, regfile_d2_in : in std_logic_vector(31 downto 0);
			pc_plus_1_in, branch_addr : in std_logic_vector(31 downto 0);
			ex_mem_rd_in : in std_logic_vector(4 downto 0);
			reg_kb_mux_in : in std_logic;
			ctrl_kb_ack_in : in std_logic;
            kb_data_in : in std_logic_vector(31 downto 0);
            ctrl_alu_dmem_in : in std_logic;
            ctrl_beq_in, ctrl_bgt_in, ctrl_jal_in : in std_logic; 
			wb_regw_out, mem_memw_out : out std_logic;
			isEqual_out, isGreaterThan_out : out std_logic;
			alu_output_out, regfile_d2_out : out std_logic_vector(31 downto 0);
			pc_plus_1_out, branch_addr_out : out std_logic_vector(31 downto 0);
			ex_mem_rd_out : out std_logic_vector(4 downto 0);
            reg_kb_mux_out : out std_logic;
            ctrl_kb_ack_out : out std_logic;
            kb_data_out : out std_logic_vector(31 downto 0);
            ctrl_alu_dmem_out : out std_logic;
            ctrl_beq_out, ctrl_bgt_out, ctrl_jal_out : out std_logic); 
end component;

component MEM_WB_latch 
	port (	clock, reset : in std_logic;
			wb_regw_in : in std_logic;
			dmem_output_in, alu_output_in, pc_plus_1_in : in std_logic_vector(31 downto 0);
			ex_mem_rd : in std_logic_vector(4 downto 0);
			kb_data_in : in std_logic_vector(31 downto 0);
               ctrl_alu_dmem_in, ctrl_kb_ack_in : in std_logic;
               reg_input_mux_in, ctrl_jal_in : std_logic;
			wb_regw_out : out std_logic;
			dmem_output_out, alu_output_out, pc_plus_1_out : out std_logic_vector(31 downto 0);
			mem_wb_rd : out std_logic_vector(4 downto 0);
			kb_data_out : out std_logic_vector(31 downto 0);
               ctrl_alu_dmem_out, ctrl_kb_ack_out: out std_logic;
               reg_input_mux_out, ctrl_jal_out  : out std_logic);
end component;


component control
     port (    instr : in std_logic_vector(31 downto 0);

               -- regfile controls
               ctrl_reg_wren                 : out std_logic;
               ctrl_rt_mux                 : out std_logic_vector(1 downto 0);
               ctrl_reg_input_mux			: out std_logic;
			   
               -- alu controls 
               ctrl_alu_opcode		         : out std_logic_vector(2 downto 0);
			   ctrl_sign_ex_mux              : out std_logic;
			   
               -- branch controls
               ctrl_beq                       : out std_logic;
               ctrl_bgt						 : out std_logic;
               ctrl_jump			          : out std_logic;
               ctrl_jr                       : out std_logic;
               ctrl_jal                      : out std_logic;

               -- dmem controls
               ctrl_dmem_wren                : out std_logic ;
               ctrl_alu_dmem                 : out std_logic; -- selects between dmem output or ALU output 
			   ctrl_dmem_read			     : out std_logic;
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
			EX_MEM_regwrite, MEM_WB_regwrite, ID_EX_memwrite, EX_MEM_memwrite : in std_logic;
			forward_A, forward_B, forward_data : out std_logic_vector(1 downto 0));
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
signal IF_next_pc, IF_cur_pc_in, IF_cur_pc_out, IF_cur_instr, IF_pc_plus_1, IF_next_pc_imem : std_logic_vector(31 downto 0);
signal one, zero : std_logic_vector(31 downto 0);
signal pc_addend_input : std_logic_vector(31 downto 0);
signal IF_pc_wren, IF_ctrl_jump_or_cont, carryout_useless : std_logic;
--signal IF_mem_memw_in, IF_m_memw_in, IF_ex_memw_in : std_logic; -- mem write enable
--signal IF_wb_regw_in, IF_m_regw_in, IF_ex_regw_in : std_logic; -- regfile write enable

---------------------- DECODE STAGE SIGNALS ----------------------------------
signal ID_pc_plus_1, ID_cur_instr, ID_regfile_d1, ID_regfile_d2,
	   ID_sgn_ext_out: std_logic_vector(31 downto 0);
signal ID_kb_data_in : std_logic_vector(31 downto 0);
signal ID_mem_memw_in, ID_wb_regw_in, ID_ctrl_mem_read, ID_ctrl_sgn_ext : std_logic; -- write enable
signal ID_rs, ID_rt, ID_rd, ID_cur_instr_rd, ID_cur_instr_rs, ID_cur_instr_rt: std_logic_vector(4 downto 0);
signal ID_reg_kb_mux_in, ID_lcd_out, ID_sgn_ext_mux : std_logic;
signal IF_ID_latch_wren : std_logic;
signal ID_ctrl_alu_dmem_in : std_logic;
signal ID_ctrl_kb_ack, ID_kb_ack_out : std_logic;
signal ID_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal ID_cur_instr_imm : std_logic_vector(16 downto 0); 
signal ID_ctrl_beq_in, ID_ctrl_bgt_in, ID_ctrl_jump_in, ID_ctrl_jr_in, ID_ctrl_jal_in  : std_logic; 
signal ID_ctrl_beq_out, ID_ctrl_bgt_out, ID_ctrl_jump_out, ID_ctrl_jr_out, ID_ctrl_jal_out  : std_logic; 
signal ctrl_dmem_wren, ctrl_reg_wren:  std_logic; -- temp signals into muxes
signal ctrl_stall, ctrl_flush, ctrl_bubble : std_logic;
signal ctrl_rt_mux : std_logic_vector(1 downto 0);
signal ctrl_rt_zero : std_logic_vector(4 downto 0);
signal ctrl_bubble_5b : std_logic_vector(4 downto 0);

---------------------- EXECUTE STAGE SIGNALS ---------------------------------
signal EX_regfile_d1, EX_regfile_d2, EX_sgn_ext_out, EX_sgn_ext_mux_out, EX_pc_plus_1: std_logic_vector(31 downto 0);
signal EX_branch_addr, EX_next_pc_br, EX_jr_jal_output, EX_kb_data_in : std_logic_vector(31 downto 0);
signal EX_mem_data : std_logic_vector(31 downto 0);
signal EX_mem_memw_in, EX_wb_regw_in : std_logic; -- write enable
signal EX_mem_memw_out, EX_wb_regw_out : std_logic; -- write enable for next stage
signal EX_mem_read : std_logic;
signal EX_ctrl_sgn_ext : std_logic;
signal EX_isEqual, EX_isGreaterThan : std_logic;
signal forward_A, forward_B, forward_data : std_logic_vector(1 downto 0);
signal ID_EX_rs, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal EX_ctrl_alu_opcode : std_logic_vector(2 downto 0);
signal EX_alu_inputA, EX_alu_inputB, EX_alu_output, EX_kb_data_out, EX_lcd_data_out : std_logic_vector(31 downto 0);
signal EX_kb_ack_in, EX_kb_ack_out, EX_lcd_in : std_logic;
signal EX_reg_kb_mux, EX_ctrl_alu_dmem_in, EX_ctrl_alu_dmem_out : std_logic;
signal EX_ctrl_jump, EX_ctrl_jr, EX_ctrl_jal, EX_ctrl_beq_in, EX_ctrl_bgt_in : std_logic; 

----------------------- MEMORY STAGE SIGNALS ----------------------------------
signal MEM_alu_output, MEM_dmem_output, MEM_kb_data_in, 
		MEM_branch_addr, MEM_regfile_d2_in, MEM_pc_plus_1 : std_logic_vector(31 downto 0);
signal MEM_mem_data : std_logic_vector(31 downto 0);
signal EX_MEM_rd, MEM_WB_rd : std_logic_vector(4 downto 0);
signal MEM_ctrl_beq_in, MEM_ctrl_bgt_in, MEM_ctrl_beq_out, MEM_ctrl_bgt_out : std_logic; 
signal MEM_wb_regw_in, MEM_mem_memw : std_logic;
signal MEM_isEqual, MEM_isGreaterThan : std_logic;
signal MEM_ctrl_alu_dmem_in, MEM_ctrl_kb_ack, MEM_reg_kb_mux : std_logic;
signal MEM_ctrl_jump_in, MEM_ctrl_jr_in, MEM_ctrl_jal : std_logic; 

------------------------ WRITEBACK STAGE SIGNALS -------------------------------
signal WB_dmem_output, WB_kb_data, WB_alu_output, WB_alu_dmem_output, WB_jal_output, WB_regfile_data, WB_pc_plus_1 : std_logic_vector(31 downto 0);
signal ctrl_jump_in, ctrl_jump_out : std_logic;
signal WB_reg_kb_mux, WB_ctrl_alu_dmem, WB_ctrl_kb_ack : std_logic;
signal WB_wb_regw_out, WB_ctrl_jal : std_logic;

------------------------ INTERSTAGE SIGNALS --------------------------------
signal jump_addr : std_logic_vector(31 downto 0);


begin

	------------------- FETCH STAGE  ------------------------

	zero <= "00000000000000000000000000000000";
	one <= "00000000000000000000000000000001"; 
	pc_addend_input_mux : mux2to1_32b port map(one, zero, ctrl_stall, pc_addend_input);
pc_reset_mux : mux2to1_32b port map(IF_next_pc, zero, reset, IF_cur_pc_in);
     pc : reg32 port map(clock, '1', reset, IF_cur_pc_in, IF_cur_pc_out);
    instr_mem: imem port map(IF_cur_pc_in(11 downto 0), '1', clock, IF_cur_instr);
adder_pc_1 : adder port map(pc_addend_input, IF_cur_pc_out, '0', IF_pc_plus_1, carryout_useless);
    jump_or_cont_mux : mux2to1_32b port map(IF_pc_plus_1, jump_addr, IF_ctrl_jump_or_cont, IF_next_pc);
     IF_ctrl_jump_or_cont <= EX_ctrl_jump or EX_ctrl_jr or EX_ctrl_jal or (EX_ctrl_beq_in and EX_isEqual) or (EX_ctrl_bgt_in and EX_isGreaterThan);

	------------------- IF/ID LATCH  -------------------------
     
    IFID_latch : IF_ID_latch port map(not clock, reset,
                                       IF_pc_plus_1, IF_cur_instr, IF_ID_latch_wren,
                                      ID_pc_plus_1, ID_cur_instr);
	
	------------------- DECODE STAGE -------------------------

	ID_cur_instr_imm <= ID_cur_instr(16 downto 0);
	ID_cur_instr_rd <= ID_cur_instr(26 downto 22);
	ID_cur_instr_rs <= ID_cur_instr(21 downto 17);
	ID_cur_instr_rt <= ID_cur_instr(16 downto 12);

    ctrl_bubble <= ctrl_stall or ctrl_flush or EX_ctrl_jump or EX_ctrl_jr or EX_ctrl_jal;
    
    bubble_5b_gen : for i in 0 to 4 generate
		ctrl_bubble_5b(i) <= ctrl_bubble;
	end generate bubble_5b_gen;
    
    ctrl_rt_gen : for i in 0 to 4 generate
		ctrl_rt_zero(i) <= (not ctrl_rt_mux(1)) or ctrl_rt_mux(0);
	end generate ctrl_rt_gen;
	
	reg_rs_mux: mux2to1_5b port map(ID_cur_instr_rs, ID_cur_instr_rd, ID_ctrl_jr_in or ID_lcd_out, ID_rs);
	reg_rt_mux: mux2to1_5b port map(ID_cur_instr_rt and ctrl_rt_zero, ID_cur_instr_rd, (not ctrl_rt_mux(1)) and ctrl_rt_mux(0), ID_rt);
	reg_jal_in_mux: mux2to1_5b port map(ID_cur_instr_rd, "11111", ID_ctrl_jal_in, ID_rd);
	
	-- mem signals
	ID_mem_memw_in <= ctrl_dmem_wren and not ctrl_bubble;
	
	-- wb signals
	ID_wb_regw_in <= ctrl_reg_wren and not ctrl_bubble;
	
	-- ex signals
--    ctrl_pc_wren_mux: mux2to1_1b port map(ctrl_pc_wren, '0', ctrl_bubble, IF_pc_wren);

    -- jump signals
    ID_ctrl_jump_out <= ID_ctrl_jump_in and not ctrl_bubble;
    ID_ctrl_jr_out <= ID_ctrl_jr_in and not ctrl_bubble;
    ID_ctrl_jal_out <= ID_ctrl_jal_in and not ctrl_bubble;

    -- branch signals
	ID_ctrl_beq_out <= ID_ctrl_beq_in and not ctrl_bubble;
	ID_ctrl_bgt_out <= ID_ctrl_bgt_in and not ctrl_bubble;
	
	-- processor output signals	
	ID_kb_ack_out <= ID_ctrl_kb_ack and not ctrl_bubble;
	
	registerfile: regfile port map(clock, WB_wb_regw_out, reset, MEM_WB_rd, ID_rs, ID_rt,
								   WB_regfile_data, ID_regfile_d1, ID_regfile_d2);
								   
	sgn_ext_unit: sgn_ext port map(ID_cur_instr_imm, ID_sgn_ext_out);
	
    hazards: hazard_detect port map(EX_mem_read, ID_rs, ID_rt, ID_EX_rs, ID_EX_rt, IF_ID_latch_wren, ctrl_stall);
	
	control_unit : control port map(ID_cur_instr, 
                                   ctrl_reg_wren, -- this is an input to a mux
                                   ctrl_rt_mux,
                                   ID_reg_kb_mux_in,
                                   ID_ctrl_alu_opcode,
                                   ID_ctrl_sgn_ext,
                                   ID_ctrl_beq_in,
                                   ID_ctrl_bgt_in,
                                   ID_ctrl_jump_in,
                                   ID_ctrl_jr_in,
                                   ID_ctrl_jal_in,
                                   ctrl_dmem_wren, -- this is an input to a mux
                                   ID_ctrl_alu_dmem_in,
                                   ID_ctrl_mem_read,
                                   ID_ctrl_kb_ack,
                                   ID_lcd_out);

    ID_kb_data_in <= keyboard_in;
									
	------------------- ID/EX LATCH ---------------------------
	
	IDEX_latch : ID_EX_latch port map(not clock, reset, 
                                       ID_mem_memw_in, ID_wb_regw_in, ID_ctrl_mem_read,
                                       ID_pc_plus_1,
                                       ID_regfile_d1, ID_regfile_d2,
                                       ID_rs and not ctrl_bubble_5b, ID_rt and not ctrl_bubble_5b, ID_rd and not ctrl_bubble_5b,
                                       ID_sgn_ext_out, ID_kb_data_in, 
                                       ID_reg_kb_mux_in, ID_ctrl_sgn_ext,
                                       ID_kb_ack_out, ID_lcd_out,
                                       ID_ctrl_beq_out, ID_ctrl_bgt_out, ID_ctrl_jump_out, ID_ctrl_jal_out, ID_ctrl_jr_out,
                                       ID_ctrl_alu_dmem_in,
                                       ID_ctrl_alu_opcode,
                                       EX_mem_memw_in, EX_wb_regw_in, EX_mem_read,
                                       EX_pc_plus_1, 
                                       EX_regfile_d1, EX_regfile_d2,
                                       ID_EX_rs, ID_EX_rt, ID_EX_rd,
                                       EX_sgn_ext_out, EX_kb_data_in,
                                       EX_reg_kb_mux, EX_ctrl_sgn_ext,
                                       EX_kb_ack_in, EX_lcd_in,
                                       EX_ctrl_beq_in, EX_ctrl_bgt_in, EX_ctrl_jump, EX_ctrl_jal, EX_ctrl_jr,
                                       EX_ctrl_alu_dmem_in,
                                       EX_ctrl_alu_opcode);

	------------------- EXECUTE STAGE -----------------------
	
	branch_adder : adder port map(EX_pc_plus_1, EX_sgn_ext_out, '0', EX_branch_addr);
	branching_unit : branch_unit port map(EX_isEqual, EX_isGreaterThan, EX_ctrl_beq_in, EX_ctrl_bgt_in, EX_pc_plus_1,
										  EX_branch_addr, EX_next_pc_br, ctrl_flush);
	alu_unit : alu port map(EX_alu_inputA, EX_alu_inputB, EX_ctrl_alu_opcode, EX_alu_output, EX_isEqual, EX_isGreaterThan);
	forward: forward_unit port map(ID_EX_rs, ID_EX_rt, ID_EX_rd, EX_MEM_rd, MEM_WB_rd,
								   MEM_wb_regw_in, WB_wb_regw_out, EX_mem_memw_out, MEM_mem_memw,
								   forward_A, forward_B, forward_data);

	--muxes
	alu_inputA_mux : mux4to1_32b port map(EX_regfile_d1,  MEM_alu_output, 
								  WB_alu_dmem_output, zero, forward_A, EX_alu_inputA);
	alu_inputB_mux : mux4to1_32b port map(EX_sgn_ext_mux_out,  MEM_alu_output, 
								  WB_alu_dmem_output, zero, forward_B, EX_alu_inputB);
	
	EX_wb_regw_out <= EX_wb_regw_in and not ctrl_flush; --wb_ctrl_reg_mux
	EX_mem_memw_out <= EX_mem_memw_in and not ctrl_flush; --mem_ctrl_mem_mux
	
	sgn_ext_mux : mux2to1_32b port map(EX_regfile_d2, EX_sgn_ext_out, EX_ctrl_sgn_ext, EX_sgn_ext_mux_out);
    jr_jal_mux : mux2to1_32b port map(EX_sgn_ext_out, EX_alu_inputA, EX_ctrl_jr, EX_jr_jal_output);
	
	EX_kb_ack_out <= EX_kb_ack_in and not ctrl_flush; -- kb ack
	EX_ctrl_alu_dmem_out <= EX_ctrl_alu_dmem_in and not ctrl_flush; -- alu_dmem
	
	forward_data_mux : mux4to1_32b port map(EX_regfile_d2, MEM_alu_output, WB_alu_dmem_output,
										 zero, forward_data, EX_mem_data);
    lcd_data <= EX_alu_inputA;
    lcd_write <= EX_lcd_in;

	---------------------- EX/MEM LATCH -----------------------------
    EXMEM_latch : EX_MEM_latch port map(not clock, reset,
                                        EX_mem_memw_out, EX_wb_regw_out,
                                        EX_isEqual, EX_isGreaterThan,
                                        EX_alu_output, EX_mem_data,
                                        EX_pc_plus_1, EX_branch_addr, 
                                        ID_EX_rd,
                                        EX_reg_kb_mux,
                                        EX_kb_ack_out,
                                        EX_kb_data_in,
                                        EX_ctrl_alu_dmem_out,
                                        EX_ctrl_beq_in, EX_ctrl_bgt_in, EX_ctrl_jal,
                                        MEM_mem_memw, MEM_wb_regw_in, 
                                        MEM_isEqual, MEM_isGreaterThan,
                                        MEM_alu_output, MEM_mem_data,
                                        MEM_pc_plus_1, MEM_branch_addr,
                                        EX_MEM_rd,
                                        MEM_reg_kb_mux,
                                        MEM_ctrl_kb_ack,
                                        MEM_kb_data_in,
                                        MEM_ctrl_alu_dmem_in,
                                        MEM_ctrl_beq_in, MEM_ctrl_bgt_in, MEM_ctrl_jal);

	
	
	----------------------- MEMORY STAGE ------------------------------

    dmem_unit : dmem port map(MEM_alu_output(11 downto 0), clock, MEM_mem_data, MEM_mem_memw, MEM_dmem_output);
										  
	-- MEM_next_bc_br is assigned a value but never read. Not sure where it goes.
										  
--	EX_MEM_rd_out <= EX_MEM_rd;
	
	
	
	
	----------------------- MEM/WB LATCH ------------------------------

    MEMWB_latch : MEM_WB_latch port map(not clock, reset,
                                         MEM_wb_regw_in, 
                                         MEM_dmem_output, MEM_alu_output, MEM_pc_plus_1,
                                         EX_MEM_rd,
                                         MEM_kb_data_in,
                                         MEM_ctrl_alu_dmem_in, MEM_ctrl_kb_ack,
                                         MEM_reg_kb_mux, MEM_ctrl_jal,
                                         WB_wb_regw_out,
                                         WB_dmem_output, WB_alu_output, WB_pc_plus_1,
                                         MEM_WB_rd,
                                         WB_kb_data,
                                         WB_ctrl_alu_dmem, WB_ctrl_kb_ack,
                                         WB_reg_kb_mux, WB_ctrl_jal);


	
	---------------------- WRITEBACK STAGE ---------------------------
	
	alu_dmem_mux: mux2to1_32b port map(WB_alu_output, WB_dmem_output, WB_ctrl_alu_dmem, WB_alu_dmem_output);
	jal_mux: mux2to1_32b port map(WB_alu_dmem_output, WB_pc_plus_1, WB_ctrl_jal, WB_jal_output);
	keyboard_mux: mux2to1_32b port map(WB_jal_output, WB_kb_data, WB_reg_kb_mux, WB_regfile_data);
     
     keyboard_ack <= WB_ctrl_kb_ack;

     ----------------------- INTERSTAGE COMPONENTS ------------------------
     jump_mux : mux2to1_32b port map(EX_next_pc_br, EX_jr_jal_output, EX_ctrl_jump, jump_addr);
     
    ------------------------- DEBUGGING SIGNAL ASSIGNMENTS ------------------------
	 IF_jump_db <= IF_ctrl_jump_or_cont;
     --IF_cur_instr_pc_db <= IF_cur_pc_in(11 downto 0);
     --IF_cur_instr_db <= IF_cur_instr;
     --IF_cur_pc_out_db <= IF_cur_pc_out;
     ID_jump_db <= ID_ctrl_jr_out;
     ID_cur_instr_db <= ID_cur_instr;
     ID_pc_plus_1_db <= ID_pc_plus_1;
     ID_regfile_d1_db <= ID_regfile_d1;
     ID_regfile_d2_db <= ID_regfile_d2;
     ID_rs_db <= ID_rs;
     ID_rt_db <= ID_rt;
     ID_rd_db <= ID_rd;
     EX_rs_db <= ID_EX_rs;
     EX_rt_db <= ID_EX_rt;
     EX_rd_db <= ID_EX_rd;
     MEM_rd_db <= EX_MEM_rd;
     WB_rd_db <= MEM_WB_rd;
     MEM_regw_db <= MEM_wb_regw_in;
     WB_regw_db <= WB_wb_regw_out;
     --ID_ctrl_alu_opcode_db <= ID_ctrl_alu_opcode;
--     ID_ctrl_beq_db <= ID_ctrl_beq_out;
--    ID_ctrl_bgt_db <= ID_ctrl_bgt_out;
--     ID_ctrl_jump_db <= ID_ctrl_jump_out;
--     ID_ctrl_jal_db <= ID_ctrl_jal_out;
--     ID_ctrl_jr_db <= ID_ctrl_jr_out;
     ID_mem_memw_db <= ID_mem_memw_in;
     ID_wb_regw_db <= ID_wb_regw_in;
     ID_ctrl_mem_read_db <= ID_ctrl_mem_read;
     ID_ctrl_sgn_ext_db <= ID_ctrl_sgn_ext;
     EX_alu_output_db <= EX_alu_output;
     EX_alu_inputA_db <= EX_alu_inputA;
     EX_alu_inputB_db <= EX_alu_inputB;
     EX_ctrl_sgn_ext_db <= EX_ctrl_sgn_ext;
     forwardA_db <= forward_A;
     forwardB_db <= forward_B;
     -- MEM_dmem_output_db <= MEM_dmem_output;
     MEM_mem_memw_db <= MEM_mem_memw;
     -- WB_alu_dmem_output_db <= WB_alu_dmem_output;
     WB_regfile_data_db <= WB_regfile_data;
     --WB_reg_kb_mux_db <= WB_reg_kb_mux;
     WB_wb_regw_out_db <= WB_wb_regw_out;
     WB_ctrl_alu_dmem_db <= WB_ctrl_alu_dmem;
     ctrl_stall_db <= ctrl_stall;
     ctrl_flush_db <= ctrl_flush;
     ctrl_rt_mux_db <= ctrl_rt_mux;
     IF_next_pc_db <= IF_next_pc;
     --jump_addr_db <= jump_addr;
     ctrl_bubble_db <= ctrl_bubble;

end structure;
