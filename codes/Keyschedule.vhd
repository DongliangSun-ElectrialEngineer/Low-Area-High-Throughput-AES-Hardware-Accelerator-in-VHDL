library ieee;
use ieee.std_logic_1164.all;
use work.my_AES_package.all;

entity Keyschedule is
	port (
		clk : in std_logic;
		rst : in std_logic;
		restart : in std_logic;
		key : in std_logic_vector(127 downto 0);
		Rcon : in std_logic_vector(7 downto 0);
		sub_key : out std_logic_vector(127 downto 0)
	);
end Keyschedule;

architecture behavioral of Keyschedule is
	signal feedback : std_logic_vector(127 downto 0);
	signal reg_input : std_logic_vector(127 downto 0);
	signal reg_output : std_logic_vector(127 downto 0);
begin
	reg_input <= key when (rst = '0') or (restart = '1') else feedback;
	reg_inst : entity work.reg
		generic map(
			size => 128
		)
		port map(
			clk => clk,
			d   => reg_input,
			q   => reg_output
		);	
	key_expansion_inst : entity work.KeyExpansion
		port map(
			current_key      => reg_output,
			Rcon             => Rcon,
			next_key         => feedback
		);
	sub_key <= reg_output;
end architecture behavioral;