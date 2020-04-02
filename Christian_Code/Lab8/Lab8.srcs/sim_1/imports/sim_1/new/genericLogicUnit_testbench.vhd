----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/04/2020
-- Lab 6
-- Design Name: genericLogicUnit_testbench
-- Project Name: Lab6
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity genericLogicUnit_testbench is
end genericLogicUnit_testbench;


-- this tests all combinations in a full-adder
architecture tb_arch of genericLogicUnit_testbench is
    constant width : integer := 4;
    signal Func_tb : STD_LOGIC_VECTOR(1 downto 0);
    signal A_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal B_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal R_tb : STD_LOGIC_VECTOR(width - 1 downto 0);
    signal isCorrect : STD_LOGIC; -- 1->results are correct; 0->results are incorrect
begin
                   
    logicUnit : entity work.genericLogicUnit(select_arch)
              generic map(width => width)
                          port map(A => A_tb,
                                   B => B_tb,
                                   Func => Func_tb,
                                   R => R_tb);
                       
process
       variable I : integer := 0;
       variable temp : STD_LOGIC_VECTOR(width downto 0);
       variable myA : integer := 0;
       variable myB : integer := 0;
       variable myR : integer := 0;
   begin
       for I in 0 to 2**(2*width + 2) - 1 loop -- iterate through every possible input combination
           Func_tb <= std_logic_vector(to_unsigned(I,2*width + 2)(2*width + 1 downto 2*width));
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 2)(2*width - 1 downto width));
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 2)(width - 1 downto 0));
           
           wait for 1ns; -- force the signals to be evaluated
                        
            -- perform the correct logical operation
            if Func_tb = "00" then --  not B
                myR := to_integer(unsigned(not B_tb));
            elsif Func_tb = "01" then -- A and B
                myR := to_integer(unsigned(A_tb and B_tb));
            elsif Func_tb = "10" then -- A or B
                myR := to_integer(unsigned(A_tb or B_tb));
            elsif Func_tb = "11" then -- A xor B
                myR := to_integer(unsigned(A_tb xor B_tb));
            end if;

            -- compare the entity result with the testbench result and set the isCorrect flag
            if myR = to_integer(unsigned(R_tb)) then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
            
            wait for 199ns;
       end loop;
   end process;
end tb_arch;
    
