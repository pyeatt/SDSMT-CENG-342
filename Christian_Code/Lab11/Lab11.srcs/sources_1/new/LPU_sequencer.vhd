----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/22/2020
-- Lab 11
-- Design Name: LPU_sequencer
-- Project Name: Lab11
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LPU_helperPKG.all;


entity LPU_sequencer is
    port(
        Mrte: in std_logic;
        Mrts: in std_logic;
        T : in instruction_t; -- instruction type
        CWin: in control_t_array; -- Mux and register enable signals
        CWout: out control_t_array; -- Mux and register enable signals
        clk: in std_logic; -- clock
        reset: in std_logic -- reset (active low)
        );
end LPU_sequencer;


architecture Behavioral of LPU_sequencer is
    signal curState: state_t := START; -- current state of the sequencer
    signal nextState: state_t; -- next state of the sequencer
begin
    -- next state
    nextState <= START when reset = '0' else
        FETCHWAIT when (curState = START and reset = '1') or 
                       (curState = FETCHWAIT and Mrts = '1')  or 
                       (curState = EX1 and not(T = LOAD or T = STORE) and Mrts = '1') or
                       (curState = LDST and Mrte = '0') else
        FETCH1 when (curState = FETCHWAIT and Mrts = '0') or
                    (curState = EX1 and not(T = LOAD or T = STORE) and Mrts = '0') else
        FETCH2 when (curState = FETCH1 and reset = '1') or
                    (curState = FETCH2 and Mrte = '1') else
        EX1 when (curState = FETCH2 and Mrte = '0') or
                 (curState = EX1 and (T = LOAD or T = STORE) and Mrts = '1') else
        LDST when (curState = EX1 and (T = LOAD or T = STORE) and Mrts = '0') or
                  (curState = LDST and Mrte = '1') else
        ERROR;
    
    
    -- flip-flop
    process(clk)
    begin
        if(clk'event and clk = '1') then -- trigger on rising clock edge
            curState <= nextState;
        end if;
    end process;
    
    
    -- output logic
    CWout <= START_cw when curState = START else
        FETCHWAIT_cw when curState = FETCHWAIT else
        FETCH1_cw when curState = FETCH1 else
        FETCH2_proceed_cw when curState = FETCH2 and Mrte = '0' else
        FETCH2_cw when curState = FETCH2 and Mrte = '1' else
        CWin or Ex1_mask when curState = EX1 and (T = LOAD or T = STORE) and Mrts = '1' else
        CWin;

end Behavioral;
