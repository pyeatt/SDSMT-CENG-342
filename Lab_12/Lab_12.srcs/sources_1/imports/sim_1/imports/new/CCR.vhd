library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CCR is
    Port ( 
             input: in std_logic_vector(3 downto 0);
             output: out std_logic_vector(3 downto 0);
             Enable, clk, reset: in std_logic    
          );
end CCR;

architecture arch of CCR is

begin
    CCR_register:
    entity work.generic_register(Behavioral)
    generic map( Bits => 4)
    port map(  
            Enable => Enable, 
            clk => clk, 
            reset => reset, 
            din => input, 
            dout => output
            );
    
end arch;
