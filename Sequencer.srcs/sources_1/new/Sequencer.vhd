--Author: Clayton Heeren
--Date: 4/19/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity Sequencer is
    Port ( Mrte, Mrts: in std_logic;
           clk, reset: in std_logic;
           CWin: in control_t_array;
           T: in instruction_t;
           CWout: out control_t_array;
           cur_state_temp, next_state_temp: out state_t--remove when not simulating
           );
end Sequencer;

architecture Behavioral of Sequencer is
    signal cur_state, next_state: state_t;  
begin
----clock logic---------------------------------------------
    process(clk)
    begin
        if (clk'event and clk='1') then
            cur_state <= next_state;
        end if;
    end process;
------------------------------------------------------------
    next_state <= START when reset = '0' else
                  FETCHWAIT when (cur_state = START) or
                                 (cur_state = FETCHWAIT and Mrts = '1') or 
                                 (cur_state = LDST and Mrte = '0') or
                                 (cur_state = EX1 and (T /= LOAD and T /= STORE) and Mrts = '1') else
                  FETCH1 when (cur_state = FETCHWAIT and Mrts = '0') or
                              (cur_state = EX1 and (T /= LOAD and T /= STORE) and Mrts = '0') else
                  FETCH2 when (cur_state = FETCH1) or
                              (cur_state = FETCH2 and Mrte = '1') else
                  EX1 when (cur_state = FETCH2 and Mrte = '0') else
                  LDST when (cur_state = EX1 and (T = LOAD or T = STORE) and Mrts = '0') or
                            (cur_state = LDST and Mrte = '1') else
                  cur_state;
    CWout <= START_cw when (cur_state = START)  else
             FETCHWAIT_cw when cur_state = FETCHWAIT else
             FETCH1_cw when cur_state = FETCH1 else
             FETCH2_cw when cur_state = FETCH2 and next_state = FETCH2 and Mrte = '1' else
             FETCH2_proceed_cw when cur_state = FETCH2 and next_state = EX1 and Mrte = '0' else
             CWin or EX1_mask when cur_state = EX1 and next_state = EX1 and (T = LOAD or T = STORE) and Mrts = '1' else
             CWin when cur_state = EX1 and (next_state = FETCHWAIT or next_state = FETCH1) else
             CWin when cur_state = EX1 and next_state = LDST and Mrts = '0' else
             CWin when cur_state = LDST and next_state = LDST and Mrte = '1' else
             CWin or EX1_mask when cur_state = LDST and next_state = FETCHWAIT and Mrte = '0';
    --testing outputs
    cur_state_temp <= cur_state;--remove when not simulating
    next_state_temp <= next_state;--remove when not simulating
end Behavioral;
