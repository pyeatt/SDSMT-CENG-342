----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 1 
-- Design Name: eq2 - 2-bit comparator
-- Project Name: Binary_Comparator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- eq2 is a 2-bit comparator
-- if a==b then aeqb=1, else aeqb=0
entity eq2 is
    Port ( a : in STD_LOGIC_VECTOR (1 downto 0);
           b : in STD_LOGIC_VECTOR (1 downto 0);
           aeqb : out STD_LOGIC);
end eq2;


-- Implements eq2 using sum of products
architecture sop_arch of eq2 is
    signal p0,p1,p2,p3: STD_LOGIC;
begin
    -- sum of products term
    aeqb <= p0 or p1 or p2 or p3;
    -- product terms
    p0 <= (not a(1)) and (not a(0)) and (not b(1)) and (not b(0));
    p1 <= (not a(1)) and a(0) and (not b(1)) and b(0);
    p2 <= a(1) and (not a(0)) and b(1) and (not b(0));
    p3 <= a(1) and a(0) and b(1) and b(0);
end sop_arch;


-- Implements eq2 using 1-bit comparators
architecture struc_arch of eq2 is
    signal e0,e1: STD_LOGIC;
begin
    -- instantiate two 1-bit comparitors
    eq_bit0_unit: entity work.eq1(sop_arch) port map(i0 => a(0), i1 => b(0), eq => e0);
    eq_bit1_unit: entity work.eq1(sop_arch) port map(i0 => a(1), i1 => b(1), eq => e1);
    -- a and b are equal if individual bits are equal
    aeqb <= e0 and e1;
end struc_arch ;   
    
    
    