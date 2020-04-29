----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_MDR
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the Memory Data Register for the LPU
entity LPU_MDR is
    generic(
        NumBits: integer := 32
        );
    port(
        MDRin: in std_logic_vector(NumBits-1 downto 0); -- Data bus to load in a new value to the MDR
        MDRout: out std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the MDR
        LoadEn: in std_logic; -- Active low enable for loading in a new value to the MDR
        Clock: in std_logic; -- Clock (triggered on rising edge)
        Reset: in std_logic -- Active low syncronous reset
        );
end LPU_MDR;


architecture arch of LPU_MDR is
begin

    MDRegister:
        entity work.genericRegister(ifelse_arch)
        generic map(
            bits => NumBits
            )
        port map(
            en => LoadEn,
            clk => Clock,
            reset => Reset,
            d => MDRin,
            q => MDRout
            );

end arch;








