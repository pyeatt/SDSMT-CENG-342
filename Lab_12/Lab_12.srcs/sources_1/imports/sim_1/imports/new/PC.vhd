library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--Using the counter example from Pyeatt's slides on Hex2Seg_part2
entity PC is
    generic(Bits: integer := 33;
            Increment: integer := 2);
    port(  input: in std_logic_vector(Bits - 1 downto 0);
           output: out std_logic_vector(Bits -1 downto 0);
           Load, IncE, clk, reset: in std_logic
         );
end PC;

architecture arch of PC is
    signal current_count: unsigned(Bits-1 downto 0) := (others=>'0');
    signal next_count: unsigned(Bits-1 downto 0) := (others=>'0');
begin
    process(input, Load, IncE, clk, reset)
    begin 
        if clk'event and clk ='1' then 
            if reset = '0' then 
                current_count <= (others=>'0');
            elsif Load = '0' then 
                current_count <= unsigned(input);
            elsif IncE = '0' then 
                current_count <= next_count;
            end if;
        end if;
     end process;
     
     next_count <= current_count + increment;
     
     output <= std_logic_vector(current_count);        

end arch;
