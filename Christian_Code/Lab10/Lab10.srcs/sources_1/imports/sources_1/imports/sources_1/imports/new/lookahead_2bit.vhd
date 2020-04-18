----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/22/2020
-- Lab 4
-- Design Name: lookahead_2bit
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a 2-bit lookahead circuit
entity lookahead_2bit is
    Port ( A,B : in STD_LOGIC_VECTOR(1 downto 0);
           Ci : in STD_LOGIC;
           Co : out STD_LOGIC);
end lookahead_2bit;


-- this archetecture uses a direct sum-of-products implementation
architecture sop_arch of lookahead_2bit is
begin      
   -- carry-out output
   Co <= (A(1) and B(1)) or (A(1) and B(0) and Ci) or
         (A(1) and A(0) and Ci) or (A(1) and A(0) and B(0)) or
         ((not A(1)) and A(0) and B(1) and Ci) or
         ((not A(1)) and A(0) and B(1) and B(0)) or
         ((not A(1)) and B(1) and B(0) and Ci);
end sop_arch;
