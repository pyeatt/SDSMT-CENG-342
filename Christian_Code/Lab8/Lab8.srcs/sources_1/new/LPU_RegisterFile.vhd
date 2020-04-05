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
        DataWidth: integer := 32; -- Width of the data
        NumSelBits: integer := 3 -- log2(number of words)
        );
        port(
            Asel: in std_logic_vector(NumSelBits-1 downto 0); -- Selects the register to output to A output
            Bsel: in std_logic_vector(NumSelBits-1 downto 0); -- Selects the register to output to B output
            Dsel: in std_logic_vector(NumSelBits-1 downto 0); -- Selects the register to store D input
            WriteEn: in std_logic; -- Active low write enable
            --ChipEn: in std_logic; -- Active low chip enable
            Din: in std_logic_vector(DataWidth-1 downto 0); -- Input data
            Aout: out std_logic_vector(DataWidth-1 downto 0); -- A output
            Bout: out std_logic_vector(DataWidth-1 downto 0); -- B output
            Clock: in std_logic; -- Clock (triggered on rising edge)
            Reset: in std_logic -- Active low synchronous reset
            );
end LPU_RegisterFile;


architecture arch of LPU_RegisterFile is
    type slv_array is array(2**NumSelBits-1 downto 0) of std_logic_vector(dataWidth-1 downto 0);
    signal Dout: slv_array; -- output of registers
    signal internalEnable: std_logic_vector(2**NumSelBits-1 downto 0) := (others=>'0'); -- internal enable for each register
    signal masterWriteEnable: std_logic;
    signal ChipEn: std_logic; -- Active low chip enable
begin
    -- only enable write when both chip enable and writeEn are enabled (active low)
    masterWriteEnable <= ChipEn or WriteEn; -- only low when both enables are low
    ChipEn <= '0'; -- always enable the LPU datapath

    Registers: for i in 0 to 2**NumSelBits-1 generate
        Registeri:
            entity work.genericRegister(ifelse_arch)
            generic map(
                bits => DataWidth
                )
            port map(
                en => internalEnable(i),
                clk => Clock,
                reset => Reset,
                d => Din,
                q => Dout(i)
                );
    end generate Registers;
    
    -- Select which register to write to
    WriteSelect:
        entity work.genericDecoderWithEnable(ifelse_arch)
        generic map(
            bits => NumSelBits
            )
        port map(
            en => masterWriteEnable,
            sel => Dsel,
            Y => internalEnable
            );
    
    -- Select A output
    Aout <= Dout(to_integer(unsigned(Asel)));
    
    -- Select B output
    Bout <= Dout(to_integer(unsigned(Bsel)));

end arch;


