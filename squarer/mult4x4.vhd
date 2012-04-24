library ieee;
use ieee.std_logic_1164.all;

entity mult4x4 is
	port (operandA, operandB : in std_logic_vector(3 downto 0);
		  product			 : out std_logic_vector(7 downto 0));
end mult4x4;

architecture structure of mult4x4 is

component mult2x2
	port (A, B : in std_logic_vector(1 downto 0);
		  R			 : out std_logic_vector(3 downto 0));
end component;

component addercs3_4b
	port (A, B, C : in std_logic_vector(3 downto 0);
	      S : out std_logic_vector(4 downto 0); 
	      c_out : out std_logic); 
end component;

component adder_4b
	port (A, B : in std_logic_vector(3 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(3 downto 0);
		  c_out : out std_logic);
end component;

signal r0, r1, r2, r3, r0_temp, r2_temp, prod_upper : std_logic_vector(3 downto 0);
signal addercs_sum : std_logic_vector(4 downto 0);
signal addercs_carry, adder_4b_carry : std_logic;

begin

	mult2x2_0 : mult2x2 port map(operandA(1 downto 0), operandB(1 downto 0), r0);
	mult2x2_1 : mult2x2 port map(operandA(1 downto 0), operandB(3 downto 2), r1);
	mult2x2_2 : mult2x2 port map(operandA(3 downto 2), operandB(1 downto 0), r2);
	mult2x2_3 : mult2x2 port map(operandA(3 downto 2), operandB(3 downto 2), r3);

	r0_temp(3 downto 2) <= "00";
	r0_temp(1 downto 0) <= r0(3 downto 2);
	
	addercs : addercs3_4b port map(r0_temp, r1, r2, addercs_sum, addercs_carry);
	
	r2_temp(2 downto 0) <= addercs_sum(4 downto 2);
	r2_temp(3) <= '0';
	
	adder4b : adder_4b port map(r3, r2_temp, '0', prod_upper, adder_4b_carry);
	product(7 downto 4) <= prod_upper;
	product(3 downto 2) <= addercs_sum(1 downto 0);
	product(1 downto 0) <= r0(1 downto 0);
	
end structure;