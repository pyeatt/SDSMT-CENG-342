----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/10/2020
-- Lab 3
-- Design Name: 1bit_8bus_mux
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.std_logic_2D_pkg.all;


-- this defines a multiplexor with 8 input buses and a bus width of 1
entity mux_1bit_8bus is
    port( inputs : in std_logic_2D (7 downto 0, 7 downto 0);
          inSelect : in std_logic_vector (2 downto 0);
          output : out std_logic_vector (7 downto 0));
end mux_1bit_8bus;


-- this implements the multiplexor using the generic multiplexor 
-- entity
architecture mux_arch of mux_1bit_8bus is
    constant bus_width : integer := 8;
    constant num_buses : integer := 8;
begin
    uut : entity work.generic_multiplexor(generic_arch)
          generic map(N => bus_width, M => num_buses)
          port map(i => inputs, sel => inSelect, Q => output);
end mux_arch;


