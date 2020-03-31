----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/31/2020
-- Lab 7
-- Design Name: hexTo7Seg
-- Project Name: Lab7
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- this converts a hexadecimal number into a seven-segment display representation
entity hexTo7Seg is
    Port ( hex: in STD_LOGIC_VECTOR (3 downto 0);
           dp: in STD_LOGIC;
           sseg: out STD_LOGIC_VECTOR (6 downto 0);
           dpo: out std_logic;
           sseg_an: out STD_LOGIC_VECTOR (7 downto 0));
end hexTo7Seg;


-- this architecture uses a direct sum-of-products implementation
architecture sop_arch of hexTo7Seg is
begin
    -- only enable the first seven segment display
    sseg_an <= "01111111";
    
    -- invert the decimal-point signal since the 7-seg-display has a common anode
    dpo <= not dp;
    
    -- convert hexadecimal input into 7-seg output
    sseg(6) <= ( (not hex(3)) and (not hex(2)) and (not hex(1)) and hex(0) ) or
                 ( (not hex(3)) and hex(2) and (not hex(1)) and (not hex(0)) ) or
                 ( hex(3) and hex(2) and (not hex(1)) and hex(0) ) or
                 ( hex(3) and (not hex(2)) and hex(1) and hex(0) );
    sseg(5) <= ( (not hex(3)) and hex(2) and (not hex(1)) and hex(0) ) or
                 ( hex(2) and hex(1) and (not hex(0)) ) or
                 ( hex(3) and hex(1) and hex(0) ) or
                 ( hex(3) and hex(2) and (not hex(0)) );
    sseg(4) <= ( (not hex(3)) and (not hex(2)) and hex(1) and (not hex(0)) ) or
                 ( hex(3) and hex(2) and (not hex(0)) ) or
                 ( hex(3) and hex(2) and hex(1) );
    sseg(3) <= ( (not hex(3)) and (not hex(2)) and (not hex(1)) and hex(0) ) or
                 ( (not hex(3)) and hex(2) and (not hex(1)) and (not hex(0)) ) or
                 ( hex(2) and hex(1) and hex(0) ) or
                 ( hex(3) and (not hex(2)) and hex(1) and (not hex(0)) );
    sseg(2) <= ( (not hex(3)) and hex(0) ) or
                 ( (not hex(3)) and hex(2) and (not hex(1)) ) or
                 ( (not hex(2)) and (not hex(1)) and hex(0) );
    sseg(1) <= ( (not hex(3)) and (not hex(2)) and hex(0) ) or
                 ( (not hex(3)) and (not hex(2)) and hex(1) ) or
                 ( (not hex(3)) and hex(1) and hex(0) ) or
                 ( hex(3) and hex(2) and (not hex(1)) and hex(0) );
    sseg(0) <= ( (not hex(3)) and (not hex(2)) and (not hex(1)) ) or
                 ( (not hex(3)) and hex(2) and hex(1) and hex(0) ) or
                 ( hex(3) and hex(2) and (not hex(1)) and (not hex(0)) );

end sop_arch;


-- this architecture uses a conditional signal assignment statement implementation
architecture conditional_arch of hexTo7Seg is
begin
    -- only enable the first seven segment display
    sseg_an <= "01111111";
    
    -- invert the decimal-point signal since the 7-seg-display has a common anode
    dpo <= not dp;
    
    -- convert hexadecimal input into 7-seg output
    sseg <= "0000001" when hex = "0000" else
            "1001111" when hex = "0001" else
            "0010010" when hex = "0010" else
            "0000110" when hex = "0011" else
            "1001100" when hex = "0100" else
            "0100100" when hex = "0101" else
            "0100000" when hex = "0110" else
            "0001111" when hex = "0111" else
            "0000000" when hex = "1000" else
            "0000100" when hex = "1001" else
            "0001000" when hex = "1010" else
            "1100000" when hex = "1011" else
            "0110001" when hex = "1100" else
            "1000010" when hex = "1101" else
            "0110000" when hex = "1110" else
            "0111000";
            
end conditional_arch;


-- this architecture uses a selection signal assignment statement implementation
architecture select_arch of hexTo7Seg is
begin
    -- only enable the first seven segment display
    sseg_an <= "01111111";
    
    -- invert the decimal-point signal since the 7-seg-display has a common anode
    dpo <= not dp;
    
    -- convert hexadecimal input into 7-seg output
    with hex select
        sseg <= "0000001" when "0000",
                "1001111" when "0001",
                "0010010" when "0010",
                "0000110" when "0011",
                "1001100" when "0100",
                "0100100" when "0101",
                "0100000" when "0110",
                "0001111" when "0111",
                "0000000" when "1000",
                "0000100" when "1001",
                "0001000" when "1010",
                "1100000" when "1011",
                "0110001" when "1100",
                "1000010" when "1101",
                "0110000" when "1110",
                "0111000" when others;

end select_arch;