----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/08/2020
-- Lab 3 
-- Design Name: generic_multiplexor_testbench
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.std_logic_2D_pkg.all;  


entity generic_multiplexor_testbench is
end generic_multiplexor_testbench;

architecture tb_arch of generic_multiplexor_testbench is
    constant TBN : integer := 4;
    constant TBM : integer := 2;
    signal TBi : std_logic_2D(TBM - 1 downto 0, TBN - 1 downto 0);
    signal TBsel : STD_LOGIC_VECTOR (integer(log2(real(TBM))) - 1 downto 0);
    signal TBQ : STD_LOGIC_VECTOR (TBN - 1 downto 0);
begin

    uut : entity work.generic_multiplexor(generic_arch)
    generic map(N => TBN, M => TBM)
    port map(i => TBi, sel => TBsel, Q => TBQ);
    
    process
        variable I : integer := 0;
        variable j : integer := 0;
        variable temp : std_logic_vector(TBN - 1 downto 0);
     begin
        -- initialize the inputs
        for I in 0 to TBM - 1 loop -- iterate through the different input buses
            temp := std_logic_vector((to_unsigned(I + 1, TBN)));
            for j in 0 to TBN - 1 loop -- iterate through the different bit in each bus
                TBi(I,j) <= temp(j);
            end loop;
        end loop;
        
        -- check that all of the input buses can be acessed
        for I in 0 to TBM loop
            TBsel <= std_logic_vector(to_unsigned(I,integer(log2(real(TBM)))));
            wait for 200ns;
        end loop;
    end process;
end tb_arch;
