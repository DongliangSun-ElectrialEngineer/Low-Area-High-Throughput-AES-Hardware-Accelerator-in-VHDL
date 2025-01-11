library ieee;
use ieee.std_logic_1164.all;
use work.my_AES_package.all;

entity controller is
	port (
		clk : in std_logic;
		rst : in std_logic;
		rconst : out std_logic_vector(7 downto 0);
		is_final_round : out std_logic;
		done : out std_logic
	);
end controller;

architecture behavioral of controller is
	signal reg_input : std_logic_vector(7 downto 0);
	signal reg_output : std_logic_vector(7 downto 0);
	signal feedback : std_logic_vector(7 downto 0);
	signal done_buffer : std_logic;
begin
--	reg_input <= x"01" when rst = '0' else feedback;
--	reg_inst : entity work.reg
--		generic map(
--			size => 8
--		)
--		port map(
--			clk => clk,
--			d   => reg_input,
--			q   => reg_output
--		);
		register_with_reset : process(clk) is
		begin
			if rising_edge(clk) then
				if (rst = '0')or (done_buffer = '1') then 
					reg_output <= x"01";				
				else 
					reg_output <= feedback;
				end if;
			end if;
	    end process register_with_reset;

	feedback <= mult_by_02(reg_output);
	rconst <= reg_output;
	is_final_round <= '1' when reg_output = x"36" else '0';
	done_buffer <= '1' when reg_output = x"6c" else '0';
	done <= done_buffer;
end architecture behavioral;