library ieee;
use ieee.std_logic_1164.all;

entity control is
     port (    instr     : in std_logic_vector(31 downto 0);

               -- regfile controls
               ctrl_reg_wren                 : out std_logic;
               ctrl_dest_mux                 : out std_logic;

               -- alu controls 
               ctrl_sign_ex_mux              : out std_logic;
               ctrl_alu_opcode				 : out std_logic_vector(2 downto 0);

               -- adder controls
               ctrl_subtract				 : out std_logic;

               -- branch controls
               ctrl_br                       : out std_logic;
               ctrl_pc_wren                  : out std_logic;

               -- shifter controls
               ctrl_rightshift               : out std_logic;
     
               -- dmem controls
               ctrl_dmem_wren                : out std_logic ;
               ctrl_output                   : out std_logic); -- selects between dmem output or ALU output 

               -- imem controls

               -- other controls
end control;


architecture structure of control is

signal opcode : std_logic_vector(5 downto 0);
signal ctrl_reg_wren_temp, ctrl_dmem_wren_temp, ctrl_pc_wren_temp : std_logic;

begin

     opcode <= instr(5 downto 0); 

     ctrl_reg_wren_temp <= '0' when opcode = "01011" else 
                           '0' when opcode = "01100" else
                           '0' when opcode = "01101" else
                           '0' when opcode = "01111" else
                           '1';
    
     ctrl_dest_mux <= '1' when opcode = "00000" else 
                      '1' when opcode = "00001" else
                      '1' when opcode = "00010" else
                      '1' when opcode = "00011" else
                      '1' when opcode = "00100" else
                      '1' when opcode = "00101" else
                      '0'; 

     ctrl_sign_ex_mux <= '1' when opcode = "00110" else 
                         '1' when opcode = "00111" else 
                         '1' when opcode = "01000" else 
                         '1' when opcode = "01001" else 
                         '1' when opcode = "01010" else 
                         '0';

     ctrl_alu_opcode <= opcode(2 downto 0);

     ctrl_subtract <= '1' when opcode = "00001" else 
                      '0';

     ctrl_br <= '1' when opcode = "01001" else
                '1' when opcode = "01010" else
                '1' when opcode = "01011" else
                '1' when opcode = "01100" else
                '1' when opcode = "01101" else
                '0';

     ctrl_pc_wren_temp <= '1' when opcode = "01001" else
                          '1' when opcode = "01010" else
                          '1' when opcode = "01011" else
                          '1' when opcode = "01100" else
                          '1' when opcode = "01101" else
                          '0';

     ctrl_rightshift <= '1' when opcode = "00101" else
                        '0';
    
     ctrl_dmem_wren_temp <= '1' when opcode = "01000" else
                            '0';

     ctrl_output <= '1' when opcode = "01111" else
                    '0';

     ctrl_reg_wren <= ctrl_reg_wren_temp after 10ns;
     ctrl_pc_wren <= ctrl_pc_wren_temp after 10ns;
     ctrl_dmem_wren <= ctrl_dmem_wren_temp after 10ns;

end structure;
