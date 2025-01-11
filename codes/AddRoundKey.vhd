library ieee;
use ieee.std_logic_1164.ALL;


-- Entity declaration for AddRoundKey
entity AddRoundKey is
    Port (
        input_state : in std_logic_vector(127 downto 0);
        round_key : in std_logic_vector(127 downto 0);
        output_state : out std_logic_vector(127 downto 0)
    );
end AddRoundKey;

-- Architecture declaration
architecture Behavioral of AddRoundKey is
begin
    -- XOR process for AddRoundKey
    process(input_state, round_key)
    begin
        output_state <= input_state xor round_key;
    end process;
end Behavioral;
