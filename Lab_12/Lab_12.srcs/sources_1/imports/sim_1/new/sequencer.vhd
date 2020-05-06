library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.ALL;

entity sequencer is
    Port (
            T: in instruction_t;
            CWin: in control_t_array;
            CWout: out control_t_array;
            Mrte, Mrts: in std_logic;
            clk, reset: in std_logic 
          );
end sequencer;

architecture arch of sequencer is
    signal current_state, next_state: state_t;
    --signal latched_out: control_t_array;
begin

        -- start the clock
       process(clk)
            begin
                if (clk'event and clk ='1') then 
                current_state <= next_state; 
                end if;
        end process; 
        
       -- Next state logic
       next_state <= Start when reset = '0' else 
            FETCHWAIT when ((current_state = Start) AND (reset = '1')) OR
                ((current_state = FETCHWAIT) AND (Mrts = '1')) OR
                ((current_state = EX1) AND NOT(T = LOAD OR T = STORE OR T = PCRL) AND Mrts ='1') OR
                ((current_state = LDST) AND (Mrte = '0')) else 
            FETCH1 when ((current_state = FETCHWAIT) AND (Mrts ='0')) OR 
                ((current_state = EX1) AND NOT(T = LOAD OR T = STORE OR T = PCRL) AND Mrts ='0') else
            FETCH2 when ((current_state  = FETCH1) AND (reset = '1')) OR 
                ((current_state = FETCH2) AND (Mrte = '1')) else 
            EX1 when ((current_state = FETCH2) AND (Mrte = '0')) OR 
                ((current_state = EX1) AND (T = LOAD OR T = STORE OR T = PCRL) AND Mrts ='1') else
            LDST when ((current_state = EX1) AND (T = LOAD OR T = STORE OR T = PCRL) AND Mrts ='0') OR
                ((current_state = LDST) AND (Mrte = '1')) else 
            current_state;
            
             
        
       -- Output state logic 
       CWout <= START_cw when current_state = START  else
            FETCHWAIT_cw when current_state = FETCHWAIT  else 
            FETCH1_cw when current_state = FETCH1  else
            FETCH2_cw when (current_state = FETCH2 AND Mrte = '1') else 
            FETCH2_proceed_cw when (current_state = FETCH2 AND Mrte = '0') else 
            (CWin OR EX1_mask) when ((current_state = LDST) AND (Mrte = '0'))  
                    OR ((current_state = EX1) AND (T = LOAD OR T = STORE OR T = PCRL) AND (Mrts ='1')) else
            Cwin;
            
end arch;
