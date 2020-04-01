--Author: Clayton Heeren
--Date: FEB. 3, 2020

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seven_Segment_Display is
    Port ( i_in: in std_logic_vector(3 downto 0);
           DP_in: in std_logic;
           O_out: out std_logic_vector(6 downto 0);
           DP_out: out std_logic
           );
end Seven_Segment_Display;

architecture Clayton_Gate_Arch of Seven_Segment_Display is
begin
    DP_out <= not DP_in;
    O_out(6) <= ((not i_in(3)) and (not i_in(2)) and (not i_in(1)) and i_in(0)) or ((not i_in(3)) and 
                 i_in(2) and (not i_in(1)) and (not i_in(0))) or (i_in(3) and i_in(2) and (not i_in(1)) 
                 and i_in(0)) or (i_in(3) and (not i_in(2)) and i_in(1) and i_in(0));
    O_out(5) <= ((not i_in(3)) and i_in(2) and (not i_in(1)) and i_in(0)) or (i_in(3) and i_in(2) and 
                  (not i_in(0))) or (i_in(3) and i_in(1) and i_in(0)) or (i_in(2) and i_in(1) and (not i_in(0)));
    O_out(4) <= ((not i_in(3)) and (not i_in(2)) and i_in(1) and (not i_in(0))) or (i_in(3) and i_in(2) and 
                 (not i_in(0))) or (i_in(3) and i_in(2) and i_in(1));
    O_out(3) <= ((not i_in(3)) and (not i_in(2)) and (not i_in(1)) and (i_in(0))) or ((not i_in(3)) and (i_in(2)) 
                 and (not i_in(1)) and (not i_in(0))) or ((i_in(3)) and (not i_in(2)) and (i_in(1)) and (not i_in(0)))
                 or ((i_in(2)) and (i_in(1)) and (i_in(0)));
    O_out(2) <= ((not i_in(3)) and (i_in(0))) or ((not i_in(3)) and (i_in(2)) and (not i_in(1))) or ((not i_in(2))
                 and (not i_in(1)) and (i_in(0)));
    O_out(1) <= ((i_in(3)) and (i_in(2)) and (not i_in(1)) and (i_in(0))) or ((not i_in(3)) and (not i_in(2)) and (i_in(0)))
                 or ((not i_in(3)) and (i_in(1)) and (i_in(0))) or ((not i_in(3)) and (not i_in(2)) and (i_in(1)));
    O_out(0) <= ((i_in(3)) and (i_in(2)) and (not i_in(1)) and (not i_in(0))) or ((not i_in(3)) and (i_in(2)) and (i_in(1)) 
                 and (i_in(0))) or ((not i_in(3)) and (not i_in(2)) and (not i_in(1)));
end Clayton_Gate_Arch;

architecture Clayton_Mux_Arch of Seven_Segment_Display is
begin
    DP_out <= not DP_in;
    O_out <= "0000001" when i_in = "0000" else
             "1001111" when i_in = "0001" else
             "0010010" when i_in = "0010" else
             "0000110" when i_in = "0011" else
             "1001100" when i_in = "0100" else
             "0100100" when i_in = "0101" else
             "0100000" when i_in = "0110" else
             "0001111" when i_in = "0111" else
             "0000000" when i_in = "1000" else
             "0000100" when i_in = "1001" else
             "0001000" when i_in = "1010" else 
             "1100000" when i_in = "1011" else
             "0110001" when i_in = "1100" else
             "1000010" when i_in = "1101" else
             "0110000" when i_in = "1110" else
             "0111000";
end Clayton_Mux_Arch;