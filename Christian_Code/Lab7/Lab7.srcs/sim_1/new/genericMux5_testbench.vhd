----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericMux5_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------
-- test time for 8-bit: 40ns


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;


-- entity declaration for testbench
entity genericMux5_testbench is
end genericMux5_testbench;


-- this tests genericMux5 using set values
architecture tb_arch of genericMux5_testbench is
    constant selBits: integer := 2; -- do not change
    signal sel: std_logic_vector(selBits-1 downto 0);
    signal in0: std_logic_vector(4 downto 0) := "00001";
    signal in1: std_logic_vector(4 downto 0) := "00010";
    signal in2: std_logic_vector(4 downto 0) := "00011";
    signal in3: std_logic_vector(4 downto 0) := "11111";
    signal output: std_logic_vector(4 downto 0);
    signal testin: unsigned(selBits-1 downto 0):= (others=>'0');
begin
    uut: entity work.genericMux5(proc_arch)
    generic map(sel_bits => selBits)
    port map(
        sel => sel,
        Y => output,
        d_in(0) => in0,
        d_in(1)=>in1,
        d_in(2)=>in2,
        d_in(3)=>in3
        );
    
    -- itereate through test cases
    process
    begin
        loop
            wait for 10 ns;
            testin <= testin + 1;
        end loop;
    end process;
    
    sel <= std_logic_vector(testin);
    
end tb_arch;