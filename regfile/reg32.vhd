library ieee;
use ieee.std_logic_1164.all;

entity reg32 is
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
end reg32;


architecture structure of reg32 is

component dffe
port (	d   : in std_logic;
        clk  : in std_logic;
        clrn : in std_logic;
        prn  : in std_logic;
        ena  : in std_logic;
        q    : out std_logic);
end component;

signal dff_tri_connector : std_logic_vector(31 downto 0);

begin

	dffe_gen : for i in 0 to 31 generate
		dffe_array : dffe port map(data_writeReg(i), clock, not ctrl_reset, '1', ctrl_writeEnable, data_readReg(i));
	end generate dffe_gen;

end structure;

-- ctrl_output determines whether the data in the register is pushed to the output or not, using the tri-state buffer.