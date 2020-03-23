----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/18/2020
-- Lab 6
-- Design Name: genericALU_testbench
-- Project Name: Lab6
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity genericALU_testbench is
end genericALU_testbench;


-- this tests all valid combinations in a full-adder
architecture tb_arch of genericALU_testbench is
    constant userWidth : integer := 4;
    constant width : integer := integer(2**(ceil(log2(real(userWidth))))); -- this guarantees that the data width will be a power of 2
    signal A_tb : std_logic_vector(width - 1 downto 0);
    signal B_tb : std_logic_vector(width - 1 downto 0);
    signal Ci_tb : std_logic;
    signal Func_tb : std_logic_vector(3 downto 0);
    signal R_tb : std_logic_vector(width - 1 downto 0);
    signal N_tb : std_logic;
    signal Z_tb : std_logic;
    signal Co_tb : std_logic;
    signal V_tb : std_logic;
    signal isCorrect : std_logic := '0';
begin
                   
    ALU: 
        entity work.genericALU(struct_arch)
        generic map(userWidth => width)
        port map(A => A_tb,
                 B => B_tb,
                 Ci => Ci_tb,
                 Func => Func_tb,
                 R => R_tb,
                 N => N_tb,
                 Z => Z_tb,
                 Co => Co_tb,
                 V => V_tb);
  
