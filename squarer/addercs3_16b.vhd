library ieee;
use ieee.std_logic_1164.all;

-- 3 input 6 bit carry-save adder
entity addercs3_16b is
	port (A, B, C : in std_logic_vector(15 downto 0);
	      S : out std_logic_vector(16 downto 0); -- sum
	      c_out : out std_logic); -- carry
end addercs3_16b;

architecture structure of addercs3_16b is

component adder_17b
	port(data_A : in std_logic_vector(16 downto 0);
		 data_B : in std_logic_vector(16 downto 0);
		 c_in : in std_logic;
		 sum    : out std_logic_vector(16 downto 0);
		 c_out  : out std_logic);
end component;

signal si : std_logic_vector(16 downto 0); -- inner sum
signal ci : std_logic_vector(16 downto 0); -- inner carry

begin
	
	si(0) <= A(0) xor B(0) xor C(0);
	si(1) <= A(1) xor B(1) xor C(1);
	si(2) <= A(2) xor B(2) xor C(2);
	si(3) <= A(3) xor B(3) xor C(3);
	si(4) <= A(4) xor B(4) xor C(4);
	si(5) <= A(5) xor B(5) xor C(5);
	si(6) <= A(6) xor B(6) xor C(6);
	si(7) <= A(7) xor B(7) xor C(7);
	si(8) <= A(8) xor B(8) xor C(8);
	si(9) <= A(9) xor B(9) xor C(9);
	si(10) <= A(10) xor B(10) xor C(10);
	si(11) <= A(11) xor B(11) xor C(11);
	si(12) <= A(12) xor B(12) xor C(12);
	si(13) <= A(13) xor B(13) xor C(13);
	si(14) <= A(14) xor B(14) xor C(14);
	si(15) <= A(15) xor B(15) xor C(15);
	si(16) <= '0';

	
	ci(0) <= '0';
	ci(1) <= (A(0) and B(0)) or (A(0) and C(0)) or (B(0) and C(0));
	ci(2) <= (A(1) and B(1)) or (A(1) and C(1)) or (B(1) and C(1));
	ci(3) <= (A(2) and B(2)) or (A(2) and C(2)) or (B(2) and C(2));
	ci(4) <= (A(3) and B(3)) or (A(3) and C(3)) or (B(3) and C(3));
	ci(5) <= (A(4) and B(4)) or (A(4) and C(4)) or (B(4) and C(4));
	ci(6) <= (A(5) and B(5)) or (A(5) and C(5)) or (B(5) and C(5));
	ci(7) <= (A(6) and B(6)) or (A(6) and C(6)) or (B(6) and C(6));
	ci(8) <= (A(7) and B(7)) or (A(7) and C(7)) or (B(7) and C(7));
	ci(9) <= (A(8) and B(8)) or (A(8) and C(8)) or (B(8) and C(8));	
	ci(10) <= (A(9) and B(9)) or (A(9) and C(9)) or (B(9) and C(9));
	ci(11) <= (A(10) and B(10)) or (A(10) and C(10)) or (B(10) and C(10));
	ci(12) <= (A(11) and B(11)) or (A(11) and C(11)) or (B(11) and C(11));
	ci(13) <= (A(12) and B(12)) or (A(12) and C(12)) or (B(12) and C(12));
	ci(14) <= (A(13) and B(13)) or (A(13) and C(13)) or (B(13) and C(13));
	ci(15) <= (A(14) and B(14)) or (A(14) and C(14)) or (B(14) and C(14));
	ci(16) <= (A(15) and B(15)) or (A(15) and C(15)) or (B(15) and C(15));

	adder17b : adder_17b port map(si, ci, '0', S, c_out);

end structure;