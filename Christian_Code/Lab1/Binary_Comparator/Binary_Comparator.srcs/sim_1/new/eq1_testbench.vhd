----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 1 
-- Design Name: eq1_testbench
-- Project Name: Binary_Comparator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- testbench for eq1
entity eq1_testbench is
end eq1_testbench;


-- implements testbench by listing every combination manually
architecture tb_arch of eq1_testbench is
    signal test_in0, test_in1: STD_LOGIC;
    signal test_out: STD_LOGIC;
begin
    -- instantiate the circuit under test
    uut: entity work.eq1(sop_arch)
    port map(i0 => test_in0, i1 => test_in1, eq => test_out);    
-- test generator
process
begin
    --test vector 1
    test_in0 <= '0';
    test_in1 <= '0';
    wait for 200 ns;
    --test vector 2
    test_in0 <= '1';
    test_in1 <= '0';
    wait for 200 ns;
    --test vector 3
    test_in0 <= '0';
    test_in1 <= '1';
    wait for 200 ns;
    --test vector 4
    test_in0 <= '1';
    test_in1 <= '1';
    wait for 200 ns;
end process;

end tb_arch;

