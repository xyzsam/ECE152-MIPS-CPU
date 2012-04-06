library ieee;
use ieee.std_logic_1164.all;

entity decode_stage is
	port(clock, reset : in std_logic;
		 keyboard_in, lcd_data : in std_logic_vector(31 downto 0);
		 flush : in std_logic;
		 ID_EX_memRead : in std_logic;
		 ID_EX_rt, ID_EX_rs : in std_logic_vector(4 downto 0);
		 pc_plus_one : in std_logic_vector(31 downto 0);
		 curr_instr : in std_logic_vector(31 downto 0);
		 reg_write_data : in std_logic_vector(31 downto 0);
		 regfile_wren : in std_logic;
		 wb, m, ex : out std_logic;
		 pc_plus_one_out : out std_logic_vector(31 downto 0);
		 regfile_d1, regfile_d2 : out std_logic_vector(31 downto 0);
		 sgn_ext_out : out std_logic_vector(31 downto 0);
		 instr_rt_out, instr_rs_out, instr_rd_out : out std_logic_vector(4 downto 0);
		 IF_ID_wren : out std_logic;
		 
		 ctrl_reg_wren_out, ctrl_reg_input_mux_out, ctrl_sign_ex_mux_out,
		 ctrl_beq_out, ctrl_bgt_out, ctrl_pc_wren_out, ctrl_jump_out, ctrl_jr_out, ctrl_jal_out,
		 ctrl_dmem_wren_out, ctrl_alu_dmem_out, ctrl_keyboard_ack_out, ctrl_lcd_write_out : out std_logic;
		 ctrl_alu_opcode_out : out std_logic_vector(2 downto 0));
end decode_stage;

architecture structure of decode_stage is

component reg32
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
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

component regfile
    port (    clock, ctrl_writeEnable, ctrl_reset : in std_logic;
            ctrl_writeReg, ctrl_readRegA, ctrl_readRegB : in std_logic_vector(4 downto 0);
            data_writeReg    : in std_logic_vector(31 downto 0);
            data_readRegA, data_readRegB : out std_logic_vector(31 downto 0) );
end component;

component sgn_ext
	port (	input 	: in std_logic_vector(16 downto 0);
			output	: out std_logic_vector(31 downto 0));
end component;

component control
     port (instr, keyboard_in, lcd_data : in std_logic_vector(31 downto 0);
           ctrl_reg_wren                : out std_logic;
           ctrl_rt_mux                  : out std_logic;
           ctrl_reg_input_mux		    : out std_logic;
           ctrl_sign_ex_mux             : out std_logic;
           ctrl_alu_opcode		    : out std_logic_vector(2 downto 0);
           ctrl_beq                     : out std_logic;
           ctrl_bgt				    : out std_logic;
           ctrl_pc_wren                 : out std_logic;
		   ctrl_jump			         : out std_logic;
           ctrl_jr                      : out std_logic;
           ctrl_jal                     : out std_logic;
           ctrl_dmem_wren               : out std_logic;
           ctrl_alu_dmem                : out std_logic; -- selects between dmem output or ALU output 
           ctrl_keyboard_ack            : out std_logic;
           ctrl_lcd_write               : out std_logic);

end component;

component hazard_detect
	port (	ID_EX_memRead : in std_logic;
			IF_ID_rs, IF_ID_rt : in std_logic_vector(4 downto 0);
			ID_EX_rs, ID_EX_rt : in std_logic_vector(4 downto 0);
			IF_ID_wren, stall :	out std_logic);
end component;

signal curr_instr_rt, curr_instr_rs, curr_instr_rd : std_logic_vector(4 downto 0);
signal regfile_rs, regfile_rt, regfile_rd : std_logic_vector(4 downto 0);
signal stall : std_logic;

signal ctrl_reg_wren, ctrl_rt_mux, ctrl_reg_input_mux, ctrl_sign_ex_mux, ctrl_beq, ctrl_bgt, ctrl_pc_wren,
	   ctrl_jump, ctrl_jr, ctrl_jal, ctrl_dmem_wren, ctrl_alu_dmem, ctrl_keyboard_ack, ctrl_lcd_write : std_logic;

