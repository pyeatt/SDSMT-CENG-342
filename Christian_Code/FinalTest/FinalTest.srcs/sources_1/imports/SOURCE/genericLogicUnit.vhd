----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/06/2020
-- Lab 6
-- Design Name: genericLogicUnit
-- Project Name: Lab6
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a generic logic unit
entity genericLogicUnit is
    generic (width : integer := 4);
    Port ( A : in STD_LOGIC_VECTOR(width - 1 downto 0); -- first operand
           B : in STD_LOGIC_VECTOR(width - 1 downto 0); -- second operand
           Func : in STD_LOGIC_VECTOR(1 downto 0); -- function to select mode: 00: not B
                                                                            -- 01: A and B
                                                                            -- 10: A or B
                                                                            -- 11: A xor B
           R : out STD_LOGIC_VECTOR(width - 1 downto 0)); -- Result
end genericLogicUnit;


-- this archetecture implements a generic logic unit
architecture select_arch of genericLogicUnit is
begin

R <= not B when Func = "00" else
     A and B when Func = "01" else
     A or B when Func = "10" else
     A xor B;

end select_arch;
