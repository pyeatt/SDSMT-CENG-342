----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/22/2020
-- Lab 4
-- Design Name: generic_full_adder_testbench
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity generic_full_adder_testbench is
end generic_full_adder_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of generic_full_adder_testbench is
    constant width : integer := 4;
    signal A_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal B_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Ci_tb : STD_LOGIC;
    signal S_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Co_tb : STD_LOGIC;
    signal V_tb : STD_LOGIC;
    signal isCorrect : STD_LOGIC := '1'; -- 1->results are correct; 0->results are incorrect
begin
    uut : entity work.generic_full_adder(gen_arch)
          generic map(width => width)
          port map(A => A_tb,
                   B => B_tb,
                   Ci => Ci_tb,
                   S => S_tb,
                   Co => Co_tb,
                   V => V_tb);
   process
       variable I : integer := 0;
       variable temp : STD_LOGIC_VECTOR(0 downto 0);
       variable myA : integer := 0;
       variable myB : integer := 0;
       variable myCi : integer := 0;
       variable myS : integer := 0;
   begin
       for I in 0 to 2**(2*width + 1) - 1 loop -- iterate through every possible input combination
           -- first set of 'width' bits are first operand
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 1)(2*width downto width + 1));
           -- second set of 'width' bits are second operand
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 1)(width downto 1));
           -- LSB is carry in
           Ci_tb <= std_logic(to_unsigned(I,2*width + 1)(0));
                      
           wait for 1ns; -- this forces the signals to be updated so they can be assigned below

           -- convert inputs into integers
           myA := to_integer(unsigned(A_tb));
           myB := to_integer(unsigned(B_tb));
           temp(0) := Ci_tb;
           myCi := to_integer(unsigned(temp));
           
           -- find the sum
           myS := myA + myB + myCi;
           
           -- compare with the generic full adder results
           if to_integer(unsigned(Co_tb & S_tb)) /= myS then -- concatenate the carry bit with the sum and compare
               isCorrect <= '0';
           else
               isCorrect <= '1';
           end if;       
           
           wait for 199ns;
       end loop;
   end process;
end tb_arch;
    
