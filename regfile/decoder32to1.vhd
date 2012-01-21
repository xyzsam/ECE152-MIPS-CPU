library ieee;
use ieee.std_logic_1164.all;

entity decoder32to1 is
port (input : in std_logic_vector(4 downto 0);
      output : out std_logic_vector(31 downto 0));
end decoder32to1;

architecture structure of decoder32to1 is
type arr is array(0 to 31) of std_logic_vector(4 downto 0);
signal arr_a : arr;

begin
    arr_a(0)  <= input xnor "00000";
    arr_a(1)  <= input xnor "00001";
    arr_a(2)  <= input xnor "00010";
    arr_a(3)  <= input xnor "00011";
    arr_a(4)  <= input xnor "00100";
    arr_a(5)  <= input xnor "00101";
    arr_a(6)  <= input xnor "00110";
    arr_a(7)  <= input xnor "00111";
    arr_a(8)  <= input xnor "01000";
    arr_a(9)  <= input xnor "01001";
    arr_a(10) <= input xnor "01010";
    arr_a(11) <= input xnor "01011";
    arr_a(12) <= input xnor "01100";
    arr_a(13) <= input xnor "01101";
    arr_a(14) <= input xnor "01110";
    arr_a(15) <= input xnor "01111";
    arr_a(16) <= input xnor "10000";
    arr_a(17) <= input xnor "10001";
    arr_a(18) <= input xnor "10010";
    arr_a(19) <= input xnor "10011";
    arr_a(20) <= input xnor "10100";
    arr_a(21) <= input xnor "10101";
    arr_a(22) <= input xnor "10110";
    arr_a(23) <= input xnor "10111";
    arr_a(24) <= input xnor "11000";
    arr_a(25) <= input xnor "11001";
    arr_a(26) <= input xnor "11010";
    arr_a(27) <= input xnor "11011";
    arr_a(28) <= input xnor "11100";
    arr_a(29) <= input xnor "11101";
    arr_a(30) <= input xnor "11110";
    arr_a(31) <= input xnor "11111";
   
    gen: for I in 0 to 31 generate
        output(I) <= (arr_a(I)(0) and arr_a(I)(1) and arr_a(I)(2) and arr_a(I)(3) and arr_a(I)(4));
    end generate gen;
   
end structure;