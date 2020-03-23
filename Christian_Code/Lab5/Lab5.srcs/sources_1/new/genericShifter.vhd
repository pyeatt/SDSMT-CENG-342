----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/02/2020
-- Lab 5
-- Design Name: genericShifter
-- Project Name: Lab5
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a genericShifter
entity genericShifter is
    generic (numShiftBits: integer := 3); --  number of bits required to represent the shift amount
    Port (din: in std_logic_vector(2**numShiftBits - 1 downto 0); -- input
          dout: out std_logic_vector(2**numShiftBits - 1 downto 0); --  output
          shamt: in std_logic_vector(numShiftBits - 1 downto 0); -- amount to be shifted
          func: in std_logic_vector(1 downto 0); -- type of shift-> 00: No shift, 
                                                                 -- 01: Logical shift left, 
                                                                 -- 10: Logical shift right, 
                                                                 -- 11: Arithmetic shift right 
          co: out std_logic); -- Last bit that was shifted out
end genericShifter;


-- This implements the 8-bit shifter using staged design within a generate statement
architecture gen_arch of genericShifter is
    constant dataWidth: integer := 2**numShiftBits; --  number of bits required to represent the input/output
    type array2DLogic is array(numShiftBits downto 0) of std_logic_vector(dataWidth + 1 downto 0);
    signal s: array2DLogic := (others => (others => '0')); -- stores temporary values between shifts
    signal zeros: std_logic_vector(dataWidth + 1 downto 0) := (others => '0'); -- allows zero padding
    signal ones: std_logic_vector(dataWidth + 1 downto 0) := (others => '1'); -- allows one padding
begin
    s(0) <= '0' & din & '0'; -- pad the input so the carries can be captured in both directions
    
    -- generate a staged design structure
    gen_shifter: for I in 0 to numShiftBits - 1 generate
    begin
                    -- No shift
        s(I + 1) <= s(I) when func = "00" else
                    -- Logical shift left
                    s(I)(dataWidth - 2**I + 1 downto 1) & zeros(2**I downto 0) when func = "01" and shamt(I) = '1' else
                    s(I) when func = "01" else
                    -- Logical shift right + Arithmetic shift right (if positive) 
                    zeros(2**I downto 0) & s(I)(dataWidth downto 2**I) when (func = "10" or (func = "11" and din(dataWidth - 1) = '0')) and shamt(I) = '1' else
                    s(I) when func = "10" else
                    -- Arithmetic shift right (if negative)  
                    ones(2**I downto 0) & s(I)(dataWidth downto 2**I) when func = "11" and din(dataWidth - 1) = '1' and shamt(I) = '1' else
                    s(I) when func = "11";
    end generate gen_shifter;
    
    -- extract the output from between the two "padding" bits
    dout <= s(numShiftBits)(dataWidth downto 1);
    
    -- extract the carry based upon the shift type
    co <= s(numShiftBits)(dataWidth + 1) when func = "01" else -- if logical left shift
          s(numShiftBits)(0) when func = "11" or func = "10" else -- if logical or arithmetic right shift
          '0'; --  if no shift
end gen_arch;
