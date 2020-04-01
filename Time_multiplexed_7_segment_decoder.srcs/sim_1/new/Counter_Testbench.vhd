library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter_testbench is
end generic_counter_testbench;

architecture arch of generic_counter_testbench is
    signal clock:std_logic := '1';
    signal reset:std_logic := '1';
    signal output:std_logic_vector(4 downto 0);
begin
    uut: entity work.Counter(prof_method)
         generic map(bits=>5)
         port map(clk=>clock,reset=>reset,count=>output);
    
    process
    begin
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
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

end arch;