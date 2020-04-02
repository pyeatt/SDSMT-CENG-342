----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/14/2020
-- Lab 7
-- Design Name: genericCounter
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a rising-edge, generic counter
entity genericCounter is
    generic(bits: integer := 4);
    port(
        clk: in std_logic; -- clock
        rst: in std_logic; -- asynch reset (active low)
        q: out std_logic_vector(bits-1 downto 0) -- count
        );
end genericCounter;


-- if-else implementation of a generic counter
architecture ifelse_arch of genericCounter is
    signal data: unsigned(bits-1 downto 0) := (others => '0');
begin
    process(clk,rst)
    begin
        if rst = '0' then
            data <= (others => '0'); -- reset count
        elsif clk'event and clk = '1' then -- change on rising edge
            data <= data + 1; -- increment counter
        end if;
    end process;
    
    q <= std_logic_vector(data);
    
end ifelse_arch;