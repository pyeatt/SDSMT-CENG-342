library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder_Testbench is
end Decoder_Testbench;

architecture arch of decoder_testbench is
    signal en:std_logic;
    signal sel:std_logic_vector(2 downto 0);
    signal output:std_logic_vector(7 downto 0);
    signal testin: unsigned(3 downto 0):="0000";
begin
    uut: entity work.three_to_eight_decoder(Behavioral)
         generic map(in_bits=>3)
         port map(enable=>en, Sel=>sel, An=>output);
    process
    begin
        loop
            wait for 10 ns;
            testin <= testin + 1;
        end loop;
    end process;
    sel <= std_logic_vector(testin(3 downto 1));
    en <= testin(0);
end arch;