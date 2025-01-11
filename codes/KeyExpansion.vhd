library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_AES_package.ALL;

entity KeyExpansion is
    Port (
        current_key : in std_logic_vector(127 downto 0); -- Input current round key
        Rcon : in std_logic_vector(7 downto 0);
        next_key : out std_logic_vector(127 downto 0) -- Output next round key
    );
end KeyExpansion;

architecture Behavioral of KeyExpansion is

-- Function to rotate word (circular left shift by 8 bits)
function RotWord(word : std_logic_vector(31 downto 0)) return std_logic_vector is
variable result : std_logic_vector(31 downto 0);
begin
    result := word(23 downto 0) & word(31 downto 24);
    return result;
    
end RotWord;



begin
    process(current_key,Rcon)
    variable column : word_type;
    variable temp : std_logic_vector(31 downto 0);
    begin
        -- First, copy the input key into the first 4 words of the expanded key
        for i in 0 to 3 loop
            column(i) := current_key((31+32*i) downto (0+32*i));
        end loop;

-- G function        
        temp := RotWord(column(0));
        temp := S_box(temp(31 downto 24)) & S_box(temp(23 downto 16))
                     & S_box(temp(15 downto 8)) & S_box(temp(7 downto 0));
        temp := temp xor (Rcon & x"000000");
        
        column(3) := column(3) xor temp;
        column(2) := column(2) xor column(3);
        column(1) := column(1) xor column(2);
        column(0) := column(0) xor column(1);
        
        next_key <= column(3) & column(2) &column(1) &column(0);
        -- Signal that expanded_key is ready
        -- Note: This is a simplified view; signal handling might be needed for synchronization
    end process;
end Behavioral;
