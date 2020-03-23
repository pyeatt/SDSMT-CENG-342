----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/04/2020
-- Lab 4
-- Design Name: generic_full_adder_subtractor_lookahead_testbench
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity generic_full_adder_subtractor_lookahead_testbench is
end generic_full_adder_subtractor_lookahead_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of generic_full_adder_subtractor_lookahead_testbench is
    constant width : integer := 4;
    signal A_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal B_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Ci_tb : STD_LOGIC;
    signal Func_tb : STD_LOGIC_VECTOR(1 downto 0);
    signal S_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal Co_tb : STD_LOGIC;
    signal V_tb : STD_LOGIC;
    signal isCorrect : STD_LOGIC; -- 1->results are correct; 0->results are incorrect
begin
                   
    full_adder_lookahead : entity work.generic_full_adder_subtractor_lookahead(gen_arch)
              generic map(width => width)
                          port map(A => A_tb,
                                   B => B_tb,
                                   Ci => Ci_tb,
                                   Func => Func_tb,
                                   S => S_tb,
                                   Co => Co_tb,
                                   V => V_tb);
                       
process
       variable I : integer := 0;
       variable temp : STD_LOGIC_VECTOR(width downto 0);
       variable myA : integer := 0;
       variable myB : integer := 0;
       variable myCi : integer := 0;
       variable myS : integer := 0;
   begin
       for I in 0 to 2**(2*width + 3) - 1 loop -- iterate through every possible input combination
           Func_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width + 2 downto 2*width + 1));
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width downto width + 1));
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(width downto 1));
           Ci_tb <= std_logic(to_unsigned(I,2*width + 3)(0));
           
           wait for 1ns; -- this forces the signals to be updated so they can be assigned below
           
           -- convert inputs into integers
           myA := to_integer(unsigned(A_tb));
           myB := to_integer(unsigned(B_tb));
           temp := (others => '0');
           temp(0) := Ci_tb;
           myCi := to_integer(unsigned(temp));
           temp(1 downto 0) := Func_tb;
           
           -- find the sum
           if Func_tb = "10" then -- subtraction
                   myS := myA - myB;
           elsif Func_tb = "11" then -- subtraction with carry
                   if myCi = 1 then
                        myS := myA - myB;
                   else
                        myS := myA - myB - 1;
                   end if;
           elsif Func_tb = "00" then -- addition
                myS := myA + myB;
           elsif Func_tb = "01" then -- addition with carry
                myS := myA + myB + myCi;
           end if;
           
           -- this cuts off the extra bits used by the integer data type
           temp := std_logic_vector(to_unsigned(myS,width + 1)); -- for unsigned addition, the 'width' bit of the integer is the carry
           if Func_tb(1) = '1' then
               temp(width) := not temp(width);--for unsigned subtraction, the NOT('width' bit) of the integer is the carry              
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
    
