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
               ctrl_beq                       : out std_logic;
               ctrl_bgt						 : out std_logic;
               ctrl_pc_wren                  : out std_logic; -- kept but unused
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
     

     ctrl_beq <= '1' when opcode = "01001" else
				 '0';
				 
	 ctrl_bgt <= '1' when opcode = "01010" else
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

     ctrl_keyboard_ack <= '1' when opcode = "01110" else
						  '0';
     
      ctrl_lcd_write <= '1' when opcode = "01111" else
						'0';
						
end behavior;
