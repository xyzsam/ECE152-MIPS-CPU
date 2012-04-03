library ieee;
use ieee.std_logic_1164.all;

-- assumes that branch is not taken. if it is taken, then it flushes the pipeline
entity branch_unit is
	port (	alu_is_equal, alu_is_greater : in std_logic;
			ctrl_beq, ctrl_bgt : in std_logic;
			pc_plus_1, branch_addr : in std_logic_vector(31 downto 0);
			next_pc_br : out std_logic_vector(31 downto 0);
			flush : out std_logic);
end branch_unit;

architecture structure of branch_unit is

component mux2to1_32b
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

signal branch_addr_eq : std_logic_vector(31 downto 0);

begin

	flush <= (alu_is_equal and ctrl_beq) or (alu_is_greater and ctrl_bgt);
	beq_mux: mux2to1_32b port map(pc_plus_1, branch_addr, (alu_is_equal and ctrl_beq), branch_addr_eq);
	bgt_mux: mux2to1_32b port map(branch_addr_eq, branch_addr, (alu_is_greater and ctrl_bgt), next_pc_br);
	
end structure;