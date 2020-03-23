----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/09/2020
-- Lab 3
-- Design Name: 2bit_2bus_mux
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.std_logic_2D_pkg.all;


-- this defines a multiplexor with 2 input buses and a bus width of 2
entity mux_2bit_2bus is
    port( inputs : in std_logic_2D (1 downto 0, 1 downto 0);
          inSelect : in std_logic_vector (0 downto 0);
          output : out std_logic_vector (1 downto 0));
end mux_2bit_2bus;


-- this implements the multiplexor using the generic multiplexor 
-- entity
architecture mux_arch of mux_2bit_2bus is
    constant bus_width : integer := 2;
    constant num_buses : integer := 2;
begin
    uut : entity work.generic_multiplexor(generic_arch)
          generic map(N => bus_width, M => num_buses)
          port map(i => inputs, sel => inSelect, Q => output);
end mux_arch;


