----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/04/2020
-- Lab 4
-- Design Name: generic_full_adder_subtractor_lookahead
-- Project Name: Lab4
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines a generic n-input full-adder with overflow detection
entity generic_full_adder_subtractor_lookahead is
    generic (width : integer := 2);
    Port ( A : in STD_LOGIC_VECTOR(width - 1 downto 0); -- first operand
           B : in STD_LOGIC_VECTOR(width - 1 downto 0); -- second operand
           Ci : in STD_LOGIC; -- Carry in
           Func : in STD_LOGIC_VECTOR(1 downto 0); -- function to select mode: 00: add
                                                                            -- 01: add with carry
                                                                            -- 10: subtract
                                                                            -- 11: subtract with carry
           S : out STD_LOGIC_VECTOR(width - 1 downto 0); -- Sum
           Co : out STD_LOGIC; -- Carry out
           V : out STD_LOGIC); -- oVerflow detection (1->true; 0->false)
end generic_full_adder_subtractor_lookahead;


-- this archetecture uses a generate statement and the full-adder entity to implement
-- the generic n-bit adder
architecture gen_arch of generic_full_adder_subtractor_lookahead is
    constant lookahead_width: integer := 2;
    signal C_internal : STD_LOGIC_VECTOR(width downto 0);
    signal C_null: STD_LOGIC_VECTOR(width/lookahead_width - 1 downto 0);
begin

    -- multiplex the input for the carry in
    C_internal(0) <= '0' when Func = "00" else
                     Ci when Func = "01" else
                     '1' when Func = "10" else
                     Ci;
        
    -- generate ('width' - 2)/2 instances of the one-bit full_adder
    gen_adder: for I in 0 to width/lookahead_width - 1 generate
    begin
                          
        adderI : entity work.full_adder(sop_arch) 
                 port map(A => A(lookahead_width * I), 
                          B => B(lookahead_width * I) XOR Func(1), 
                          Ci => C_internal(lookahead_width * I), 
                          S => S(lookahead_width * I), 
                          Co => C_internal(lookahead_width * I + 1)); 
                           
        adder2I : entity work.full_adder(sop_arch) 
                 port map(A => A(lookahead_width * I + 1), 
                          B => B(lookahead_width * I + 1) XOR Func(1), 
                          Ci => C_internal(lookahead_width * I + 1), 
                          S => S(lookahead_width * I + 1), 
                          Co => C_null(I));    
                          
        lookaheadI : entity work.lookahead_2bit(sop_arch) 
             port map(A => A(lookahead_width * I + 1 downto lookahead_width * I),
                      B => B(lookahead_width * I + 1 downto lookahead_width * I) XOR (Func(1) & Func(1)), 
                      Ci => C_internal(lookahead_width * I), 
                      Co => C_internal(lookahead_width * (I + 1)));     
                             
    end generate gen_adder;
    
    -- set carry-out flag
    Co <= C_internal(width);
    
    -- set overflow flag
    V <= C_internal(width) XOR C_internal(width - 1);-- oVerflow is true whenever Carry(n) != Carry(n - 1)

end gen_arch;
