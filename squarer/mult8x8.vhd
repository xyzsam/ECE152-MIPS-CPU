library ieee;
use ieee.std_logic_1164.all;

entity mult8x8 is
	port (A, B : in std_logic_vector(7 downto 0);
		  P  : out std_logic_vector(15 downto 0));
end mult8x8;

architecture structure of mult8x8 is

component mult4x4
	port (operandA, operandB : in std_logic_vector(3 downto 0);
		  product			 : out std_logic_vector(7 downto 0));
end component;

component addercs3_8b
	port (A, B, C : in std_logic_vector(7 downto 0);
	      S : out std_logic_vector(8 downto 0); -- sum
	      c_out : out std_logic); -- carry
end component;

component adder_9b
	port (A, B : in std_logic_vector(8 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(8 downto 0);
		  c_out : out std_logic);
end component;

component CLA8bit
	port(data_A : in std_logic_vector(7 downto 0);
		 data_B : in std_logic_vector(7 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(7 downto 0);
		 c_out  : out std_logic);
end component;

signal r0, r1, r2, r3, r0_temp, r2_temp, prod_upper : std_logic_vector(7 downto 0);
signal addercs_sum : std_logic_vector(8 downto 0);
signal addercs_carry, adder_8b_carry: std_logic;

begin

	mult4x4_0 : mult4x4 port map(A(3 downto 0), B(3 downto 0), r0);
	mult4x4_1 : mult4x4 port map(A(3 downto 0), B(7 downto 4), r1);
	mult4x4_2 : mult4x4 port map(A(7 downto 4), B(3 downto 0), r2);
	mult4x4_3 : mult4x4 port map(A(7 downto 4), B(7 downto 4), r3);
	
	r0_temp(7 downto 4) <= "0000";
	r0_temp(3 downto 0) <= r0(7 downto 4);
	
	addercs3 : addercs3_8b port map(r2, r1, r0_temp, addercs_sum, addercs_carry);

	r2_temp(4 downto 0) <= addercs_sum(8 downto 4);
	r2_temp(7 downto 5) <= "000";
	
	adder8b : CLA8bit port map(r3, r2_temp, '0', prod_upper, adder_8b_carry);
	P(15 downto 8) <= prod_upper;
	P(7 downto 4) <= addercs_sum(3 downto 0);
	P(3 downto 0) <= r0(3 downto 0);
	
end structure;