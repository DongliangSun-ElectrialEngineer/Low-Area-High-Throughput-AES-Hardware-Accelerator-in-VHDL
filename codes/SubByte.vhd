library ieee;
use ieee.std_logic_1164.ALL;
use work.my_AES_package.ALL;

entity SubByte is
    Port ( input_state : in std_logic_vector(127 downto 0); -- 16 bytes input state
           output_state : out std_logic_vector(127 downto 0)); -- 16 bytes output state after ShiftRows
end SubByte;

architecture Behavioral of SubByte is
begin
    process(input_state)
    variable S : byte_type;
    begin
        for i in 0 to 15 loop -- Process each column
            S(i) := std_logic_vector(input_state((i*8+7) downto i*8));
        end loop;
    
        output_state <=   S_box(S(15)) & S_box(S(14)) & S_box(S(13)) & S_box(S(12))
                        & S_box(S(11)) & S_box(S(10)) & S_box(S(9)) & S_box(S(8))
                        & S_box(S(7)) & S_box(S(6)) & S_box(S(5)) & S_box(S(4))
                        & S_box(S(3)) & S_box(S(2)) & S_box(S(1)) & S_box(S(0));
    end process;
end Behavioral;

