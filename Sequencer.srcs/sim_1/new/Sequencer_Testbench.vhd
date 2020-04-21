--Author: Clayton Heeren
--Date: 4/19/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity Sequencer_Testbench is
end Sequencer_Testbench;

architecture Behavioral of Sequencer_Testbench is
    signal clock, reset: std_logic := '0';
    signal Mrte, Mrts: std_logic := '1';
    signal CWin, CWout: control_t_array;
    signal T: instruction_t;
    signal cur_state, next_state: state_t;
begin
    --sequencer
    SEQ: entity work.Sequencer(Behavioral)
         Port Map(Mrte=>Mrte, Mrts=>Mrts, CWin=>CWin, CWout=>CWout,
                  clk=>clock, reset=>reset, T=>T, cur_state_temp=>cur_state,
                  next_state_temp=>next_state);
    --reset
    rst: process
    begin
        wait for 15ns;
        reset <= '1';
        wait;
    end process;
    clk: process
    begin
        wait for 10ns;
        loop
            clock <= not clock;
            wait for 10ns;
        end loop;
    end process;
    --testing
    test: process
    begin
        --CWin should not matter at this state
        CWin <= "10101111000100110";
        T <= LOAD;
        --starts at START during reset
        --after 10ns, should go to FETCHWAIT
        --CWout should be FETCHW_cw
        wait for 35ns;
        --should go to FETCH1 when mrts goes to '0'
        Mrts <= '0';
        --CWout should now be FETCH1_CW
        wait for 20ns;
        --should now be in FETCH2
        --should stay here until Mrte goes to '0'
        wait for 40ns;
        Mrte <= '0';
        Mrts <='1';
        --should now go to EX1
        --CWout should now be FETCH2_proceed_cw
        wait for 40ns;
        Mrts <= '0';
        Mrte <= '1';
        wait for 40ns;
        Mrte <= '0';
        mrts <= '1';
        wait for 20ns;
        Mrte <= '1';
        Mrts <= '1';
        T <= RRR;
        wait for 40ns;
        Mrts <= '0';
        wait for 20ns;
        Mrts <= '0';
        Mrte <= '0';
        wait for 20ns;
        wait for 20ns;
        wait for 20ns;
    end process;
end Behavioral;
