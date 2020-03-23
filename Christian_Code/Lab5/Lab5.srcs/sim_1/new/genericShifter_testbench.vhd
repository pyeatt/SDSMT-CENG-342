----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/02/2020
-- Lab 5
-- Design Name: genericShifter_testbench
-- Project Name: Lab5
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity genericShifter_testbench is
end genericShifter_testbench;


-- This checks every possible input and checks the answer
architecture tb_arch of genericShifter_testbench is
    constant numShiftBits: integer := 3; --  number of bits required to represent the shift amount
    constant dataWidth: integer := 2**numShiftBits; --  number of bits required to represent the input/output
    signal din: std_logic_vector(dataWidth - 1 downto 0); -- input
    signal dout: std_logic_vector(dataWidth - 1 downto 0); --  output
    signal shamt: std_logic_vector(numShiftBits - 1 downto 0); -- amount to be shifted
    signal func: std_logic_vector(1 downto 0); -- type of shift-> 00: No shift, 
                                                               -- 01: Logical shift left, 
                                                               -- 10: Logical shift right, 
                                                               -- 11: Arithmetic shift right 
    signal co: std_logic; -- last bit that was shifted out
    signal isCorrect: std_logic := '0'; -- flag signals if uut is working
begin
    uut: entity work.genericShifter(gen_arch)
         generic map(numShiftBits => numShiftBits)
         port map(din => din,
                  dout => dout,
                  shamt => shamt,
                  func => func,
                  co => co);
    process
        variable i: integer := 0;
        variable myShamt: integer; 
        variable myCarryout: std_logic;
        variable myResult: integer;
        variable totalBits: integer := dataWidth + numShiftBits + 2;
    begin
        -- iterate through every possible combination
        for i in 0 to 2**(totalBits) - 1 loop
            func <= std_logic_vector(to_unsigned(i, totalBits)(totalBits - 1 downto totalBits - 2));
            shamt <= std_logic_vector(to_unsigned(i, totalBits)(totalBits - 3 downto dataWidth));
            din <= std_logic_vector(to_unsigned(i, totalBits)(dataWidth - 1 downto 0));         
            
            wait for 1ns; -- force the signals to be evaluated
            
            myShamt := to_integer(unsigned(shamt));
                        
            -- perform the correct shift operation (default carry is '0')
            if func = "00" then --  no shift
                myResult := to_integer(unsigned(din));
                myCarryout := '0';
            elsif func = "01" then -- logical shift left
                myResult := to_integer(shift_left(unsigned(din), myShamt));
                if myShamt > 0 then myCarryout := din(dataWidth - myShamt); else myCarryout := '0'; end if;
            elsif func = "10" then -- logical shift right
                myResult := to_integer(shift_right(unsigned(din), myShamt));
                if myShamt > 0 then myCarryout := din(myShamt - 1); else myCarryout := '0'; end if;
            elsif func = "11" then -- arithmetic shift right
                myResult := to_integer(unsigned(shift_right(signed(din), myShamt)));
                if myShamt > 0 then myCarryout := din(myShamt - 1); else myCarryout := '0'; end if;
            end if;

            -- compare the entity result with the testbench result and set the isCorrect flag
            if myResult = to_integer(unsigned(dout)) and myCarryout = co then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
            
            wait for 199ns;
        end loop;
    end process;     
end tb_arch;
