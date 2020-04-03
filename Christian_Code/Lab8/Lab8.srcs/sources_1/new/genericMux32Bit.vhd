----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: genericMux32Bit
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package my_package is
    type slv_array_5 is array(natural range <>) of std_logic_vector(4 downto 0);
    type slv_array_8 is array(natural range <>) of std_logic_vector(7 downto 0);
    type slv_array_16 is array(natural range <>) of std_logic_vector(15 downto 0);
    type slv_array_32 is array(natural range <>) of std_logic_vector(31 downto 0);
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;


-- entity declaration for a generic 5-bit mux
entity genericMux32Bit is
    generic(sel_bits: integer := 1); -- number of selector bits
    port(
        sel: in std_logic_vector(sel_bits-1 downto 0); -- selector inputs
        d_in: in slv_array_32(2**sel_bits-1 downto 0);
        Y: out std_logic_vector(31 downto 0)
        );
end genericMux32Bit;


-- implementation for a generic 5-bit mux using a process
architecture proc_arch of genericMux32Bit is
begin
    process(sel,d_in)
        variable sel_n: natural;
    begin
        sel_n := to_integer(unsigned(sel));
        Y <= d_in(sel_n); -- select the input selected by 'sel_n'
    end process;
end proc_arch;
