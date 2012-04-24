library ieee;
use ieee.std_logic_1164.all;

entity adder is
	port (	data_addendA, data_addendB	: in std_logic_vector(31 downto 0);
			ctrl_subtract				: in std_logic;
			data_sum					: out std_logic_vector(31 downto 0);
			data_carryout				: out std_logic);
end adder;

architecture structure of adder is

component CLA16bit
	port (data_A, data_B : in std_logic_vector(15 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(15 downto 0);
		  c_out : out std_logic);
end component;

component mux2to1_add
	port (	in0, in1	: in std_logic_vector(15 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(15 downto 0));
end component;

signal data_addendB_new  : std_logic_vector(31 downto 0);
signal sum_bottom, sum_top0, sum_top1, sum_top_sel : std_logic_vector(15 downto 0);
signal c_bottom, c_top0, c_top1	: std_logic;

begin

	flip_gen: for i in 0 to 31 generate
		data_addendB_new(i) <= ((not ctrl_subtract) and data_addendB(i)) or (ctrl_subtract and (not data_addendB(i)));
	end generate flip_gen;
	
	adder_bottom : CLA16bit port map(data_addendA(15 downto 0), data_addendB_new(15 downto 0), ctrl_subtract, sum_bottom, c_bottom);
	adder_top_0  : CLA16bit port map(data_addendA(31 downto 16), data_addendB_new(31 downto 16), '0', sum_top0, c_top0);
	adder_top_1  : CLA16bit port map(data_addendA(31 downto 16), data_addendB_new(31 downto 16), '1', sum_top1, c_top1);

	mux_sum		 : mux2to1_add  port map(sum_top0, sum_top1, c_bottom, sum_top_sel);
	data_carryout <= (c_bottom and c_top1) or ((not c_bottom) and c_top0);
	
	data_sum(15 downto 0) <= sum_bottom;
	data_sum(31 downto 16) <= sum_top_sel;
	
end structure;