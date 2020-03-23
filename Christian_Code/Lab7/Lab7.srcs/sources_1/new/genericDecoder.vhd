----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/14/2020
-- Lab 7
-- Design Name: genericDecoder
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity genericDecoder is
    generic(
        bits:integer:=1 -- number of selector inputs
        );
    port(
        sel: in std_logic_vector(bits-1 downto 0); -- selector inputs
        Y: out std_logic_vector(2**bits-1 downto 0)
        );
end genericDecoder;

architecture proc_arch of genericDecoder is
begin
    process(sel)
        variable sel_n:natural;
    begin
        Y <= (others=>'1');
        sel_n := to_integer(unsigned(sel));
        Y(sel_n) <= '0';
    end process;
end proc_arch;