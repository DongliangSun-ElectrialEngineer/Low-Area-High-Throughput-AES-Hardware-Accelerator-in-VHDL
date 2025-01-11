library IEEE;
use IEEE.std_logic_1164.all;

entity AESmodule_tb is
end;

architecture testbench of AESmodule_tb is

  component AESmodule 
  	port (
  		clk : in std_logic;
  		rst : in std_logic;
  		key : in std_logic_vector(127 downto 0);
  		plaintext : in std_logic_vector(127 downto 0);
  		ciphertext : out std_logic_vector(127 downto 0);
  		done : out std_logic		
  	);
  end component;

  signal clk: std_logic:= '0';
  signal rst: std_logic;
  signal key: std_logic_vector(127 downto 0);
  signal plaintext: std_logic_vector(127 downto 0);
  signal ciphertext: std_logic_vector(127 downto 0) := (others => '0');
  signal done: std_logic ;

begin

  uut: AESmodule port map ( clk        => clk,
                            rst        => rst,
                            key        => key,
                            plaintext  => plaintext,
                            ciphertext => ciphertext,
                            done       => done );
-- clock_gen : process
--    begin
--        loop
--            clk <= '0';
--            wait for 5 ns; -- Clock low period
--            clk <= '1';
--            wait for 5 ns; -- Clock high period
--        end loop;
--    end process clock_gen;
clock_generation : process
    begin
        while true loop
            clk <= '0';
            wait for 1 ns; -- Half the period of a 20 ns clock cycle
            clk <= '1';
            wait for 1 ns;
        end loop;
    end process;
    
  stimulus: process
  begin

  rst <= '0';
  wait for 2 ns;
  rst <= '1';
  wait;
  end process;
  
process
begin
  plaintext <= x"1002a1b1c3d34767afaf5f6f34367275";
  key <= x"11223344a1b2c3e4aabbccdd55667790";
  wait;
end process;

end;