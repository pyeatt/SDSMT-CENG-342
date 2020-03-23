----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/22/2020
-- Lab 4
-- Design Name: lookahead_2bit_testbench
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lookahead_2bit_testbench is
end lookahead_2bit_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of lookahead_2bit_testbench is
    constant width: integer := 2; -- width of the input buses
    signal A,B: STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Ci: STD_LOGIC;
    signal Co: STD_LOGIC;
begin
    uut : entity work.lookahead_2bit(sop_arch)
          port map(A => A,
                   B => B,
                   Ci => Ci,
                   Co => Co);
   process
       variable I : integer := 0;
   begin
       -- iterate through all the possible inputs
       for I in 0 to 2**(2*width + 1) - 1 loop
           A <= std_logic_vector(to_unsigned(I,7)(2*width downto width + 1));
           B <= std_logic_vector(to_unsigned(I,7)(width downto 1));
           Ci <= std_logic(to_unsigned(I,7)(0));   
           wait for 200ns;
       end loop;
   end process;
end tb_arch;
    
