library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Full_Adder is
    --generic(n: integer:= 1);
    Port ( a, b, Cin: in std_logic;--in std_logic_vector(n downto 0);
            s, Cout: out std_logic--std_logic_vector(n downto 0)
            );
end Full_Adder;

architecture Standard of Full_Adder is   
begin
    Cout <= (b and Cin) or (A and Cin) or (A and B);
    s <= ((a) and (not b) and (not Cin)) or ((not a) and (not b) and (Cin)) or
         ((a) and (b) and (Cin)) or ((not a) and (b) and (not Cin));  
end Standard;
