--Author: Clayton Heeren
--Date: 4/1/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Branch_Test_Unit is
    Port ( N: in std_logic;
           Z: in std_logic;
           C: in std_logic;
           V: in std_logic;
           condition: in std_logic_vector(3 downto 0);
           Branch: out std_logic
           );
end Branch_Test_Unit;

architecture Behavioral of Branch_Test_Unit is
begin
    Branch <= (C and condition(0) and condition(2) and condition(3) and (not Z))
               or (C and condition(0) and (not condition(1)) and condition(2) and (not condition(3)))
               or (condition(0) and condition(1) and condition(2) and V)
               or (condition(0) and condition(1) and (not condition(2)) and Z)
               or (condition(0) and (not condition(2)) and condition(3) and N and (not V))
               or (condition(0) and (not condition(2)) and condition(3) and (not N) and V)
               or (condition(1) and condition(2) and condition(3) and (not Z))
               or ((not C) and (not condition(0)) and condition(1) and condition(2))
               or ((not condition(0)) and condition(1) and condition(3) and N and V and (not Z))
               or ((not condition(0)) and condition(3) and (not N) and (not V) and (not Z))
               or ((not condition(0)) and (not condition(1)) and condition(2) and condition(3) and N and V)
               or ((not condition(0)) and (not condition(1)) and condition(3) and (not N) and (not V))
               or ((not condition(0)) and (not condition(1)) and (not condition(3)) and (not Z))
               or ((not condition(0)) and (not condition(2)) and (not condition(3)) and (not N))
               or ((not condition(1)) and (not condition(2)) and N and (not V))
               or ((not condition(1)) and (not condition(2)) and (not condition(3)) and N);
end Behavioral;

architecture Mux of Branch_Test_Unit is
begin
    with condition select
        Branch <= N when "0001",
                  not N when "0010",
                  Z when "0011",
                  not Z when "0100",
                  C when "0101",
                  not C when "0110",
                  V when "0111",
                  not V when "1000",
                  N XOR V when "1001",
                  --((NOT N) AND (NOT Z) AND (NOT V)) OR (N AND (NOT Z) AND V) when "1010",
                  ((not Z) and (N or V)) or ((not N) and V) when "1010", 
                  Z or (N XOR V) when "1011",
                  (N and V) or ((not N) and (not V)) when "1100",
                  C and (not Z) when "1101",
                  (not C) or Z when "1110",
                  '1' when others;
end Mux;