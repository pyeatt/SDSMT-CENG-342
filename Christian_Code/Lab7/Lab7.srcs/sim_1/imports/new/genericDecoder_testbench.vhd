----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericDecoder_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity genericDecoder_testbench is
end genericDecoder_testbench;


architecture tb_arch of genericDecoder_testbench is
    constant bits: integer := 3;
    signal sel: std_logic_vector(bits-1 downto 0);
    signal output: std_logic_vector(2**bits-1 downto 0);
    signal testin: unsigned(bits-1 downto 0):= (others=>'0');
begin
    uut: entity work.genericDecoder(proc_arch)
    generic map(bits => bits)
    port map(
        sel => sel,
        Y => output
        );
    
    -- iterate through all the possible input values
    process
    begin
        loop
            wait for 10 ns;
            testin <= testin + 1;
        end loop;
    end process;
    
    sel <= std_logic_vector(testin);
end tb_arch;
