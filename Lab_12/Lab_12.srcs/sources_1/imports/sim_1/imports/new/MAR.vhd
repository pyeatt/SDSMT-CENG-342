library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAR is
    generic (Bits: integer := 32);
    Port (
           input: in std_logic_vector(Bits - 1 downto 0);
           output: out std_logic_vector(Bits -1 downto 0);
           Enable, clk, reset: in std_logic  
          );
end MAR;

architecture arch of MAR is
begin
       MAR_register: entity work.generic_register(Behavioral)
    generic map( Bits => Bits)
    port map(  
            Enable => Enable, 
            clk => clk, 
            reset => reset, 
            din => input, 
            dout => output
            );

end arch;
