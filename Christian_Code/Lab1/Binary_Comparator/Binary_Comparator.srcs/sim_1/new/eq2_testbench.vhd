----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 1 
-- Design Name: eq2_testbench
-- Project Name: Binary_Comparator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- testbench for eq2
entity eq2_testbench is
end eq2_testbench;


-- implements testbench by listing every combination manually
architecture tb_arch of eq2_testbench is
    signal test_in0, test_in1: STD_LOGIC_VECTOR (1 downto 0);
    signal test_out: STD_LOGIC;
begin
    -- instantiate the circuit under test
    uut: entity work.eq2(struc_arch)
    port map(a => test_in0, b => test_in1, aeqb => test_out);
-- test vector generator
process
begin
    --test vector 1
    test_in0 <= "00";
    test_in1 <= "00";
    wait for 200 ns;
    --test vector 2
    test_in0 <= "01";
    test_in1 <= "00";
    wait for 200 ns;
    --test vector 3
    test_in0 <= "10";
    test_in1 <= "00";
    wait for 200 ns;
    --test vector 4
    test_in0 <= "11";
    test_in1 <= "00";
    wait for 200 ns;
    --test vector 5
    test_in0 <= "00";
    test_in1 <= "01";
    wait for 200 ns;
    --test vector 6
    test_in0 <= "01";
    test_in1 <= "01";
    wait for 200 ns;
    --test vector 7
    test_in0 <= "10";
    test_in1 <= "01";
    wait for 200 ns;
    --test vector 8
    test_in0 <= "11";
    test_in1 <= "01";
    wait for 200 ns;
    --test vector 9
    test_in0 <= "00";
    test_in1 <= "10";
    wait for 200 ns;
    --test vector 10
    test_in0 <= "01";
    test_in1 <= "10";
    wait for 200 ns;
    --test vector 11
    test_in0 <= "10";
    test_in1 <= "10";
    wait for 200 ns;
    --test vector 12
    test_in0 <= "11";
    test_in1 <= "10";
    wait for 200 ns;
    --test vector 13
    test_in0 <= "00";
    test_in1 <= "11";
    wait for 200 ns;
    --test vector 14
    test_in0 <= "01";
    test_in1 <= "11";
    wait for 200 ns;
    --test vector 15
    test_in0 <= "10";
    test_in1 <= "11";
    wait for 200 ns;
    --test vector 16
    test_in0 <= "11";
    test_in1 <= "11";
    wait for 200 ns;
end process;

end tb_arch;
