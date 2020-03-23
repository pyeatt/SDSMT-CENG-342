----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/09/2020
-- Lab 3 
-- Design Name: 4bit_2bus_mux_testbench
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.std_logic_2D_pkg.all;  


entity mux_4bit_2bus_testbench is
end mux_4bit_2bus_testbench;

architecture tb_arch of mux_4bit_2bus_testbench is
    constant bus_width : integer := 4;
    constant num_buses : integer := 2;
    signal TBinputs : std_logic_2D(num_buses - 1 downto 0, bus_width - 1 downto 0);
    signal TBinSelect : STD_LOGIC_VECTOR (integer(log2(real(num_buses))) - 1 downto 0);
    signal TBoutput : STD_LOGIC_VECTOR (bus_width - 1 downto 0);
begin

    uut : entity work.mux_4bit_2bus(mux_arch)
    port map(inputs => TBinputs, inSelect => TBinSelect, output => TBoutput);
    
    process
        variable I : integer := 0;
        variable j : integer := 0;
        variable temp : std_logic_vector(bus_width - 1 downto 0);
     begin
        -- initialize the inputs
        for I in 0 to num_buses - 1 loop -- iterate through the different input buses
            -- assign the address of each input as the value of that bus
            temp := std_logic_vector((to_unsigned(I, bus_width)));
            for j in 0 to bus_width - 1 loop -- iterate through the different bit in each bus
                TBinputs(I,j) <= temp(j);
            end loop;
        end loop;
        
        -- check that all of the input buses can be acessed
        for I in 0 to num_buses - 1 loop
            TBinSelect <= std_logic_vector(to_unsigned(I,integer(log2(real(num_buses)))));
            wait for 200ns;
        end loop;
    end process;
end tb_arch;
