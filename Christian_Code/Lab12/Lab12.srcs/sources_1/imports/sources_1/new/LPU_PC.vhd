----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/03/2020
-- Lab 8
-- Design Name: LPU_PC
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the program counter for the LPU
entity LPU_PC is
    generic(
        NumBits: integer := 32; -- Number of bits in the counter
        Increment: integer := 2 -- Value to increment the counter by
        );
    port(
        PCin: in std_logic_vector(NumBits-1 downto 0); -- Data bus to load in a new value to the counter
        PCout: out std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the counter
        LoadEn: in std_logic; -- Active low enable for loading in a new value to the counter
        Inc: in std_logic; -- Active low enable for incrementing the value held in the counter
        Clock: in std_logic; -- Clock (triggered on rising edge)
        Reset: in std_logic -- Active low syncronous reset
        );
end LPU_PC;


architecture arch of LPU_PC is
    signal Count: unsigned(NumBits-1 downto 0) := (others=>'0');
    signal Count_next: unsigned(NumBits-1 downto 0) := (others=>'0');
begin

    process(PCin, LoadEn, Inc, Clock, Reset)
    begin
        if Clock'event and Clock = '1' then -- only perform an operation on a rising clock edge
            if Reset = '0' then
                Count <= (others=>'0'); -- reset count
            elsif LoadEn = '0' then
                Count <= unsigned(PCin); -- load new value to counter
            elsif Inc = '0' then
                Count <= Count_next; -- increment counter
            end if;
        end if;
    end process;
    
    Count_next <= Count + Increment;
    
    PCout <= std_logic_vector(Count);

end arch;





