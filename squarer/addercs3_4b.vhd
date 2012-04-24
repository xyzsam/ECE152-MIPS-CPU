library ieee;
use ieee.std_logic_1164.all;

-- 3 input 4 bit carry-save adder
entity addercs3_4b is
	port (A, B, C : in std_logic_vector(3 downto 0);
	      S : out std_logic_vector(4 downto 0); -- sum
	      c_out : out std_logic); -- carry
end addercs3_4b;

architecture structure of addercs3_4b is

component adder_5b
	port (A, B : in std_logic_vector(4 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(4 downto 0);
		  c_out : out std_logic);
end component;

signal si : std_logic_vector(4 downto 0); -- inner sum
signal ci : std_logic_vector(4 downto 0); -- inner carry

begin
	
	si(0) <= A(0) xor B(0) xor C(0);
	si(1) <= A(1) xor B(1) xor C(1);
	si(2) <= A(2) xor B(2) xor C(2);
	si(3) <= A(3) xor B(3) xor C(3);
	si(4) <= '0';
	
	ci(0) <= '0';
	ci(1) <= (A(0) and B(0)) or (A(0) and C(0)) or (B(0) and C(0));
	ci(2) <= (A(1) and B(1)) or (A(1) and C(1)) or (B(1) and C(1));
	ci(3) <= (A(2) and B(2)) or (A(2) and C(2)) or (B(2) and C(2));
	ci(4) <= (A(3) and B(3)) or (A(3) and C(3)) or (B(3) and C(3));
	
	adder5b : adder_5b port map(si, ci, '0', S, c_out);

end structure;