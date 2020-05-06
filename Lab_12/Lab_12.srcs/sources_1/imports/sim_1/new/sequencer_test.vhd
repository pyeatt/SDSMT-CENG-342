library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.ALL;

entity sequencer_test is
end sequencer_test;

architecture bench of sequencer_test is
    signal T: instruction_t;
    signal CWin: control_t_array;
    signal CWout: control_t_array;
    signal Mrte: std_logic := '1';
    signal Mrts: std_logic := '1';
    signal clk: std_logic := '0'; 
    signal reset: std_logic := '1';
    
    --Testig stuff 
    signal correct_state: state_t; 
    signal correct_CWout: control_t_array;
    
     
begin
    
    
    sequencer: entity work.sequencer(arch)
        port map (
                    T => T, CWin => CWin, CWout => CWout, Mrte => Mrte, 
                    Mrts => Mrts, clk => clk, reset => reset
                  );
                  
   --start the clock  
    clock: process 
        begin 
            loop 
                clk <= not clk;
                wait for 10 ns;
            end loop;
        end process clock;
        
    --test 
    Test: process 
        begin 
        
        CWin <= (others => '1');
        CWin(Irle) <= '0';
            -- reboot
            wait for 10 ns;
            reset <= '0';
            wait for 10 ns;
            
            -- Start loop 
            correct_state <= START;
            correct_CWout <= START_cw;
            wait for 10 ns;
            
            -- Start to FETCHWAIT
            reset <= '1'; 
            wait for 10 ns;
            correct_state <= FETCHWAIT;
            correct_CWout <= FETCHWAIT_cw;
            wait for 10 ns;
            
            -- FETCHWAIT loop 
            Mrts <= '1';
            wait for 10 ns;
            correct_state <= FETCHWAIT;
            correct_CWout <= FETCHWAIT_cw;
            wait for 10 ns; 
            
            -- FETCHWAIT to FETCH1
            Mrts <= '0';
            wait for 10 ns;
            correct_state <= FETCH1;
            correct_CWout <= FETCH1_cw;
            wait for 10 ns;
            
            -- FETCH1 to FETCH2 
            Mrte <= '1';
            wait for 10 ns;
            correct_state <= FETCH2;
            correct_CWout <= FETCH2_cw;
            wait for 10 ns;
            
            -- FETCH 2 loop
            Mrte <= '1';
            wait for 10 ns;
            correct_state <= FETCH2;
            correct_CWout <= FETCH2_cw;
            wait for 10 ns;
            
            -- FETCH2 to EX1
            Mrts <= '1';
            Mrte <= '0';
            T <= LOAD;
            wait for 10 ns;
            correct_state <= EX1;
            correct_CWout <= CWin OR EX1_mask;
            wait for 10 ns;
        
            -- EX1 to FETCHWAIT 
            Mrts <= '1';
            T <= RR;
            wait for 10 ns;
            correct_state <= FETCHWAIT;
            correct_CWout <= FETCHWAIT_cw; 
            wait for 10 ns;
            
            -- FETCHWAIT to FETCH1
            Mrts <= '0';
            wait for 10 ns;
            correct_state <= FETCH1;
            correct_CWout <= FETCH1_cw; 
            wait for 10 ns;
            
            -- FETCH1 to FETCH2 
            Mrte <= '1';
            wait for 10 ns;
            correct_state <= FETCH2;
            correct_CWout <= FETCH2_cw;
            wait for 10 ns;
            
            -- FETCH 2 to EX1 
            Mrts <= '1';
            Mrte <= '0';
            T <= LOAD;
            wait for 10 ns;
            correct_state <= EX1;
            correct_CWout <= CWin;
            wait for 10 ns;
            
            -- EX1 to FETCH1
            Mrts <= '0';
            T <= RR;
            wait for 10 ns;
            correct_state <= FETCH1;
            correct_CWout <= FETCH1_cw;
            wait for 10 ns;
            
            -- FETCH1 to FETCH 2 
            Mrte <= '1';
            wait for 10 ns;
            correct_state <= FETCH2;
            correct_CWout <= FETCH2_cw;
            wait for 10 ns;
            
            --FETCH2 to EX1
            Mrts <= '0';
            Mrte <= '0';
            T <= LOAD;
            wait for 10 ns;
            correct_state <= EX1;
            correct_CWout <= CWin;
            wait for 10 ns;
            
            -- EX1 to LSDT
            Mrte <= '1';
            wait for 10 ns; 
            correct_state <= LDST; -- helps to spell correctly -_-
            correct_CWout <= CWin;
            wait for 10 ns;
            
            -- LDST to LDST
            Mrte <= '0';
            wait for 10 ns;
            correct_state <= LDST; 
            correct_CWout <= FETCHWAIT_cw;
            wait for 10 ns;
            
      end process;
end bench;
