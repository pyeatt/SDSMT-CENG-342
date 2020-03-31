----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericDecoderWithEnable_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity genericDecoderWithEnable_testbench is
end genericDecoderWithEnable_testbench;


architecture tb_arch of genericDecoderWithEnable_testbench is
    constant bits: integer := 3;
    signal en: std_logic;
    signal sel: std_logic_vector(bits-1 downto 0);
    signal output: std_logic_vector(2**bits-1 downto 0);
    signal testin: unsigned(bits downto 0):= (others=>'0');
    signal isCorrect: std_logic := '0';
begin
    uut: entity work.genericDecoderWithEnable(ifelse_arch)
    generic map(bits => bits)
    port map(
        en => en,
        sel => sel,
        Y => output
        );
    
    process
    begin
        loop
            wait for 10 ns;
            testin <= testin + 1;
        end loop;
    end process;
    
    sel <= std_logic_vector(testin(3 downto 1));
    en <= testin(0);
    
end tb_arch;
