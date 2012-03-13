library ieee;
use ieee.std_logic_1164.all;

entity processor is
	port (	clock, reset		: in std_logic;
			keyboard_in			: in std_logic_vector(31 downto 0);
			keyboard_ack, lcd_write	:out std_logic;
			lcd_data			: out std_logic_vector(31 downto 0));
end processor;

architecture structure of processor is

component imem
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

component dmem
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

component reg32
port (	clock, ctrl_writeEnable, ctrl_reset: in std_logic;
		data_writeReg : in std_logic_vector(31 downto 0);
		data_readReg : out std_logic_vector(31 downto 0));
end component;

component shift2
	port ( 	data_A	: in std_logic_vector(31 downto 0);
			ctrl_rightshift	: in std_logic;
			data_S	: out std_logic_vector(31 downto 0));
end component;

component adder
	port (	data_addendA, data_addendB	: in std_logic_vector(31 downto 0);
			ctrl_subtract				: in std_logic;
			data_sum					: out std_logic_vector(31 downto 0);
			data_carryout				: out std_logic);
end component;

component alu
	port (	data_operandA, data_operandB 	: 	in std_logic_vector(31 downto 0);
			ctrl_ALUopcode				 	:	in std_logic_vector(2 downto 0);
			data_result						: 	out std_logic_vector(31 downto 0);
			isEqual, isGreaterThan			: 	out std_logic);
end component;

