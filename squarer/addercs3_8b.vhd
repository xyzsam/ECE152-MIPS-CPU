library ieee;
use ieee.std_logic_1164.all;

-- 3 input 8 bit carry-save adder
entity addercs3_8b is
	port (A, B, C : in std_logic_vector(7 downto 0);
	      S : out std_logic_vector(8 downto 0); -- sum
	      c_out : out std_logic); -- carry
end addercs3_8b;

architecture structure of addercs3_8b is

component adder_9b
	port (A, B : in std_logic_vector(8 downto 0);
		  c_in : in std_logic;
		  sum : out std_logic_vector(8 downto 0);
		  c_out : out std_logic);
end component;

signal si : std_logic_vector(8 downto 0); -- inner sum
signal ci : std_logic_vector(8 downto 0); -- inner carry

begin
	
	si(0) <= A(0) xor B(0) xor C(0);
	si(1) <= A(1) xor B(1) xor C(1);
	si(2) <= A(2) xor B(2) xor C(2);
	si(3) <= A(3) xor B(3) xor C(3);
	si(4) <= A(4) xor B(4) xor C(4);
	si(5) <= A(5) xor B(5) xor C(5);
	si(6) <= A(6) xor B(6) xor C(6);
	si(7) <= A(7) xor B(7) xor C(7);
	si(8) <= '0';

	
	ci(0) <= '0';
	ci(1) <= (A(0) and B(0)) or (A(0) and C(0)) or (B(0) and C(0));
	ci(2) <= (A(1) and B(1)) or (A(1) and C(1)) or (B(1) and C(1));
	ci(3) <= (A(2) and B(2)) or (A(2) and C(2)) or (B(2) and C(2));
	ci(4) <= (A(3) and B(3)) or (A(3) and C(3)) or (B(3) and C(3));
	ci(5) <= (A(4) and B(4)) or (A(4) and C(4)) or (B(4) and C(4));
	ci(6) <= (A(5) and B(5)) or (A(5) and C(5)) or (B(5) and C(5));
	ci(7) <= (A(6) and B(6)) or (A(6) and C(6)) or (B(6) and C(6));
	ci(8) <= (A(7) and B(7)) or (A(7) and C(7)) or (B(7) and C(7));
	
	adder9b : adder_9b port map(si, ci, '0', S, c_out);

end structure;