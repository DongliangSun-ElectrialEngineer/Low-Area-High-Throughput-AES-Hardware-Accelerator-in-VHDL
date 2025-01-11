library ieee;
use ieee.std_logic_1164.ALL;
use work.my_AES_package.ALL;

entity ShiftRows is
    Port ( input_state : in std_logic_vector(127 downto 0); -- 16 bytes input state
           output_state : out std_logic_vector(127 downto 0)); -- 16 bytes output state after ShiftRows
end ShiftRows;

architecture Behavioral of ShiftRows is
begin
    process(input_state)
    variable S : byte_type;
    begin
        for i in 0 to 15 loop -- Process each column
            S(i) := std_logic_vector(input_state((i*8+7) downto i*8));
        end loop;
    
        output_state <=   S(15) & S(10) & S(5) & S(0)
                        & S(11) & S(6) & S(1) & S(12)
                        & S(7) & S(2) & S(13) & S(8)
                        & S(3) & S(14) & S(9) & S(4);
    end process;
end Behavioral;
