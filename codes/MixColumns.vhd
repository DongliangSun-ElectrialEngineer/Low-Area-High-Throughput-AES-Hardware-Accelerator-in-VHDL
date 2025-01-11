library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_AES_package.ALL;

-- Entity declaration for MixColumns
entity MixColumns is
    Port (
        input_state : in std_logic_vector(127 downto 0);
        output_state : out std_logic_vector(127 downto 0)
    );
end MixColumns;

-- Architecture declaration
architecture Behavioral of MixColumns is

-- Function for finite field multiplication by 2 used in MixColumns
--function mult_by_02(b : std_logic_vector(7 downto 0)) return std_logic_vector is
--    variable result : std_logic_vector(7 downto 0);
--begin
--    result := b(6 downto 0) & '0'; -- Left shift by 1
--    if b(7) = '1' then -- if b7 is 1 then add {1b} polynomial (x^8 + x^4 + x^3 + x + 1)
--        result := result xor "00011011";
--    end if;
--    return result;
--end mult_by_02;

-- Function for finite field multiplication by 3 used in MixColumns
function mult_by_03(b : std_logic_vector(7 downto 0)) return std_logic_vector is
begin
    -- x3 multiplication is x2 ^ x
    return mult_by_02(b) xor b;
end mult_by_03;

-- Main process for MixColumns
begin
    process(input_state)
    variable S : byte_type;
    variable result_state : byte_type; -- Resultant state
    begin
        for i in 0 to 15 loop -- Process each column
            S(i) := std_logic_vector(input_state((i*8+7) downto i*8));
        end loop;
         for i in 0 to 3 loop -- Process each column
            -- Applying MixColumns transformation
            --result_state(0 + i) := mult_by_02(S(0 + i)) xor mult_by_03(S(4 + i)) xor S(8 + i) xor S(12 + i);
            --result_state(4 + i)  := S(0 + i) xor mult_by_02(S(4 + i)) xor mult_by_03(S(8 + i)) xor S(12 + i);
            --result_state(8 + i)  := S(0 + i) xor S(4 + i) xor mult_by_02(S(8 + i)) xor mult_by_03(S(12 + i));
            --result_state(12 + i) := mult_by_03(S(0 + i)) xor S(4 + i) xor S(8 + i) xor mult_by_02(S(12 + i));
            result_state(3 + i*4) := mult_by_02(S(3 + i*4)) xor mult_by_03(S(2 + i*4)) xor S(1 + i*4) xor S(0 + i*4);
            result_state(2 + i*4)  := S(3 + i*4) xor mult_by_02(S(2 + i*4)) xor mult_by_03(S(1 + i*4)) xor S(0 + i*4);
            result_state(1 + i*4)  := S(3 + i*4) xor S(2 + i*4) xor mult_by_02(S(1 + i*4)) xor mult_by_03(S(0 + i*4));
            result_state(0 + i*4) := mult_by_03(S(3 + i*4)) xor S(2 + i*4) xor S(1 + i*4) xor mult_by_02(S(0 + i*4));
        end loop;
        output_state <= result_state(15) & result_state(14) & result_state(13) & result_state(12)
                        & result_state(11) & result_state(10) & result_state(9) & result_state(8)
                        & result_state(7) & result_state(6) & result_state(5) & result_state(4)
                        & result_state(3) & result_state(2) & result_state(1) & result_state(0);
    end process;
end Behavioral;