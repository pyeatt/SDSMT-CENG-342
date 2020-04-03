----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_MAR_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_MAR_TB is
end LPU_MAR_TB;


-- testbench for LPU Memory Data Register
architecture tb_arch of LPU_MAR_TB is
    signal MARin: std_logic_vector(31 downto 0) := (others => '0'); -- Data bus to load in a new value to the MAR
    signal MARout: std_logic_vector(31 downto 0); -- Data bus to output the current value of the MAR
    signal LoadEn: std_logic := '1'; -- Active low enable for loading in a new value to the MAR
    signal Clock: std_logic := '1'; -- Clock (triggered on rising edge)
    signal Reset: std_logic := '1'; -- Active low syncronous reset
    signal Control: unsigned(33 downto 0) := (others => '0'); -- internal signal
begin
    MAR:
        entity work.LPU_MAR(arch)
        port map(
            MARin => MARin,
            MARout => MARout,
            LoadEn => LoadEn,
            Clock => Clock,
            Reset => Reset
            );
    
    TestReset: process
    begin
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait;
    end process TestReset;
    
    TestLoadEn: process
    begin
        LoadEn <= '1';
        wait for 10 ns;
        loop
            LoadEn <= '0';
            wait for 35 ns;
            LoadEn <= '1';
            wait for 10 ns;
        end loop;
    end process TestLoadEn;
    
    TestInput: process
    begin
        wait for 5 ns;
        loop
            wait for 10 ns;
            Control <= Control + 1;
        end loop;
    end process TestInput;
    
    MARin <= std_logic_vector(Control(33 downto 2));
    Clock <= Control(0);

end tb_arch;
