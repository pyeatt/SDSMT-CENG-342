----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/24/2020
-- Lab 4
-- Design Name: generic_full_adder_subtractor_testbench
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity generic_full_adder_subtractor_testbench is
end generic_full_adder_subtractor_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of generic_full_adder_subtractor_testbench is
    constant width : integer := 4;
    signal A_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal B_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Ci_tb : STD_LOGIC;
    signal Sub_tb : STD_LOGIC;
    signal S_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Co_tb : STD_LOGIC;
    signal V_tb : STD_LOGIC;
    signal isCorrect : STD_LOGIC := '1'; -- 1->results are correct; 0->results are incorrect
begin
    uut : entity work.generic_full_adder_subtractor(gen_arch)
          generic map(width => width)
          port map(A => A_tb,
                   B => B_tb,
                   Ci => Ci_tb,
                   Sub => Sub_tb,
                   S => S_tb,
                   Co => Co_tb,
                   V => V_tb);
   process
       variable I : integer := 0;
       variable temp : STD_LOGIC_VECTOR(width downto 0);
       variable myA : integer := 0;
       variable myB : integer := 0;
       variable myCi : integer := 0;
       variable mySub : integer := 0;
       variable myS : integer := 0;
   begin
       for I in 0 to 2**(2*width + 2) - 1 loop -- iterate through every possible input combination
           -- first set of 'width' bits are first operand
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 2)(2*width + 1 downto width + 2));
           -- second set of 'width' bits are second operand
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 2)(width + 1 downto 2));
           -- second-to-last bit is the carry in
           Ci_tb <= std_logic(to_unsigned(I,2*width + 2)(1));
           -- LSB is subtract flag
           Sub_tb <= std_logic(to_unsigned(I,2*width + 2)(0));
           
           wait for 1ns; -- this forces the signals to be updated so they can be assigned below
           
           -- convert inputs into integers
           myA := to_integer(unsigned(A_tb));
           myB := to_integer(unsigned(B_tb));
           temp := (others => '0');
           temp(0) := Ci_tb;
           myCi := to_integer(unsigned(temp));
           temp(0) := Sub_tb;
           mySub := to_integer(unsigned(temp));
           
           -- find the sum
           if mySub = 1 then -- subtraction
               if myCi = 1 then -- subtraction with carry
                   myS := myA - myB - 1;
               else -- subtraction without carry
                   myS := myA - myB;
               end if;
               
               temp := std_logic_vector(to_unsigned(myS,width + 1));
               temp(width) := not temp(width);--for unsigned subtraction, the NOT('width' bit) of the integer is the carry              
           else -- addition
               if myCi = 1 then -- addition with carry
                   myS := myA + myB + 1;
               else -- addition without carry
                   myS := myA + myB;
               end if;

               temp := std_logic_vector(to_unsigned(myS,width + 1)); -- for unsigned addition, the 'width' bit of the integer is the carry
           end if;
           
           -- compare with the generic full adder/subtractor results
           if to_integer(unsigned(Co_tb & S_tb)) /= to_integer(unsigned(temp)) then -- concatenate the carry bit with the sum and compare
               isCorrect <= '0';
           else
               isCorrect <= '1';
           end if;       
           
           wait for 199ns;
       end loop;
   end process;
end tb_arch;
    
