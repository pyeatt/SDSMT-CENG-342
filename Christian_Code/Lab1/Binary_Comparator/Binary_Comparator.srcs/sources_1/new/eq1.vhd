----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 1 
-- Design Name: eq1 - 1-bit comparator
-- Project Name: Binary_Comparator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- eq1 is a 1-bit comparator
-- if i0==i1 then eq=1, else eq=0
entity eq1 is
    Port ( i0, i1 : in STD_LOGIC;
           eq : out STD_LOGIC);
end eq1;


-- Implements eq1 using sum of products
architecture sop_arch of eq1 is
    signal p0, p1: STD_LOGIC;
begin
    -- sum of two product terms
    eq <= p0 or p1;
    -- product terms
    p0 <= i0 and i1;
    p1 <= (not i0) and (not i1);
end sop_arch;
