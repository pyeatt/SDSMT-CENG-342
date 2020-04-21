--Author: Clayton Heeren
--Date: 4/19/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity CPU_testbench is
end CPU_testbench;

architecture Behavioral of CPU_testbench is
    signal clock, reset: std_logic := '0'; 
    signal Mrts, Mrte: std_logic := '1';
    signal Mcem, Moen, Mwen, Mbyte, Mhalf: std_logic;
    signal MAddr, MDatao: std_logic_vector(31 downto 0);
    signal MDatai: std_logic_vector(31 downto 0);
    signal zeros: std_logic_vector(15 downto 0) := "0000000000000000";
    signal temp: unsigned(2 downto 0) := "000";
    signal cur_state, next_state: state_t;
    signal control: control_t_array;
    signal instruction: instruction_t;
begin
    CPU1: entity work.CPU(Behavioral)
         Port Map(clock=>clock, reset=>reset, Mrts=>Mrts, Mrte=>Mrte,
                  Mcem=>Mcem, Moen=>Moen, Mwen=>Mwen, Mbyte=>Mbyte,
                  Mhalf=>Mhalf, MAddr=>MAddr, MDatai=>MDatai, 
                  MDatao=>Mdatao, 
                  cur_state=>cur_state, next_state=>next_state, control=>control,
                  T=>instruction);
----Set-up-----------------------------------------------------------------
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
----Testing-----------------------------------------------------------------
    test: process
    begin
        wait for 30ns; --comes out of reset, FETCHWAIT.
        --next positive edge in 20ns
        wait for 15ns;--FETCH1
        Mrts <= '0';
        Mrte <= '0';
        --wait for 20ns;--FETCH2
        --RI: mov, load registers
        for j in 0 to 5 loop
            temp <= to_unsigned(j, 3);
            MDatai <= zeros & "110" & "00" & "10011001" & std_logic_vector(temp);
            wait for 60ns;
        end loop;
        --add RRR rb: 101, ra: 100, rd: 011
        MDatai <= zeros & "100" & "00" & '0' & '0' & "100" & "011" & "010";
        wait for 60ns;
        --STORE to test registers
        --IT & offset & sz & ra & rs
        Mdatai <= zeros & "01" & "000000" & "10" & "100" & "010";
        Mrts <= '1';
        Mrte <= '1';
        wait for 60ns;
        mrts <= '0';
        mrte <= '0';
        wait for 40ns;
    end process;
end Behavioral;
