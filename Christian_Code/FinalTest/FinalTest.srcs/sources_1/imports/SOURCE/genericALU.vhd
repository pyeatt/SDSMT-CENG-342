----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/18/2020
-- Lab 6
-- Design Name: genericALU
-- Project Name: Lab6
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


-- This defines a generic arithmetic logic unit
entity genericALU is
    generic (userWidth : integer := 4);
    Port ( A : in std_logic_vector(integer(2**(ceil(log2(real(userWidth))))) - 1 downto 0); -- first operand
           B : in std_logic_vector(integer(2**(ceil(log2(real(userWidth))))) - 1 downto 0); -- second operand
           Ci : in std_logic; -- carry in
           Func : in std_logic_vector(3 downto 0); -- function to select mode
           R : out std_logic_vector(integer(2**(ceil(log2(real(userWidth))))) - 1 downto 0); -- Result
           N : out std_logic; -- Negative result flag
           Z : out std_logic; -- Zero result flag
           Co : out std_logic; -- Carry out flag
           V : out std_logic); -- oVerflow flag (1->true; 0->false)
end genericALU;


-- this archetecture implements a generic logic unit
architecture struct_arch of genericALU is
    constant width : integer := integer(2**(ceil(log2(real(userWidth))))); -- this guarantees that the data width will be a power of 2
    type array2DLogic is array(3 downto 0) of std_logic_vector(width - 1 downto 0);
    signal RTemp : array2DLogic;
    signal CoTemp : std_logic_vector(2 downto 0);
    signal VTemp : std_logic_vector(2 downto 0);
    signal zeros : std_logic_vector(width - 1 downto 0) := (others => '0');
begin

    adderSubtractor:
        entity work.generic_full_adder_subtractor_lookahead(gen_arch)
        generic map(userWidth => width)
        port map(A => A,
                 B => B,
                 Ci => Ci,
                 Func => Func(2 downto 1),
                 S => RTemp(0),
                 Co => CoTemp(0),
                 V => VTemp(0));
              
    logicUnit:
        entity work.genericLogicUnit(select_arch)
        generic map(width => width)
        port map(A => A,
                 B => B,
                 Func => Func(2 downto 1),
                 R => RTemp(1));

    shifter:
        entity work.genericShifter(gen_arch)
        generic map(numShiftBits => integer(ceil(log2(real(width)))))
        port map(din => A,
                 shamt => B(integer(ceil(log2(real(width)))) - 1 downto 0),
                 func => Func(2 downto 1),
                 dout => RTemp(2),
                 co => CoTemp(2));  
                 
    RTemp(3) <= RTemp(0) when Func(3) = '0' and Func(0) = '0' else -- Func = "0xx0" (add/subract)
         RTemp(1) when Func(3) = '1' and Func(0) = '1' else -- Func = "1xx1" (logic)
         RTemp(2) when Func(3) = '1' and Func(2 downto 1) /= "00" and Func(0) = '0' else -- Func = "1xx0" (shift)
         B when Func = "1000" else -- Func = "1000" (Pass B)
         (others => '0'); -- default value is all zeros
         
    R <= RTemp(3);
         
    N <= '1' when RTemp(3)(width - 1) = '1' else
         '0';
              
    Z <= '1' when RTemp(3) = zeros else
         '0';
    
    Co <= CoTemp(0) when Func(3) = '0' and Func(0) = '0' else -- Func = "0xx0" (add/subtract)
          '0' when Func(3) = '1' and Func(0) = '1' else -- Func = "1xx1" (logic)
          CoTemp(2) when Func(3) = '1' and Func(2 downto 1) /= "00" and Func(0) = '0' else -- Func = "1xx0" (shift)
          '0';
    
    V <= VTemp(0) when Func(3) = '0' and Func(0) = '0' else -- Func = "0xx0" (add/subtract)
         A(width - 1) xor RTemp(3)(width - 1) when Func = "1010" else
         '0';
        
end struct_arch;
