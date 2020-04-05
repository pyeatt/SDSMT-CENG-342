----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
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
-- Test period: 4*10*(2**numSelBits) ns
-- Setup time: 20 ns
architecture tb_arch of LPU_PC_TB is
    constant NumBits: integer := 3; -- Number of bits in the counter
    constant Increment: integer := 2; -- Value to increment the counter by
    signal PCin: std_logic_vector(NumBits-1 downto 0); -- Data bus to load in a new value to the counter
    signal PCout: std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the counter
    signal LoadEn: std_logic; -- Active low enable for loading in a new value to the counter
    signal Inc: std_logic; -- Active low enable for incrementing the value held in the counter
    signal Clock: std_logic; -- Clock (triggered on rising edge)
    signal Reset: std_logic; -- Active low syncronous reset
    
    type TEST_STATE is (
        SETUP,
        SUCC_INC,
        FAIL_INC,
        SUCC_LOAD,
        FAIL_LOAD
        );
    signal state: TEST_STATE := SETUP; -- This marks each quarter test period
    signal dat: natural := 0; -- input data
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
            
    ClockTest: process
    begin
        Clock <= '1';
        wait for 5 ns;
        Clock <= not Clock;
        loop -- count up indefinately
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process ClockTest;
    
    Test: process
        variable i: natural := 0;
    begin
            -- setup
            state <= SETUP;
            Reset <= '1';
            LoadEn <= '1';
            Inc <= '1';
            wait for 10 ns;
            Reset <= '0';
            wait for 10 ns;
            Reset <= '1';
         loop   
            -- test successful increment
            state <= SUCC_INC;
            Inc <= '0';
            for i in 0 to 2**NumBits-1 loop
                wait for 10 ns;
            end loop;
            
            -- test fail increment
            state <= FAIL_INC;
            Inc <= '1';
            for i in 0 to 2**NumBits-1 loop
                wait for 10 ns;
            end loop;
            
            -- test successful load
            state <= SUCC_LOAD;
            LoadEn <= '0';
            for i in 0 to 2**NumBits-1 loop
                PCin <= std_logic_vector(to_unsigned(dat, NumBits));
                wait for 10 ns;
                dat <= dat + 1;
            end loop;
            
            -- test fail load
            state <= FAIL_LOAD;
            LoadEn <= '1';
            for i in 0 to 2**NumBits-1 loop
                PCin <= std_logic_vector(to_unsigned(dat, NumBits));
                wait for 10 ns;
                dat <= dat + 1;
            end loop;
        end loop;
    end process Test;    
end tb_arch;