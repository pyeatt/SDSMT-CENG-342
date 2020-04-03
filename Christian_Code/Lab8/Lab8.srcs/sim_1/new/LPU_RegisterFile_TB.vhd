----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_RegisterFile_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a testbench for a generic 5-bit register file
entity LPU_RegisterFile_TB is
end LPU_RegisterFile_TB;


-- implementation for a testbench for a generic 5-bit register file
architecture tb_arch of LPU_RegisterFile_TB is
    constant DataWidth: integer := 5;
    constant numSelBits: integer := 2;
    signal Asel: std_logic_vector(numSelBits-1 downto 0); -- Selects the register to output to A output
    signal Bsel: std_logic_vector(numSelBits-1 downto 0); -- Selects the register to output to B output
    signal Dsel: std_logic_vector(numSelBits-1 downto 0); -- Selects the register to store D input
    signal WriteEn: std_logic := '1'; -- Active low write enable
    signal Din: std_logic_vector(dataWidth-1 downto 0); -- Input data
    signal Aout: std_logic_vector(dataWidth-1 downto 0); -- A output
    signal Bout: std_logic_vector(dataWidth-1 downto 0); -- B output
    signal Clock: std_logic := '1'; -- Clock (triggered on rising edge)
    signal Reset: std_logic := '1'; -- Active low synchronous reset
begin

    uut: entity work.LPU_RegisterFile(arch)
        generic map(
            DataWidth => DataWidth,
            NumSelBits => NumSelBits
            )
        port map(
            Asel => Asel,
            Bsel => Bsel,
            Dsel => Dsel,
            WriteEn => WriteEn,
            Din => Din,
            Aout => Aout,
            Bout => Bout,
            Clock => Clock,
            Reset => Reset
            );
    
    -- clear the register file
    process
    begin
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait;
    end process;
    
    -- run the clock
    process
    begin
        wait for 5 ns;
        Clock <= not Clock;
        loop
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process;
    
    
    process
        variable dat,i: natural := 0;
    begin
        loop
            -- write data to the register file
            for i in 0 to 3 loop
                Dsel <= std_logic_vector(to_unsigned(i,2));
                Din <= std_logic_vector(to_unsigned(dat,5));
                dat := dat + 1;
                WriteEn <= '0';
                wait for 10 ns;
                WriteEn <= '1';
                wait for 10 ns;
            end loop;
            
            -- read data from the register file
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i,2));
                Bsel <= std_logic_vector(to_unsigned(i+1,2));
                wait for 10 ns;
            end loop;
        end loop;
    end process;
end tb_arch;