library ieee;
use ieee.std_logic_1164.all;

entity writeback_stage is
	port(kb_input : in std_logic_vector(31 downto 0);
		 ctrl_alu_dmem, ctrl_jal, ctrl_reg_input_mux, ctrl_reg_wren : in std_logic; -- wb signals
		 ctrl_keyboard_ack, ctrl_lcd_write : in std_logic; -- processor output signals
		 pc_plus_one : in std_logic_vector(31 downto 0);
		 dmem_output : in std_logic_vector(31 downto 0);
		 alu_output : in std_logic_vector(31 downto 0);
		 MEM_WB_rd : in std_logic_vector(4 downto 0);
		 wb_data : out std_logic_vector(31 downto 0);
		 ctrl_keyboard_ack_out, ctrl_lcd_write_out : out std_logic; -- processor output signals
		 ctrl_reg_wren_out : out std_logic;
		 MEM_WB_rd_out : out std_logic_vector(4 downto 0));
end writeback_stage;

architecture structure of writeback_stage is

component mux2to1_32b
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

signal alu_dmem_out, wb_temp : std_logic_vector(31 downto 0);

begin

	alu_dmem_mux: mux2to1_32b port map(alu_output, dmem_output, ctrl_alu_dmem, alu_dmem_out);
	jal_mux: mux2to1_32b port map(alu_dmem_out, pc_plus_one, ctrl_jal, wb_temp);
	keyboard_mux: mux2to1_32b port map(wb_temp, kb_input, ctrl_reg_input_mux, wb_data);

	MEM_WB_rd_out <= MEM_WB_rd;
	
	ctrl_reg_wren_out <= ctrl_reg_wren;
	
end structure;