component mux2to1_32b
	port (	in0, in1	: in std_logic_vector(31 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(31 downto 0));
end component;

component mux2to1_5b
	port (	in0, in1	: in std_logic_vector(4 downto 0);
			ctrl_select	: in std_logic;
			data_out	: out std_logic_vector(4 downto 0));
end component;

component control
     port (    instr     : in std_logic_vector(31 downto 0);
               ctrl_reg_wren                 : out std_logic;
               ctrl_dest_mux                 : out std_logic;
               ctrl_sign_ex_mux              : out std_logic;
               ctrl_alu_opcode		     : out std_logic_vector(2 downto 0);
               ctrl_br                       : out std_logic;
               ctrl_pc_wren                  : out std_logic;
			ctrl_jump			          : out std_logic;
               ctrl_jr                       : out std_logic;
               ctrl_jal                      : out std_logic;
               ctrl_dmem_wren                : out std_logic ;
               ctrl_alu_dmem                 : out std_logic; -- selects between dmem output or ALU output 
               ctrl_output                   : out std_logic); -- lcd output

end component;

component sgn_ext
	port (	input 	: in std_logic_vector(16 downto 0);
			output	: out std_logic_vector(31 downto 0));
end component;

component regfile
    port (    clock, ctrl_writeEnable, ctrl_reset : in std_logic;
            ctrl_writeReg, ctrl_readRegA, ctrl_readRegB : in std_logic_vector(4 downto 0);
            data_writeReg    : in std_logic_vector(31 downto 0);
            data_readRegA, data_readRegB : out std_logic_vector(31 downto 0) );
end component;

signal    cur_pc_in, cur_pc_in_temp, cur_pc_out,
          pc_plus_1, 
          cur_instr, cur_instr_jump,
          jump_addr,
          sgn_ext_out, sgn_ext_shift,
          branch_addr, br_or_j_addr,
          regfile_d1, regfile_d2, regfile_write,
          alu_output, alu_input2, 
          dmem_output : std_logic_vector(31 downto 0);

signal    cur_instr_rs, cur_instr_rt, 
          cur_instr_rd, regfile_dest, temp_regfile_dest : std_logic_vector(4 downto 0);

signal    cur_instr_imm  : std_logic_vector(16 downto 0);

signal    cur_instr_jump_27   : std_logic_vector(26 downto 0);

signal    ctrl_reg_wren, ctrl_dest_mux, 
          ctrl_sgn_ex_mux, 
          ctrl_br, ctrl_pc_wren, ctrl_jump,
          ctrl_jr, ctrl_jal,
          ctrl_dmem_wren,
          ctrl_alu_dmem, ctrl_output   : std_logic; 

signal    ctrl_alu_opcode : std_logic_vector(2 downto 0);

signal    carryout_useless, useless, useless2, useless3 : std_logic;

signal    one, zero: std_logic_vector(31 downto 0);

signal 	  alu_zero : std_logic;

begin

    
     cur_instr_imm <= cur_instr(16 downto 0);
     cur_instr_jump_27 <= cur_instr(26 downto 0);
     cur_instr_rd <= cur_instr(26 downto 22);
     cur_instr_rs <= cur_instr(21 downto 17);
     cur_instr_rt <= cur_instr(16 downto 12);
     cur_instr_jump(31 downto 27) <= pc_plus_1(31 downto 27);
     cur_instr_jump(26 downto 0) <= cur_instr_jump_27;
     
     one <= "00000000000000000000000000000001";         
     zero <= "00000000000000000000000000000000";
     pc : reg32 port map(clock, ctrl_pc_wren, reset, cur_pc_in, cur_pc_out);
     instr_mem: imem port map(cur_pc_in(11 downto 0), '1', clock, cur_instr); -- might fail to compile
     registerfile : regfile port map(clock, ctrl_reg_wren, reset, regfile_dest, 
                                     cur_instr_rs, cur_instr_rt, regfile_write,
                                     regfile_d1, regfile_d2);
     reg_dest_mux : mux2to1_5b port map(cur_instr_rt, cur_instr_rd, ctrl_dest_mux, temp_regfile_dest);
     pc_reset_mux : mux2to1_32b port map(cur_pc_in_temp, zero, reset, cur_pc_in);
     sgn_ext_unit : sgn_ext port map(cur_instr_imm, sgn_ext_out);
     control_unit : control port map(cur_instr, ctrl_reg_wren, ctrl_dest_mux, 
                                   ctrl_sgn_ex_mux, ctrl_alu_opcode, 
                                   ctrl_br, ctrl_pc_wren, ctrl_jump, ctrl_jr, ctrl_jal,
                                   ctrl_dmem_wren, ctrl_alu_dmem, ctrl_output);
     adder_pc_1   : adder port map(one, cur_pc_out, '0', pc_plus_1, carryout_useless);
     sgn_ext_mux: mux2to1_32b port map(regfile_d2, sgn_ext_out, ctrl_sgn_ex_mux, alu_input2);
     main_alu: alu port map(regfile_d1, alu_input2, ctrl_alu_opcode, alu_output, useless, useless2);
     data_mem: dmem port map(alu_output(11 downto 0), not clock, regfile_d2, ctrl_dmem_wren, dmem_output);
     output_mux: mux2to1_32b port map(alu_output, dmem_output, ctrl_alu_dmem, regfile_write);
     br_mux: mux2to1_32b port map(pc_plus_1, branch_addr, alu_zero and ctrl_br, br_or_j_addr);
     branch_adder: adder port map(pc_plus_1, sgn_ext_out, '0', branch_addr, useless3);
     br_jump_addr_mux: mux2to1_32b port map(br_or_j_addr, jump_addr, ctrl_jump, cur_pc_in_temp);
     jal_mux: mux2to1_5b port map(temp_regfile_dest, "11111", ctrl_jal, regfile_dest);
	 jr_mux: mux2to1_32b port map(cur_instr_jump, regfile_d1, ctrl_jr, jump_addr);


     -- alu zero
     alu_zero <= not (alu_output(0) or
                      alu_output(1) or
                      alu_output(2) or
                      alu_output(3) or
                      alu_output(4) or
                      alu_output(5) or
                      alu_output(6) or
                      alu_output(7) or
                      alu_output(8) or
                      alu_output(9) or
                      alu_output(10) or
                      alu_output(11) or
                      alu_output(12) or
                      alu_output(13) or
                      alu_output(14) or
                      alu_output(15) or
                      alu_output(16) or
                      alu_output(17) or
                      alu_output(18) or
                      alu_output(19) or
                      alu_output(20) or
                      alu_output(21) or
                      alu_output(22) or
                      alu_output(23) or
                      alu_output(24) or
                      alu_output(25) or
                      alu_output(26) or
                      alu_output(27) or
                      alu_output(28) or
                      alu_output(29) or
                      alu_output(30) or
                      alu_output(31));
                 
end structure;