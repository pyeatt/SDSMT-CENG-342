----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 01/25/2020
-- Lab 1, Part 2
-- Design Name: BinaryDecoder
-- Project Name: 2to4BinaryDecoder
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- BinaryDecoder is a 2-to-4 Binary Decoder
-- if a=="00" then Q(0)=1, elseif a=="01" then Q(1)=1,
-- elseif a=="10" then Q(2)=1, elseif a=="11" then Q(3)=1
entity BinaryDecoder is
    Port ( a : in STD_LOGIC_VECTOR (1 downto 0);
           Q : out STD_LOGIC_VECTOR (3 downto 0));
end BinaryDecoder;


-- implements BinaryDecoder using sum of products
architecture decoder_arch of BinaryDecoder is
begin
    Q(0) <= (not a(1)) and (not a(0));
    Q(1) <= (not a(1)) and a(0);
    Q(2) <= a(1) and (not a(0));
    Q(3) <= a(1) and a(0);
end decoder_arch;
