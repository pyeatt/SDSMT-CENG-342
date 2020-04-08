----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/07/2020
-- Lab 9
-- Design Name: LPU_BTU
-- Project Name: Lab9
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity LPU_BTU is
    port(
        condition: in std_logic_vector(3 downto 0); -- this is the condition code
        N: in std_logic; -- this is the negative flag
        Z: in std_logic; -- this is the zero flag
        Co: in std_logic; -- this is the carry-out flag
        V: in std_logic; -- this is the overflow flag
        branch: out std_logic -- this flag determines if a branch should be taken
        );
end LPU_BTU;

architecture behavioral of LPU_BTU is

    signal branchInternal: std_logic_vector(14 downto 0);
begin
    with condition select
        branch <= 
            '1' when "0000", -- al
            N when "0001", -- mi
            not N when "0010", -- pl
            Z when "0011", -- eq
            not Z when "0100", -- ne
            Co when "0101", -- cs & hs
            not Co when "0110", -- cc & lo
            V when "0111", -- vs
            not V when "1000", -- vc
            N xor V when "1001", -- lt
            ((not Z) and (N or V)) or ((not N) and V) when "1010", -- gt
            Z or (N xor V) when "1011", -- le
            (N and V) or ((not N) and (not V)) when "1100", -- ge
            Co and (not Z) when "1101", -- hi
            (not Co) or Z when "1110", -- ls
            '0' when others; -- no branch by default
end behavioral;
