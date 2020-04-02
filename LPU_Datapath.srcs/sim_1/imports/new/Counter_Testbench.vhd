--Author: Clayton Heeren
--Date: March 27, 2020
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter_testbench is
end generic_counter_testbench;

architecture arch of generic_counter_testbench is
    signal clock:std_logic := '0';
    signal reset:std_logic := '0';
    signal PC_le, PC_ie: std_logic;
    signal PC_in: std_logic_vector(4 downto 0) := "00000";
    signal output:std_logic_vector(4 downto 0);
begin
    uut: entity work.PC_Counter(Arch)
         generic map(bits=>5)
         port map(clk=>clock,reset=>reset,count=>output,
                  PC_le=>PC_le, PC_ie=>PC_ie, PC_in=>PC_in(4 downto 1)); 
    
    process --initialize counter
    begin
        PC_ie <= '1';
        PC_le <= '1';
        wait for 10 ns;
        reset <= '1';
        wait for 5 ns;
        --PC_ie <= '0';
        PC_le <= '0';
        wait;
    end process;
    
    process
    begin
        wait for 5 ns;
        clock <= not clock;
        loop
            wait for 10 ns;
            clock <= not clock;
        end loop;
    end process;
    
    process
        variable I: integer;
    begin
        wait for 20ns;
        loop
            for I in 0 to 32 loop
                PC_in <= std_logic_vector(to_unsigned(I, 5));
                wait for 20ns;
            end loop;
        end loop;
    end process;
    
end arch;