signal ctrl_alu_opcode : std_logic_vector(2 downto 0);

begin

	curr_instr_imm <= curr_instr(16 downto 0);
	curr_instr_rd <= curr_instr(26 downto 22);
	curr_instr_rs <= curr_instr(21 downto 17);
	curr_instr_rt <= curr_instr(16 downto 12);

	reg_rs_mux: mux2to1_5b port map(curr_instr_rs, curr_instr_rd, ctrl_jr or ctrl_lcd_write, regfile_rs);
	reg_rt_mux: mux2to1_5b port map(curr_instr_rt, curr_instr_rd, ctrl_rt_mux, regfile_rt);
	reg_jal_mux: mux2to1_5b port map(curr_instr_rd, "11111", ctrl_jal, regfile_rd);
	
	-- ctrl muxes
	ctrl_reg_wren_mux: mux2to1_1b port map(ctrl_reg_wren, '0', stall or flush, ctrl_reg_wren_out);
	
	ctrl_reg_input_mux_mux: mux2to1_1b port map(ctrl_reg_input_mux, '0', stall or flush, ctrl_reg_input_mux_out);
	ctrl_sign_ex_mux_mux: mux2to1_1b port map(ctrl_sign_ex_mux, '0', stall or flush, ctrl_sign_ex_mux_out);
	ctrl_beq_mux: mux2to1_1b port map(ctrl_beq, '0', stall or flush, ctrl_beq_out);
	ctrl_bgt_mux: mux2to1_1b port map(ctrl_bgt, '0', stall or flush, ctrl_bgt_out);
	ctrl_pc_wren_mux: mux2to1_1b port map(ctrl_pc_wren, '0', stall or flush, ctrl_pc_wren_out);
	ctrl_jump_mux: mux2to1_1b port map(ctrl_jump, '0', stall or flush, ctrl_jump_out);
	ctrl_jr_mux: mux2to1_1b port map(ctrl_jr, '0', stall or flush, ctrl_jr_out);
	ctrl_jal_mux: mux2to1_1b port map(ctrl_jal, '0', stall or flush, ctrl_jal_out);
	ctrl_dmem_wren_mux: mux2to1_1b port map(ctrl_dmem_wren, '0', stall or flush, ctrl_dmem_wren_out);
	ctrl_alu_dmem_mux: mux2to1_1b port map(ctrl_alu_dmem, '0', stall or flush, ctrl_alu_dmem_out);
	ctrl_keyboard_ack_mux: mux2to1_1b port map(ctrl_keyboard_ack, '0', stall or flush, ctrl_keyboard_ack_out);
	ctrl_lcd_write_mux: mux2to1_1b port map(ctrl_lcd_write, '0', stall or flush, ctrl_lcd_write_out);
	--ctrl_alu_opcode_out
	
	registerfile: regfile port map(clock, regfile_wren, reset, regfile_rd, regfile_rs, regfile_rt,
								   reg_write_data, regfile_d1, regfile_d2);
								   
	sgn_ext_unit: sgn_ext port map(curr_instr_imm, sgn_ext_out);
	
	hazards: hazard_detect port map(ID_EX_memRead, curr_instr_rs, curr_instr_rt, ID_EX_rs, ID_EX_rt);
	
	control_unit : control port map(curr_instr, keyboard_in, lcd_data,
									ctrl_reg_wren,
									ctrl_rt_mux,
									ctrl_reg_input_mux,
									ctrl_sign_ex_mux,
									ctrl_alu_opcode,
									ctrl_beq,
									ctrl_bgt,
									ctrl_pc_wren,
									ctrl_jump,
									ctrl_jr,
									ctrl_jal,
									ctrl_dmem_wren,
									ctrl_alu_dmem,
									ctrl_keyboard_ack,
									ctrl_lcd_write);
									
end structure;