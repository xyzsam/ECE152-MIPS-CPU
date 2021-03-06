library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_latch is
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
end MEM_WB_latch;

architecture structure of MEM_WB_latch is

component reg32
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
end component;

component dffe
port (	d   : in std_logic;
        clk  : in std_logic;
        clrn : in std_logic;
        prn  : in std_logic;
        ena  : in std_logic;
        q    : out std_logic);
end component;

signal ex_mem_rd32, mem_wb_rd32 : std_logic_vector(31 downto 0);

begin

	ex_mem_rd32(31 downto 5) <= "000000000000000000000000000";
	ex_mem_rd32(4 downto 0) <= ex_mem_rd;
	mem_wb_rd <= mem_wb_rd32(4 downto 0);
	
	wb_regw_dffe : dffe port map(wb_regw_in, clock, not reset, '1', '1', wb_regw_out);
	ctrl_alu_dmem_dffe : dffe port map(ctrl_alu_dmem_in, clock, not reset, '1', '1', ctrl_alu_dmem_out);
	kb_ack_dffe : dffe port map(ctrl_kb_ack_in, clock, not reset, '1', '1', ctrl_kb_ack_out);
	reg_input_dffe : dffe port map(reg_input_mux_in, clock, not reset, '1', '1', reg_input_mux_out);
	kb_data_reg : reg32 port map(clock, '1', reset, kb_data_in, kb_data_out);
        ctrl_jal_dffe : dffe port map(ctrl_jal_in, clock, not reset, '1', '1', ctrl_jal_out);	

	rd_reg : reg32 port map(clock, '1', reset, ex_mem_rd32, mem_wb_rd32);
	dmem_output_reg : reg32 port map(clock, '1', reset, dmem_output_in, dmem_output_out);
	alu_output_reg : reg32 port map(clock, '1', reset, alu_output_in, alu_output_out);
        pc_plus_1_reg : reg32 port map(clock, '1', reset, pc_plus_1_in, pc_plus_1_out);	
	
end structure;
