----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/14/2020
-- Lab 7
-- Design Name: genericCounter_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a testbench for a generic counter
entity genericCounter_testbench is
end genericCounter_testbench;


-- implementation of a testbench for a generic counter
architecture tb_arch of genericCounter_testbench is
    signal clock: std_logic := '1';
    signal reset: std_logic := '1';
    signal output: std_logic_vector(4 downto 0) := (others => '0');
begin
    uut: entity work.genericCounter(ifelse_arch)
        generic map(bits=>5)
        port map(
            clk=>clock,
            rst=>reset,
            q=>output
            );
    
    process
    begin
        -- initialize counter
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
        loop -- count up indefinately
            wait for 10 ns;
            clock <= not clock;
        end loop;
    end process;
end tb_arch;