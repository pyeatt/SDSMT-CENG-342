----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_RegisterFile
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is the register file for the LPU datapath
entity LPU_RegisterFile is
    generic(
        dataWidth: integer := 32; -- Width of the data
        numSelBits: integer := 3 -- log2(number of words)
        );
        port(
            Asel: in std_logic_vector(numSelBits-1 downto 0); -- Selects the register to output to A output
            Bsel: in std_logic_vector(numSelBits-1 downto 0); -- Selects the register to output to B output
            Dsel: in std_logic_vector(numSelBits-1 downto 0); -- Selects the register to store D input
            WriteEn: in std_logic; -- Active low write enable
            Din: in std_logic_vector(dataWidth-1 downto 0); -- Input data
            Aout: out std_logic_vector(dataWidth-1 downto 0); -- A output
            Bout: out std_logic_vector(dataWidth-1 downto 0); -- B output
            Clock: in std_logic; -- clock (triggered on rising edge)
            Reset: in std_logic -- Active low reset
            );
end LPU_RegisterFile;


architecture arch of LPU_RegisterFile is
    type slv_array is array(2**numSelBits-1 downto 0) of std_logic_vector(dataWidth-1 downto 0);
    signal Dout: slv_array; -- output of registers
    signal Enable: std_logic_vector(2**numSelBits-1 downto 0) := (others=>'0'); -- internal enable for each register
begin

    Registers: for i in 0 to 2**numSelBits generate
        Registeri:
            entity work.genericRegister(ifelse_arch)
            generic map(
                bits => dataWidth
                )
            port map(
                en => Enable(i),
                clk => clock,
                reset => reset,
                d => Din,
                q => Dout(i)
                );
    end generate Registers;
    
    -- Select which register to write to
    WriteSelect:
        entity work.genericDecoderWithEnable(ifelse_arch)
        generic map(
            bit => numSelBits
            )
        port map(
            en => WriteEn,
            sel => Dsel,
            Y => Enable
            );
    
    -- Select A output
    Aout <= Dout(to_integer(unsigned(Asel)));
    
    -- Select B output
    Bout <= Dout(to_integer(unsigned(Bsel)));

end arch;


