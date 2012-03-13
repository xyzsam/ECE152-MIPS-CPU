library ieee;
use ieee.std_logic_1164.all;

entity shifter is
	port (	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift : in std_logic;
			ctrl_shamt		: in std_logic_vector(4 downto 0);
			data_S	: out std_logic_vector(31 downto 0));
end shifter;

architecture structure of shifter is

component shift16
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component shift8
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component shift4
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component shift2
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component shift1
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component mux2to1_shift
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

signal shift16_out : std_logic_vector(31 downto 0);
signal shift8_out : std_logic_vector(31 downto 0);
signal shift4_out : std_logic_vector(31 downto 0);
signal shift2_out : std_logic_vector(31 downto 0);
signal shift1_out : std_logic_vector(31 downto 0);

signal shift8_in : std_logic_vector(31 downto 0);
signal shift4_in : std_logic_vector(31 downto 0);
signal shift2_in : std_logic_vector(31 downto 0);
signal shift1_in : std_logic_vector(31 downto 0);

begin 

	c_shift16: shift16 port map(data_A, ctrl_rightshift, shift16_out);
	c_shift8 : shift8 port map(shift8_in, ctrl_rightshift, shift8_out);
	c_shift4 : shift4 port map(shift4_in, ctrl_rightshift, shift4_out);
	c_shift2 : shift2 port map(shift2_in, ctrl_rightshift, shift2_out);
	c_shift1 : shift1 port map(shift1_in, ctrl_rightshift, shift1_out);
	
	mux2_16 : mux2to1_shift port map(data_A, shift16_out, ctrl_shamt(4), shift8_in);
	mux2_8 :  mux2to1_shift port map(shift8_in, shift8_out, ctrl_shamt(3), shift4_in);
	mux2_4 :  mux2to1_shift port map(shift4_in, shift4_out, ctrl_shamt(2), shift2_in);
	mux2_2 :  mux2to1_shift port map(shift2_in, shift2_out, ctrl_shamt(1), shift1_in);
	mux2_1 :  mux2to1_shift port map(shift1_in, shift1_out, ctrl_shamt(0), data_S);
	
end structure;