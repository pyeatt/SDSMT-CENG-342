----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
-- Lab 8
-- Design Name: LPU_CCR_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_CCR_TB is
end LPU_CCR_TB;


-- testbench for LPU Condition Control Register
-- Test period: 2*20 ns
-- Setup time: 25 ns
architecture tb_arch of LPU_CCR_TB is
    constant dataWidth: integer := 4;
    signal CCRin: std_logic_vector(dataWidth-1 downto 0) := (others => '0'); -- Data bus to load in a new value to the CCR
    signal CCRout: std_logic_vector(dataWidth-1 downto 0); -- Data bus to output the current value of the CCR
    signal LoadEn: std_logic; -- Active low enable for loading in a new value to the CCR
    signal Clock: std_logic; -- Clock (triggered on rising edge)
    signal Reset: std_logic; -- Active low syncronous reset
    type TEST_STATE is (
        SETUP,
        SUCC_WRITE,
        FAIL_WRITE,
        READ
        );
    signal state: TEST_STATE := SETUP; -- This marks each quarter test period
    signal dat: natural := 0; -- input data
begin
    CCR:
        entity work.LPU_CCR(arch)
        port map(
            CCRin => CCRin,
            CCRout => CCRout,
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
        -- clear the register file
        state <= SETUP;
        Reset <= '1';
        LoadEn <= '1';
        wait for 10 ns;
        Reset <= '0';
        wait for 15 ns;
        Reset <= '1';
        
        loop
            -- write data to the CCR
            state <= SUCC_WRITE; -- mark reading state
            LoadEn <= '0'; -- enable load
            CCRin <= std_logic_vector(to_unsigned(dat,dataWidth));
            dat <= dat + 1;
            wait for 20 ns;
            
            -- try write data to the register file (fill every register)
            state <= FAIL_WRITE; -- mark reading state
            LoadEn <= '1'; -- disable load
            CCRin <= std_logic_vector(to_unsigned(dat,dataWidth));
            dat <= dat + 1;
            wait for 20 ns;
        
        end loop;
    end process test;
end tb_arch;
