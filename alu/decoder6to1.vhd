library ieee;
use ieee.std_logic_1164.all;

entity decoder6to1 is
port (input : in std_logic_vector(2 downto 0);
      output : out std_logic_vector(5 downto 0));
end decoder6to1;

architecture structure of decoder6to1 is
type arr is array(0 to 5) of std_logic_vector(5 downto 0);
signal arr_a : arr;

begin
    arr_a(0)  <= input xnor "000";
    arr_a(1)  <= input xnor "001";
    arr_a(2)  <= input xnor "010";
    arr_a(3)  <= input xnor "011";
    arr_a(4)  <= input xnor "100";
    arr_a(5)  <= input xnor "101";
       
    gen: for I in 0 to 5 generate
        output(I) <= (arr_a(I)(0) and arr_a(I)(1) and arr_a(I)(2));
    end generate gen;
   
end structure;
