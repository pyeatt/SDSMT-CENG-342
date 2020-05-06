library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MCR is
    Port (
           input: in std_logic_vector(4 downto 0);
           output: out std_logic_vector(4 downto 0);
           Enable, clk, reset: in std_logic  
          );
end MCR;

architecture arch of MCR is

begin
    MCR_register: entity work.generic_register(Behavioral)
    generic map( Bits => 5)
    port map(  
            Enable => Enable, 
            clk => clk, 
            reset => reset, 
            din => input, 
            dout => output
            ); 

end arch;
