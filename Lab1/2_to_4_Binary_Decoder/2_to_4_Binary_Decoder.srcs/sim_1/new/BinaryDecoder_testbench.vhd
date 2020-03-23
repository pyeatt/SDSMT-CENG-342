----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 2
-- Design Name: BinaryDecoder_testbench
-- Project Name: 2to4BinaryDecoder
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- testbench for BinaryDecoder
entity BinaryDecoder_testbench is
end BinaryDecoder_testbench;


-- implements testbench
architecture tb_arch of BinaryDecoder_testbench is
    signal test_in: STD_LOGIC_VECTOR (1 downto 0);
    signal test_out: STD_LOGIC_VECTOR (3 downto 0);
begin
    -- instantiate the circuit under test
    uut: entity work.BinaryDecoder(decoder_arch)
    port map(a => test_in, Q => test_out);
-- test vector generator
process
begin
    -- loop through all possible values
    for i in 0 to 3 loop
        test_in <= STD_LOGIC_VECTOR(to_unsigned(i, 2));
        wait for 200 ns;
    end loop;

end process;

end tb_arch;
