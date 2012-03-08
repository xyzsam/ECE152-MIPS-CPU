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

begin


end structure;