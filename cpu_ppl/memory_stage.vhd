library ieee;
use ieee.std_logic_1164.all;

entity memory_stage is
	port(clock : in std_logic;
		 ctrl_alu_dmem, ctrl_jal, ctrl_reg_input_mux : in std_logic; -- wb signals
		 ctrl_dmem_wren, ctrl_beq, ctrl_bgt : in std_logic; -- mem signals
		 ctrl_keyboard_ack, ctrl_lcd_write : in std_logic; -- processor output signals
		 is_equal, is_greater : in std_logic;
		 alu_output : in std_logic_vector(31 downto 0);
		 pc_plus_one : in std_logic_vector(31 downto 0);
		 branch_addr : in std_logic_vector(31 downto 0);
		 dmem_write_data : in std_logic_vector(31 downto 0);
		 EX_MEM_rd : in std_logic_vector(4 downto 0);
		 --meta info
		 ctrl_alu_dmem_out, ctrl_jal_out, ctrl_reg_input_mux_out : out std_logic; -- wb signals
		 ctrl_keyboard_ack_out, ctrl_lcd_write_out : out std_logic; -- processor output signals
		 dmem_output : out std_logic_vector(31 downto 0);
		 alu_output_out : out std_logic_vector(31 downto 0);
		 next_pc_br : out std_logic_vector(31 downto 0);
		 flush : out std_logic;
		 EX_MEM_rd_out : out std_logic_vector(4 downto 0)
		 --meta info
		 );
end memory_stage;

architecture structure of memory_stage is

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

component branch_unit
	port (	alu_is_equal, alu_is_greater : in std_logic;
			ctrl_beq, ctrl_bgt : in std_logic;
			pc_plus_1, branch_addr : in std_logic_vector(31 downto 0);
			next_pc_br : out std_logic_vector(31 downto 0);
			flush : out std_logic);
end component;

begin

	dmem_unit : dmem port map(alu_output(11 downto 0), not clock, dmem_write_data, ctrl_dmem_wren, dmem_output);
	branching_unit : branch_unit port map(is_equal, is_greater, ctrl_beq, ctrl_bgt, pc_plus_one,
										  branch_addr, next_pc_br, flush);
										  
	EX_MEM_rd_out <= EX_MEM_rd;
	
	-- WB signals
	ctrl_alu_dmem_out <= ctrl_alu_dmem;
	ctrl_jal_out <= ctrl_jal;
	ctrl_reg_input_mux_out <= ctrl_reg_input_mux;

	ctrl_keyboard_ack_out <= ctrl_keyboard_ack;
	ctrl_lcd_write_out <= ctrl_lcd_write;

end structure;