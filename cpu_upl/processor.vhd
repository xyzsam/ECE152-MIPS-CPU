library ieee;
use ieee.std_logic_1164.all;

entity processor is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0));
end processor;

architecture structure of processor is

component imem
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

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

component shift2
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
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

component mux2to1
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

component control
     port (    instr     					 : in std_logic_vector(31 downto 0);
               ctrl_reg_wren                 : out std_logic;
               ctrl_dest_mux                 : out std_logic;
               ctrl_sign_ex_mux              : out std_logic;
               ctrl_alu_opcode				 : out std_logic_vector(2 downto 0);
               ctrl_subtract				 : out std_logic;
               ctrl_br                       : out std_logic;
               ctrl_pc_wren                  : out std_logic;
               ctrl_rightshift               : out std_logic;
               ctrl_dmem_wren                : out std_logic ;
               ctrl_output                   : out std_logic); -- selects between dmem output or ALU output 
end component;

component sgn_ext
	port (	input 	: in std_logic_vector(15 downto 0);
			output	: out std_logic_vector(31 downto 0));
end component;

component regfile
    port (    clock, ctrl_writeEnable, ctrl_reset : in std_logic;
            ctrl_writeReg, ctrl_readRegA, ctrl_readRegB : in std_logic_vector(4 downto 0);
            data_writeReg    : in std_logic_vector(31 downto 0);
            data_readRegA, data_readRegB : out std_logic_vector(31 downto 0) );
end component;

signal    cur_pc_in, cur_pc_out,
          pc_plus_1, 
          cur_instr, cur_instr_jump,
          jump_addr,
          sgn_ext_out, sgn_ext_shift,
          branch_addr, br_or_j_addr,
          regfile_d1, regfile_d2, regfile_write,
          alu_output,
          dmem_output : std_logic_vector(31 downto 0);

signal    cur_instr_rs, cur_instr_rt, 
          cur_instr_rd, regfile_dest : std_logic_vector(4 downto 0);

signal    cur_instr_imm  : std_logic_vector(16 downto 0);

signal    cur_instr_jump_27   : std_logic_vector(26 downto 0);

signal    ctrl_reg_wren, ctrl_dest_mux, 
          ctrl_sign_ex_mux, ctrl_subtract,
          ctrl_br, ctrl_pc_wren, 
          ctrl_rightshift, ctrl_dmem_wren,
          ctrl_output    : out std_logic; 

signal    ctrl_alu_opcode : out std_logic_vector(2 downto 0);

begin


     pc : reg32 port map(clock, ctrl_pc_wren, reset, cur_pc_in, cur_pc_out);
     instr_mem: imem port map(cur_pc_in, '1', clock, cur_instr); -- might fail to compile
     registerfile : 

end structure;
