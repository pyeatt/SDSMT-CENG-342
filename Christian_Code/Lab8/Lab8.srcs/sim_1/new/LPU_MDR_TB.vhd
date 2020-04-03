----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_MDR_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_MDR_TB is
end LPU_MDR_TB;


-- testbench for LPU Memory Data Register
architecture tb_arch of LPU_MDR_TB is
    constant NumBits: integer := 32;
    signal MDRin: std_logic_vector(NumBits-1 downto 0) := (others => '0'); -- Data bus to load in a new value to the MDR
    signal MDRout: std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the MDR
    signal LoadEn: std_logic := '1'; -- Active low enable for loading in a new value to the MDR
    signal Clock: std_logic := '1'; -- Clock (triggered on rising edge)
    signal Reset: std_logic := '1'; -- Active low syncronous reset
    signal Control: unsigned(NumBits+1 downto 0) := (others => '0'); -- internal signal
begin
    MDR:
        entity work.LPU_MDR(arch)
        generic map(
            NumBits => NumBits
            )
        port map(
            MDRin => MDRin,
            MDRout => MDRout,
            LoadEn => LoadEn,
            Clock => Clock,
            Reset => Reset
            );
    
    TestReset: process
    begin
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait;
    end process TestReset;
    
    TestLoadEn: process
    begin
        LoadEn <= '1';
        wait for 10 ns;
        loop
            LoadEn <= '0';
            wait for 35 ns;
            LoadEn <= '1';
            wait for 10 ns;
        end loop;
    end process TestLoadEn;
    
    TestInput: process
    begin
        wait for 5 ns;
        loop
            wait for 10 ns;
            Control <= Control + 1;
        end loop;
    end process TestInput;
    
    MDRin <= std_logic_vector(Control(NumBits+1 downto 2));
    Clock <= Control(0);

end tb_arch;
