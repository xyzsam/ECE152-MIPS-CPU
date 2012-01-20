library ieee;
use ieee.std_logic_1164.all;

entity regfile is
    port (    clock, ctrl_writeEnable, ctrl_reset : in std_logic;
            ctrl_writeReg, ctrl_readRegA, ctrl_readRegB : in std_logic_vector(4 downto 0);
            data_writeReg    : in std_logic_vector(31 downto 0);
            data_readRegA, data_readRegB : out std_logic_vector(31 downto 0) );
end regfile;

architecture structure of regfile is

component reg32
port (    clock, ctrl_writeEnable, ctrl_reset : in std_logic;
        data_writeReg : in std_logic_vector(31 downto 0);
        data_readReg : out std_logic_vector(31 downto 0));
end component;

component mux32to1
port (in0, in1, in2, in3, in4, in5, in6, in7,
      in8, in9, in10, in11, in12, in13, in14, in15,
      in16, in17, in18, in19, in20, in21, in22, in23,
      in24, in25, in26, in27, in28, in29, in30, in31 : in std_logic_vector(31 downto 0);
      ctrl  : in std_logic_vector(4 downto 0);
      output: out std_logic_vector(31 downto 0));
end component;

component decoder32to1
port (input : in std_logic_vector(4 downto 0);
      output : out std_logic_vector(31 downto 0));
end component;

-- bus over which the output of the registers is sent to the one hot decoder.
type input_reg_mux is array(0 to 31) of std_logic_vector(31 downto 0);
signal ctrl_read  : input_reg_mux;

-- output of the 5 to 32 decoder, which determines which register is being written to.
signal write_ena_mask : std_logic_vector(31 downto 0);

-- indicates which register to enable reading output from
signal ctrl_output : std_logic_vector(31 downto 0);

signal output_A : std_logic_vector(31 downto 0);
signal output_B : std_logic_vector(31 downto 0);

-- true if the ctrl_writeReg does not refer to $r0, otherwise false
signal register0 : std_logic;

begin
	
	register0 <= not (ctrl_writeReg(0) or ctrl_writeReg(1) or ctrl_writeReg(2) or ctrl_writeReg(3) or ctrl_writeReg(4));

    reg_gen: for i in 0 to 31 generate
        reg_arr : reg32 port map (clock, (ctrl_writeEnable and write_ena_mask(i) and (not register0)),
                                      ctrl_reset and register0, data_writeReg, ctrl_read(i));
    end generate reg_gen;
   
    mux_1 : mux32to1 port map (ctrl_read(0), ctrl_read(1), ctrl_read(2), ctrl_read(3),
                                ctrl_read(4), ctrl_read(5), ctrl_read(6), ctrl_read(7),
                                        ctrl_read(8), ctrl_read(9), ctrl_read(10), ctrl_read(11),
                                        ctrl_read(12), ctrl_read(13), ctrl_read(14), ctrl_read(15),
                                        ctrl_read(16), ctrl_read(17), ctrl_read(18), ctrl_read(19),
                                        ctrl_read(20), ctrl_read(21), ctrl_read(22), ctrl_read(23),
                                        ctrl_read(24), ctrl_read(25), ctrl_read(26), ctrl_read(27),
                                        ctrl_read(28), ctrl_read(29), ctrl_read(30), ctrl_read(31),
                                        ctrl_readRegA, data_readRegA);
    mux_2 : mux32to1 port map (ctrl_read(0), ctrl_read(1), ctrl_read(2), ctrl_read(3),
                                        ctrl_read(4), ctrl_read(5), ctrl_read(6), ctrl_read(7),
                                        ctrl_read(8), ctrl_read(9), ctrl_read(10), ctrl_read(11),
                                        ctrl_read(12), ctrl_read(13), ctrl_read(14), ctrl_read(15),
                                        ctrl_read(16), ctrl_read(17), ctrl_read(18), ctrl_read(19),
                                        ctrl_read(20), ctrl_read(21), ctrl_read(22), ctrl_read(23),
                                        ctrl_read(24), ctrl_read(25), ctrl_read(26), ctrl_read(27),
                                        ctrl_read(28), ctrl_read(29), ctrl_read(30), ctrl_read(31),
                                        ctrl_readRegB, data_readRegB);
    
    decoder5to32 : decoder32to1 port map(ctrl_writeReg, write_ena_mask);       
                                
end structure;
