----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
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
-- Test period: 2*20 ns
-- Setup time: 25 ns
architecture tb_arch of LPU_MAR_TB is
    constant dataWidth: integer := 32;
    signal MARin: std_logic_vector(dataWidth-1 downto 0) := (others => '0'); -- Data bus to load in a new value to the MAR
    signal MARout: std_logic_vector(dataWidth-1 downto 0); -- Data bus to output the current value of the MAR
    signal LoadEn: std_logic := '1'; -- Active low enable for loading in a new value to the MAR
    signal Clock: std_logic := '1'; -- Clock (triggered on rising edge)
    signal Reset: std_logic := '1'; -- Active low syncronous reset
    type TEST_STATE is (
        SETUP,
        SUCC_WRITE,
        FAIL_WRITE,
        READ
        );
    signal state: TEST_STATE := SETUP; -- This marks each quarter test period
    signal dat: natural := 0; -- input data
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
    
    -- run the clock
    testClock: process
    begin
        Clock <= '1';
        wait for 5 ns;
        Clock <= not Clock;
        loop
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process testClock;
    
    
    test: process
    begin
        -- clear the MAR
        state <= SETUP;
        Reset <= '1';
        LoadEn <= '1';
        wait for 10 ns;
        Reset <= '0';
        wait for 15 ns;
        Reset <= '1';
        
        loop
            -- write data to the MAR
            state <= SUCC_WRITE; -- mark reading state
            LoadEn <= '0'; -- enable load
            MARin <= std_logic_vector(to_unsigned(dat,dataWidth));
            dat <= dat + 1;
            wait for 20 ns;
            
            -- try write data to the MAR
            state <= FAIL_WRITE; -- mark reading state
            LoadEn <= '1'; -- disable load
            MARin <= std_logic_vector(to_unsigned(dat,dataWidth));
            dat <= dat + 1;
            wait for 20 ns;
        
        end loop;
    end process test;
end tb_arch;
