----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_MAR
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the Memory Address Register for the LPU
entity LPU_MAR is
    generic(
        NumBits: integer := 32
        );
    port(
        MARin: in std_logic_vector(NumBits-1 downto 0); -- Data bus to load in a new value to the MAR
        MARout: out std_logic_vector(NumBits-1 downto 0); -- Data bus to output the current value of the MAR
        LoadEn: in std_logic; -- Active low enable for loading in a new value to the MAR
        Clock: in std_logic; -- Clock (triggered on rising edge)
        Reset: in std_logic -- Active low syncronous reset
        );
end LPU_MAR;


architecture arch of LPU_MAR is
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
            d => MARin,
            q => MARout
            );

end arch;








