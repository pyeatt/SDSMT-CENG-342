----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/21/2020
-- Lab 4
-- Design Name: full_adder
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a full-adder
entity full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Ci : in STD_LOGIC;
           S : out STD_LOGIC;
           Co : out STD_LOGIC);
end full_adder;


-- this archetecture uses a direct sum-of-products implementation
architecture sop_arch of full_adder is
begin
    -- sum output
    S <= ((NOT A) AND B AND (NOT Ci)) OR 
         (A AND (NOT B) AND (NOT Ci)) OR 
         ((NOT A) AND (NOT B) AND Ci) OR 
         (A AND B AND Ci);
         
   -- carry-out output
   Co <= (A AND B) OR 
          (B AND Ci) OR 
          (A AND Ci);
end sop_arch;
