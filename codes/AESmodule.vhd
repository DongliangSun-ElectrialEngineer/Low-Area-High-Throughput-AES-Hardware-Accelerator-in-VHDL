library ieee;
use ieee.std_logic_1164.all;
use work.my_AES_package.all;

entity AESmodule is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		key : in std_logic_vector(127 downto 0);
		plaintext : in std_logic_vector(127 downto 0);
		ciphertext : out std_logic_vector(127 downto 0);
		done : out std_logic		
	);
end AESmodule;

architecture behavioral of AESmodule is
	signal reg_input : std_logic_vector(127 downto 0);
	signal reg_output : std_logic_vector(127 downto 0);
	signal addroundkey_output : std_logic_vector(127 downto 0);
	signal Sbox_output : std_logic_vector(127 downto 0);
	signal shiftrows_output : std_logic_vector(127 downto 0);
	signal mixcol_output : std_logic_vector(127 downto 0);
	signal feedback : std_logic_vector(127 downto 0);
	signal round_key : std_logic_vector(127 downto 0);
	signal round_const : std_logic_vector(7 downto 0);
	signal sel : std_logic;
	signal restart : std_logic;
	
begin
	reg_input <= plaintext when (rst = '0') or (restart = '1') else feedback;
	reg_inst : entity work.reg
		generic map(
			size => 128
		)
		port map(
			clk => clk,
			d   => reg_input,
			q   => reg_output
		);
	-- Encryption body
	add_round_key_inst : entity work.AddRoundKey
		port map(
			input_state => reg_output,
			round_key => round_key,
			output_state => addroundkey_output
		);
	
	sub_byte_inst : entity work.SubByte
	    port map(
	        input_state  => addroundkey_output,
	        output_state => Sbox_output
	    );

	
	shift_rows_inst : entity work.ShiftRows
		port map(
			input_state  => Sbox_output,
			output_state => shiftrows_output
		);
	mix_columns_inst : entity work.MixColumns
		port map(
			input_state  => shiftrows_output,
			output_state => mixcol_output
		);
	feedback <= mixcol_output when sel = '0' else shiftrows_output;
	ciphertext <= addroundkey_output;	
	-- Controller
	controller_inst : entity work.controller
		port map(
			clk            => clk,
			rst            => rst,
			rconst         => round_const,
			is_final_round => sel,
			done           => restart
		);
		done <= restart;
	-- Keyschedule
	key_schedule_inst : entity work.Keyschedule
		port map(
			clk         => clk,
			rst         => rst,
			restart     => restart,
			key         => key,
			Rcon        => round_const,
			sub_key     => round_key
		);	
end architecture behavioral;