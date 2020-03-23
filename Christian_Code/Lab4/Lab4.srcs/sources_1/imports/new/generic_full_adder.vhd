----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/21/2020
-- Lab 4
-- Design Name: generic_full_adder
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a generic n-input full-adder with overflow detection
entity generic_full_adder is
    generic (width : integer := 4);
    Port ( A : in STD_LOGIC_VECTOR(width - 1 downto 0); -- first operand
           B : in STD_LOGIC_VECTOR(width - 1 downto 0); -- second operand
           Ci : in STD_LOGIC; -- Carry in
           S : out STD_LOGIC_VECTOR(width - 1 downto 0); -- Sum
           Co : out STD_LOGIC; -- Carry out
           V : out STD_LOGIC); -- oVerflow detection (1->true; 0->false)
end generic_full_adder;


-- this archetecture uses a generate statement and the full-adder entity to implement
-- the generic n-bit adder
architecture gen_arch of generic_full_adder is
    signal C_internal : STD_LOGIC_VECTOR(width downto 0);
begin
    C_internal(0) <= Ci;
    
    -- generate 'width' instances of the one-bit full_adder
    gen_adder: for I in width - 1 downto 0 generate
    begin
        AaI : entity work.full_adder(sop_arch) 
              port map(A => A(I), 
                       B => B(I), 
                       Ci => C_internal(I), 
                       S => S(I), 
                       Co => C_internal(I + 1));        
    end generate gen_adder;
    
    -- set carry-out flag
    Co <= C_internal(width);
    
    -- set overflow flag
    V <= C_internal(width) XOR C_internal(width - 1);-- oVerflow is true whenever Carry(n) != Carry(n - 1)

end gen_arch;
