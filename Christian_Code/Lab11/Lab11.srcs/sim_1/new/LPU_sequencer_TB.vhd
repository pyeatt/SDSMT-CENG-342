----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/22/2020
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
    signal CWin: control_t_array := (others => '1'); -- Mux and register enable signals
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
        
        -- transition from START to START
        expectedState <= START;
        CWoutExpected <= START_cw;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 21 ns
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
        if CWout = CWoutExpected then -- 41 ns
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
        if CWout = CWoutExpected then -- 61 ns
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
        if CWout = CWoutExpected then -- 81 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH1 to FETCH2
        Mrte <= '1';
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
        wait for 1 ns; -- allow time for flags to be set
        if CWout = CWoutExpected then -- 101 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH2 to FETCH2
        Mrte <= '1';
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
        wait for 1 ns; -- allow time for flags to be set
        if CWout = CWoutExpected then -- 121 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH2 to EX1
        Mrte <= '0';
        Mrts <= '1';
        T <= LOAD;
        wait for 19 ns;
        CWoutExpected <= CWin or EX1_mask;
        expectedState <= EX1;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 141 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from EX1 to EX1
        -- transition from EX1 to FETCHWAIT
        Mrts <= '1';
        T <= RR; -- Itype != LDST
        wait for 19 ns;
        CWoutExpected <= FETCHWAIT_cw;
        expectedState <= FETCHWAIT;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 161 ns
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
        if CWout = CWoutExpected then -- 181 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH1 to FETCH2
        Mrte <= '1';
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
        wait for 1 ns; -- allow time for flags to be set
        if CWout = CWoutExpected then -- 201 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH2 to EX1
        Mrte <= '0';
        Mrts <= '1';
        T <= LOAD;
        wait for 19 ns;
        CWoutExpected <= CWin;
        expectedState <= EX1;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 221 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from EX1 to FETCH1
        Mrts <= '0';
        T <= RR; -- Itype != LDST
        wait for 19 ns;
        CWoutExpected <= FETCH1_cw;
        expectedState <= FETCH1;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 241 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH1 to FETCH2
        Mrte <= '1';
        wait for 19 ns; -- allow time for transition
        CWoutExpected <= FETCH2_cw;
        expectedState <= FETCH2;
        wait for 1 ns; -- allow time for flags to be set
        if CWout = CWoutExpected then -- 261 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from FETCH2 to EX1
        Mrte <= '0';
        Mrts <= '0';
        T <= LOAD;
        wait for 19 ns;
        CWoutExpected <= CWin;
        expectedState <= EX1;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 281 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from EX1 to LDST
        Mrte <= '1';
        wait for 19 ns;
        CWoutExpected <= CWin;
        expectedState <= LDST;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 301 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        -- transition from LDST to LDST
        Mrte <= '0';
        wait for 19 ns;
        CWoutExpected <= FETCHWAIT_cw;
        expectedState <= LDST;
        wait for 1 ns;
        if CWout = CWoutExpected then -- 321 ns
            isCorrect <= '1';
        else
            isCorrect <= '0';
        end if;
        
        wait;
    end process;
end Behavioral;
