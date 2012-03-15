library ieee;
use ieee.std_logic_1164.all;

entity control is
     port (    instr, keyboard_in, lcd_data : in std_logic_vector(31 downto 0);

               -- regfile controls
               ctrl_reg_wren                 : out std_logic;
               ctrl_rt_mux                 : out std_logic;
               ctrl_reg_input_mux			: out std_logic;
			   
               -- alu controls 
               ctrl_sign_ex_mux              : out std_logic;
               ctrl_alu_opcode		     : out std_logic_vector(2 downto 0);

               -- branch controls
               ctrl_br                       : out std_logic;
               ctrl_pc_wren                  : out std_logic;
               ctrl_jump			          : out std_logic;
               ctrl_jr                       : out std_logic;
               ctrl_jal                      : out std_logic;

               -- dmem controls
               ctrl_dmem_wren                : out std_logic ;
               ctrl_alu_dmem                 : out std_logic; -- selects between dmem output or ALU output 

               -- other controls
               ctrl_keyboard_ack             : out std_logic;
               ctrl_lcd_write                : out std_logic);
end control;


architecture behavior of control is

signal opcode : std_logic_vector(4 downto 0);
signal ctrl_reg_wren_temp, ctrl_dmem_wren_temp, ctrl_pc_wren_temp, ctrl_jump_temp : std_logic;

begin

     opcode <= instr(31 downto 27); 

     ctrl_reg_wren_temp <= '0' when opcode = "01000" else
						   '0' when opcode = "01001" else
						   '0' when opcode = "01010" else
						   '0' when opcode = "01011" else 
                           '0' when opcode = "01100" else
                           '0' when opcode = "01101" else
                           '0' when opcode = "01111" else
                           '1';
    
     ctrl_rt_mux <=   '1' when opcode = "00111" else 
                      '1' when opcode = "01000" else
                      '1' when opcode = "01001" else
                      '1' when opcode = "01010" else
                      '0'; 

     ctrl_sign_ex_mux <= '1' when opcode = "00110" else 
                         '1' when opcode = "00111" else 
                         '1' when opcode = "01000" else 
                         '1' when opcode = "01001" else 
                         '1' when opcode = "01010" else 
                         '0';

     ctrl_alu_opcode <= "000" when opcode = "00000" else
                        "001" when opcode = "00001" else
                        "010" when opcode = "00010" else
                        "011" when opcode = "00011" else
                        "100" when opcode = "00100" else
                        "101" when opcode = "00101" else
                        "000" when opcode = "00110" else
                        "001" when opcode = "01001" else
                        "001" when opcode = "01010" else
                        "000";
     

     ctrl_br <= '1' when opcode = "01001" else
                '1' when opcode = "01010" else
                '1' when opcode = "01011" else
                '1' when opcode = "01100" else
                '1' when opcode = "01101" else
                '0';

     ctrl_jal <= '1' when opcode = "01101" else
                 '0';
     
     ctrl_jr <= '1' when opcode = "01011" else
                '0';

     ctrl_alu_dmem <= '1' when opcode = "00111" else
                      '0';

	 ctrl_jump_temp <= '1' when opcode = "01011" else
					   '1' when opcode = "01100" else
					   '1' when opcode = "01101" else
					   '0';
					   
     ctrl_pc_wren_temp <= '1' when opcode = "01001" else
                          '1' when opcode = "01010" else
                          '1' when opcode = "01011" else
                          '1' when opcode = "01100" else
                          '1' when opcode = "01101" else
                          '0';
    
     ctrl_dmem_wren_temp <= '1' when opcode = "01000" else
                            '0';
                   
	 ctrl_reg_input_mux <= '1' when opcode = "01110" else
						   '0';
						   
     ctrl_reg_wren <= ctrl_reg_wren_temp after 10ns;
     ctrl_pc_wren <= ctrl_pc_wren_temp after 10ns;
     ctrl_dmem_wren <= ctrl_dmem_wren_temp after 10ns;
	 ctrl_jump <= ctrl_jump_temp after 10ns;

     ctrl_keyboard_ack <= not (keyboard_in(0) or
                      keyboard_in(1) or
                      keyboard_in(2) or
                      keyboard_in(3) or
                      keyboard_in(4) or
                      keyboard_in(5) or
                      keyboard_in(6) or
                      keyboard_in(7) or
                      keyboard_in(8) or
                      keyboard_in(9) or
                      keyboard_in(10) or
                      keyboard_in(11) or
                      keyboard_in(12) or
                      keyboard_in(13) or
                      keyboard_in(14) or
                      keyboard_in(15) or
                      keyboard_in(16) or
                      keyboard_in(17) or
                      keyboard_in(18) or
                      keyboard_in(19) or
                      keyboard_in(20) or
                      keyboard_in(21) or
                      keyboard_in(22) or
                      keyboard_in(23) or
                      keyboard_in(24) or
                      keyboard_in(25) or
                      keyboard_in(26) or
                      keyboard_in(27) or
                      keyboard_in(28) or
                      keyboard_in(29) or
                      keyboard_in(30) or
                      keyboard_in(31)) and
                      ( (not opcode(4)) and opcode(3) and opcode(2) and opcode(1) and (not opcode(0)));
     
      ctrl_lcd_write <= not (lcd_data(0) or
                      lcd_data(1) or
                      lcd_data(2) or
                      lcd_data(3) or
                      lcd_data(4) or
                      lcd_data(5) or
                      lcd_data(6) or
                      lcd_data(7) or
                      lcd_data(8) or
                      lcd_data(9) or
                      lcd_data(10) or
                      lcd_data(11) or
                      lcd_data(12) or
                      lcd_data(13) or
                      lcd_data(14) or
                      lcd_data(15) or
                      lcd_data(16) or
                      lcd_data(17) or
                      lcd_data(18) or
                      lcd_data(19) or
                      lcd_data(20) or
                      lcd_data(21) or
                      lcd_data(22) or
                      lcd_data(23) or
                      lcd_data(24) or
                      lcd_data(25) or
                      lcd_data(26) or
                      lcd_data(27) or
                      lcd_data(28) or
                      lcd_data(29) or
                      lcd_data(30) or
                      lcd_data(31)) and
                      ( (not opcode(4)) and opcode(3) and opcode(2) and opcode(1) and opcode(0));
end behavior;
