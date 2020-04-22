----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/21/2020
-- Lab 11
-- Design Name: LPU_sequencer_TB
-- Project Name: Lab11
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LPU_helperPKG.all;


entity LPU_sequencer_TB is
end LPU_sequencer_TB;


architecture Behavioral of LPU_sequencer_TB is
    signal Mrte: std_logic := '1';
    signal Mrts: std_logic := '1';
    signal T : instruction_t; -- instruction type
    signal CWin: control_t_array := (others => '0'); -- Mux and register enable signals
    signal CWout: control_t_array; -- Mux and register enable signals
    signal clk: std_logic := '0'; -- clock
    signal reset: std_logic := '1'; -- reset (active low)
    
    signal expectedState: state_t := ERROR;
    signal CWoutExpected: control_t_array; -- Mux and register enable signals 
    signal isCorrect: std_logic := 'U';
begin
    
    sequencer:
        entity work.LPU_sequencer(Behavioral)
        port map(
            Mrte => Mrte,
            Mrts => Mrts,
            T => T,
            CWin => CWin,
            CWout => CWout,
            clk => clk,
            reset => reset
            );    
    
    process
    begin
        loop
            clk <= not clk;
            wait for 10 ns;
        end loop;
    end process;
    
    process
    begin
        -- reset system
        wait for 15 ns;
        reset <= '0';
        wait for 5 ns;
        expectedState <= START;
        CWoutExpected <= START_cw;
        wait for 1 ns;
        if CWout = CWoutExpected then
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from START to FETCHWAIT
        reset <= '1';
        wait for 19 ns;
        CWoutExpected <= FETCHWAIT_cw;
        expectedState <= FETCHWAIT;
        wait for 1 ns;
        if CWout = CWoutExpected then
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        
        -- transition from FETCHWAIT to FETCHWAIT
        Mrts <= '1';
        wait for 19 ns;
        CWoutExpected <= FETCHWAIT_cw;
        expectedState <= FETCHWAIT;
        wait for 1 ns;
        if CWout = CWoutExpected then
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCHWAIT to FETCH1
        Mrts <= '0';
        wait for 19 ns;
        CWoutExpected <= FETCH1_cw;
        expectedState <= FETCH1;
        wait for 1 ns;
        if CWout = CWoutExpected then
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH1 to FETCH2
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
        wait for 1 ns; -- allow time for flags to be set
        if CWout = CWoutExpected then
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH2 to FETCH2
        Mrte <= '1';
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
--        wait for 1 ns; -- allow time for flags to be set
--        if CWout = CWoutExpected then
--            isCorrect <= '1';
--        else
--            isCorrect <= '0';
--        end if;
        
        -- transition from FETCH2 to EX1
        wait for 19 ns;
        Mrte <= '0';
        CWoutExpected <= FETCH2_proceed_cw;
        expectedState <= EX1;
        wait for 1 ns;
--        if CWout = CWoutExpected then
--            isCorrect <= '1';
--        else
--            isCorrect <= '0';
--        end if;
        
        -- transition from EX1 to EX1
        wait for 19 ns;
        
        wait;
        
        
    end process;

end Behavioral;
