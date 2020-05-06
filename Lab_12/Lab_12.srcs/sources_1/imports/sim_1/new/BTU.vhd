library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BTU is
    port(
            N, Z, C, V: IN STD_LOGIC;
            Encoding: IN STD_LOGIC_VECTOR (3 downto 0);
            brout: OUT STD_LOGIC
        );
end BTU;

architecture sanity_check of BTU is

begin
-- Thank you slide set 6 as the when else was not able to handle others part
    with Encoding select
    brout <= '1' when "0000", 
    N when "0001",       
    NOT(N) when "0010",
    Z when "0011",
    NOT(Z) when "0100", 
    C when "0101",
    NOT(C) when "0110",
    V when "0111", 
    NOT(V) when "1000",
    (N XOR V) when "1001", 
    NOT(Z) AND ((N AND V) OR (NOT(N) AND NOT(V))) when "1010",  
    Z OR (N XOR V) when "1011",  
    (N AND V) OR (NOT(N) AND NOT(V)) when  "1100",
    C AND NOT(Z) when "1101",       
    NOT(C) OR Z when "1110",      
    '0' when others;
            
end sanity_check;