----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/28/2020
-- Lab 1, Part 1 
-- Design Name: eq2_loop_testbench
-- Project Name: Binary_Comparator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- testbench for eq2 (both struc_arch & sop_arc)
entity eq2_loop_testbench is
end eq2_loop_testbench;


-- implements testbench by listing every combination with a loop
architecture tb_arch of eq2_loop_testbench is
    signal test_in0, test_in1: STD_LOGIC_VECTOR (1 downto 0);
    signal struc_test_out, sop_test_out: STD_LOGIC;
begin
    -- instantiate the circuit under test
    struc_uut: entity work.eq2(struc_arch)
    port map(a => test_in0, b => test_in1, aeqb => struc_test_out);
    sop_uut: entity work.eq2(sop_arch)
    port map(a => test_in0, b => test_in1, aeqb => sop_test_out);
-- test vector generator
process
begin
    -- iterate through all the possible combinations for test_in0
    for i in 0 to 3 loop
        test_in0 <= STD_LOGIC_VECTOR(to_unsigned(i, 2));
        -- iterate through all the possible combinations for test_in1
        for j in 0 to 3 loop
            test_in1 <= STD_LOGIC_VECTOR(to_unsigned(j, 2));
            wait for 200 ns;
        end loop;
    end loop;

end process;

end tb_arch;
