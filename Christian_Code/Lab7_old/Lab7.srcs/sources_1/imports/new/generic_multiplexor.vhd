----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/10/2020
-- Lab 3
-- Design Name: generic_multiplexor
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


-- this package allows a variable number of std_logic input buses of 
-- variable width to be declared
package std_logic_2D_pkg is    
    type std_logic_2D is array(integer range <>, integer range <>) of std_logic;
end package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.std_logic_2D_pkg.all;


-- this implements a generic multiplexor whose number 
-- of buses and bus width can be specified
entity generic_multiplexor is
    generic (N : integer := 1; -- bus width
             M : integer := 2);-- number of buses
    Port ( i : in std_logic_2D(M - 1 downto 0, N - 1 downto 0);
           sel : in STD_LOGIC_VECTOR (integer(log2(real(M))) - 1 downto 0);
           Q : out STD_LOGIC_VECTOR (N - 1 downto 0));
end generic_multiplexor;


-- this implements the generic mux by assigning 
-- the input of index 'sel' to 'Q' (the output)
architecture generic_arch of generic_multiplexor is
begin
    process (sel)
        variable j : integer := 0;
    begin
        -- assign each element of the correct input to Q
        for j in 0 to N - 1 loop
            Q(j) <= i(to_integer(unsigned(sel)),j);
        end loop;
    end process;
end generic_arch;
