----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_CCR
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the Condition Control Register for the LPU
entity LPU_CCR is
    port(
        CCRin: in std_logic_vector(3 downto 0); -- Data bus to load in a new value to the CCR
        CCRout: out std_logic_vector(3 downto 0); -- Data bus to output the current value of the CCR
        LoadEn: in std_logic; -- Active low enable for loading in a new value to the CCR
        Clock: in std_logic; -- Clock (triggered on rising edge)
        Reset: in std_logic -- Active low syncronous reset
        );
end LPU_CCR;


architecture arch of LPU_CCR is
begin

    CCRegister:
        entity work.genericRegister(ifelse_arch)
        generic map(
            bits => 4
            )
        port map(
            en => LoadEn,
            clk => Clock,
            reset => Reset,
            d => CCRin,
            q => CCRout
            );

end arch;








