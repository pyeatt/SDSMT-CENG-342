----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_MCR
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the Memory Control Register for the LPU
entity LPU_MCR is
    port(
        MCRin: in std_logic_vector(4 downto 0); -- Data bus to load in a new value to the MCR
        MCRout: out std_logic_vector(4 downto 0); -- Data bus to output the current value of the MCR
        LoadEn: in std_logic; -- Active low enable for loading in a new value to the MCR
        Clock: in std_logic; -- Clock (triggered on rising edge)
        Reset: in std_logic -- Active low syncronous reset
        );
end LPU_MCR;


architecture arch of LPU_MCR is
begin

    MCRegister:
        entity work.genericRegister(ifelse_arch)
        generic map(
            bits => 5
            )
        port map(
            en => LoadEn,
            clk => Clock,
            reset => Reset,
            d => MCRin,
            q => MCRout
            );

end arch;