-- check every valid input   
process
       constant numShiftBits : integer := integer(ceil(log2(real(width))));
       constant shifterTotalBits : integer := width + numShiftBits + 2;
       variable I : integer := 0;
       variable temp : std_logic_vector(width downto 0);
       variable myA : integer := 0;
       variable myB : integer := 0;
       variable myCi : integer := 0;
       variable myR : integer := 0;
       variable myN : std_logic := '0';
       variable myZ : std_logic := '0'; 
       variable myCo : std_logic := '0'; 
       variable myV : std_logic := '0';      
       variable myShamt : integer := 0;
       variable zeros : std_logic_vector(width downto 0) := (others => '0');
   begin
        -- verify the adder/subtractor (Func = "0xx0")   
        adderSubtractorTest: for I in 0 to 2**(2*width + 3) - 1 loop -- iterate through every possible input combination
           Func_tb(3) <= '0';
           Func_tb(0) <= '0';
           Func_tb(2 downto 1) <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width + 2 downto 2*width + 1));
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
           temp(1 downto 0) := Func_tb(2 downto 1);
           
           -- find the sum
           if Func_tb(2 downto 1) = "10" then -- subtraction
                   myR := myA - myB;
           elsif Func_tb(2 downto 1) = "11" then -- subtraction with carry
                   if myCi = 1 then
                        myR := myA - myB;
                   else
                        myR := myA - myB - 1;
                   end if;
           elsif Func_tb(2 downto 1) = "00" then -- addition
                myR := myA + myB;
           elsif Func_tb(2 downto 1) = "01" then -- addition with carry
                myR := myA + myB + myCi;
           end if;
           
           -- this cuts off the extra bits used by the integer data type
           temp := std_logic_vector(to_unsigned(myR,width + 1)); -- for unsigned addition, the 'width' bit of the integer is the carry
           if Func_tb(2) = '1' then
               temp(width) := not temp(width);--for unsigned subtraction, the NOT('width' bit) of the integer is the carry              
           end if;
           
           -- find the N and Z flags
           myN := temp(width - 1);
           if temp(width - 1 downto 0) = zeros(width - 1 downto 0) then
               myZ := '1';
           else
               myZ := '0';
           end if;
           
           -- Note: must check V by hand
           
           -- compare with the generic full adder/subtractor results
           if to_integer(unsigned(Co_tb & R_tb)) = to_integer(unsigned(temp)) and N_tb = myN and Z_tb = myZ then -- concatenate the carry bit with the sum and compare
               isCorrect <= '1';
           else
               isCorrect <= '0';
           end if;       
           
           wait for 199ns;
       end loop adderSubtractorTest;
       
       logicUnitTest: for I in 0 to 2**(2*width + 3) - 1 loop -- iterate through every possible input combination
           Func_tb(3) <= '1';
           Func_tb(0) <= '1';
           Func_tb(2 downto 1) <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width + 2 downto 2*width + 1));
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width downto width + 1));
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(width downto 1));
           Ci_tb <= std_logic(to_unsigned(I,2*width + 3)(0));
           
           wait for 1ns; -- force the signals to be evaluated
                        
            -- perform the correct logical operation
            if Func_tb(2 downto 1) = "00" then --  not B
                myR := to_integer(unsigned(not B_tb));
            elsif Func_tb(2 downto 1) = "01" then -- A and B
                myR := to_integer(unsigned(A_tb and B_tb));
            elsif Func_tb(2 downto 1) = "10" then -- A or B
                myR := to_integer(unsigned(A_tb or B_tb));
            elsif Func_tb(2 downto 1) = "11" then -- A xor B
                myR := to_integer(unsigned(A_tb xor B_tb));
            end if;
            
           -- find the N and Z flags
           myN := std_logic(to_unsigned(myR,width)(width - 1));
           if myR = 0 then
               myZ := '1';
           else
               myZ := '0';
           end if;
           
           -- find the Co and V flags
           myCo := '0'; -- default value
           myV := '0'; -- default value

            -- compare the entity result with the testbench result and set the isCorrect flag
            if myR = to_integer(unsigned(R_tb)) and N_tb = myN and Z_tb = myZ and Co_tb = myCo and V_tb = myV then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
            
            wait for 199ns;
       end loop logicUnitTest;
       
        -- iterate through every possible combination (note: since the no-shift function is not supported ("00"), I starts at a value later than 0_
        shifterTest: for I in 2**(2*width + 1) to 2**(2*width + 3) - 1 loop
            Func_tb(3) <= '1';
            Func_tb(0) <= '0';            
            Func_tb(2 downto 1) <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width + 2 downto 2*width + 1));
            A_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(2*width downto width + 1));
            B_tb <= std_logic_vector(to_unsigned(I,2*width + 3)(width downto 1));
            Ci_tb <= std_logic(to_unsigned(I,2*width + 3)(0));       
            
            wait for 1ns; -- force the signals to be evaluated
            
            myShamt := to_integer(unsigned(B_tb(numShiftBits - 1 downto 0)));
                        
            -- perform the correct shift operation (default carry is '0')
            if Func_tb(2 downto 1) = "00" then --  no shift
                myR := to_integer(unsigned(A_tb));
                myCo := '0';
            elsif Func_tb(2 downto 1) = "01" then -- logical shift left
                myR := to_integer(shift_left(unsigned(A_tb), myShamt));
                if myShamt > 0 then myCo := A_tb(width - myShamt); else myCo := '0'; end if;
            elsif Func_tb(2 downto 1) = "10" then -- logical shift right
                myR := to_integer(shift_right(unsigned(A_tb), myShamt));
                if myShamt > 0 then myCo := A_tb(myShamt - 1); else myCo := '0'; end if;
            elsif Func_tb(2 downto 1) = "11" then -- arithmetic shift right
                myR := to_integer(unsigned(shift_right(signed(A_tb), myShamt)));
                if myShamt > 0 then myCo := A_tb(myShamt - 1); else myCo := '0'; end if;
            end if;
            
            -- find the N and Z flags
            myN := std_logic(to_unsigned(myR,width)(width - 1));
            if myR = 0 then
               myZ := '1';
            else
               myZ := '0';
            end if;
           
            -- find the Co and V flags
            if Func_tb = "1010" then -- left shift
                myV := std_logic(to_unsigned(myR,width)(width - 1)) xor A_tb(width - 1);
            else
                myV := '0'; -- default value
            end if;

            -- compare the entity result with the testbench result and set the isCorrect flag
            if myR = to_integer(unsigned(R_tb)) and N_tb = myN and Z_tb = myZ and Co_tb = myCo and V_tb = myV then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
            
            wait for 199ns;
        end loop shifterTest;
        
        passBTest: for I in 0 to 2**(2*width + 1) - 1 loop -- iterate through every possible input combination
           Func_tb <= "1000";
           A_tb <= std_logic_vector(to_unsigned(I,2*width + 1)(2*width downto width + 1));
           B_tb <= std_logic_vector(to_unsigned(I,2*width + 1)(width downto 1));
           Ci_tb <= std_logic(to_unsigned(I,2*width + 1)(0));
           
           wait for 1ns; -- force the signals to be evaluated
           
           -- perform the correct pass operation
           myR := to_integer(unsigned(B_tb));
           
           -- find the N and Z flags
           myN := std_logic(to_unsigned(myR,width)(width - 1));
           if myR = 0 then
               myZ := '1';
           else
               myZ := '0';
           end if;
           
           -- find the Co and V flags
           myCo := '0'; -- default value
           myV := '0'; -- default value
           
           -- compare the entity result with the testbench result and set the isCorrect flag
            if myR = to_integer(unsigned(R_tb)) and N_tb = myN and Z_tb = myZ and Co_tb = myCo and V_tb = myV then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
           
           wait for 199ns;
       end loop passBTest;
       
   end process;
end tb_arch;
    
