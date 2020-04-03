----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_PC_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a testbench for a generic counter
entity LPU_PC_TB is
end LPU_PC_TB;


-- implementation of a testbench for a generic counter
architecture tb_arch of LPU_PC_TB is
    signal NumBits: integer := 32; -- Number of bits in the counter
    signal Increment: integer := 2; -- Value to increment the counter by
    signal PCin: std_logic_vector(NumBits-1 downto 0) := (others => '0'); -- Data bus to load in a new value to the counter
    signal PCout: std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the counter
    signal LoadEn: std_logic := '1'; -- Active low enable for loading in a new value to the counter
    signal Inc: std_logic := '1'; -- Active low enable for incrementing the value held in the counter
    signal Clock: std_logic := '1'; -- Clock (triggered on rising edge)
    signal Reset: std_logic := '1'; -- Active low syncronous reset
begin
    PC:
        entity work.LPU_PC(arch)
        generic map(
            NumBits => NumBits,
            Increment => Increment
            )
        port map(
            PCin => PCin,
            PCout => PCout,
            LoadEn => LoadEn,
            Inc => Inc,
            Clock => Clock,
            Reset => Reset
            );
    
    ResetTest: process
    begin
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait;
    end process ResetTest;
    
    IncTest: process
    begin
        wait for 10 ns;
        Inc <= '1';
        wait for 20 ns;
        Inc <= '0';
        wait;
    end process IncTest;
    
    LoadTest: process
    begin
        wait for 10 ns;
        LoadEn <= '1';
        wait for 40 ns;
        PCin <= std_logic_vector(to_unsigned(11, NumBits));
        LoadEn <= '0';
        wait for 10 ns;
        LoadEn <= '1';
        wait;
    end process LoadTest;
    
    ClockTest: process
    begin
        wait for 5 ns;
        Clock <= not Clock;
        loop -- count up indefinately
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process ClockTest;
end tb_arch;