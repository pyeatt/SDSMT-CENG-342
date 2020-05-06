library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--stealing Pyeatt's package for specific sized Muxes 
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

entity Mux is
    generic(Nsel : integer := 2);
    Port (
             sel: in std_logic_vector(Nsel-1 downto 0);
             input: in slv_array_32(2**Nsel-1 downto 0);
             output: out std_logic_vector(31 downto 0)
          );
end Mux;

architecture arch of Mux is

begin
    process(sel, input)
        variable sel_out: integer;
        begin 
            sel_out := to_integer(unsigned(sel));
            output <= input(sel_out);
     end process;

end arch;
