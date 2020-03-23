----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/21/2020
-- Lab 4
-- Design Name: full_adder_testbench
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity full_adder_testbench is
end full_adder_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of full_adder_testbench is
    signal A_tb : STD_LOGIC;
    signal B_tb : STD_LOGIC;
    signal Ci_tb : STD_LOGIC;
    signal S_tb : STD_LOGIC;
    signal Co_tb : STD_LOGIC;
begin
    uut : entity work.full_adder(sop_arch)
          port map(A => A_tb,
                   B => B_tb,
                   Ci => Ci_tb,
                   S => S_tb,
                   Co => Co_tb);
   process
       variable I : integer := 0;
   begin
       for I in 0 to 7 loop
           A_tb <= std_logic(to_unsigned(I,3)(2));
           B_tb <= std_logic(to_unsigned(I,3)(1));
           Ci_tb <= std_logic(to_unsigned(I,3)(0));   
           wait for 200ns;
       end loop;
   end process;
end tb_arch;
    
