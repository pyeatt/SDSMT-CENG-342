----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: decoderWithEnable
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity genericDecoderWithEnable is
    generic( bits: integer := 1 ); -- number of selector inputs
    port(
        en: in std_logic;
        sel: in std_logic_vector(bits-1 downto 0); -- selector inputs
        Y: out std_logic_vector(2**bits-1 downto 0)
        );
end genericDecoderWithEnable;


architecture ifelse_arch of genericDecoderWithEnable is
begin
    process(en,sel)
        variable sel_n: natural;
    begin
        if en='1' then -- enable is active low, so when en=1, disable 'Y'
            Y <= (others=>'1');
        else
            Y <= (others=>'1'); -- otherwise disable Y
            sel_n := to_integer(unsigned(sel));
            Y(sel_n) <= '0'; -- enable the pin encoded in 'sel'
        end if;
    end process;
end ifelse_arch;