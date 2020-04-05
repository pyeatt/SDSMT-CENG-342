----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
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


-- implementation for a testbench for a generic 5-bit register file:
-- Test period: 2*40*(2**numSelBits) ns
-- Setup time: 25 ns
-- Setup description: run clock and enable reset for 10 ns to reset register file
-- Test description:
--      1st 1/4 period: write is enabled; try fill registers with ascending data
--      2nd 1/4 period: write is disabled; read registers
--      3rd 1/4 period: write is disabled; try fill registers with ascending data
--      4th 1/4 period: write is disabled; read registers
-- Test expected:
--      1st 1/4 period: write is successful
--      2nd 1/4 period: read successfully reads last write
--      3rd 1/4 period: write is unsuccessful
--      4th 1/4 period: read reads original write

architecture tb_arch of LPU_RegisterFile_TB is
    constant dataWidth: integer := 4;
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
    
    type TEST_STATE is (
        SETUP,
        SUCC_WRITE,
        FAIL_WRITE,
        READ
        );
    signal state: TEST_STATE := SETUP; -- This marks each quarter test period
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
        wait for 25 ns; -- wait until register setup complete
        loop
               
            -- write data to the register file (fill every register)
            state <= SUCC_WRITE; -- mark reading state
            WriteEn <= '0'; -- enable write
            for i in 0 to 2**numSelBits-1 loop
                Dsel <= std_logic_vector(to_unsigned(i,numSelBits));
                Din <= std_logic_vector(to_unsigned(dat,dataWidth));
                dat := dat + 1;
                wait for 20 ns;
            end loop;
            
            -- read data from the register file
            state <= READ; -- mark writing state
            WriteEn <= '1'; -- disable write
            WriteEn <= '1'; -- disable write
            for i in 0 to 2**numSelBits-1 loop
                Asel <= std_logic_vector(to_unsigned(i,2));
                Bsel <= std_logic_vector(to_unsigned(i+1,2));
                wait for 20 ns;
            end loop;
            
            -- try write data to the register file (fill every register)
            state <= FAIL_WRITE; -- mark reading state
            WriteEn <= '1'; -- disable write
            for i in 0 to 2**numSelBits-1 loop
                Dsel <= std_logic_vector(to_unsigned(i,numSelBits));
                Din <= std_logic_vector(to_unsigned(dat,dataWidth));
                dat := dat + 1;
                wait for 20 ns;
            end loop;
            
            -- read data from the register file
            state <= READ; -- mark writing state
            WriteEn <= '1'; -- disable write
            for i in 0 to 2**numSelBits-1 loop
                Asel <= std_logic_vector(to_unsigned(i,2));
                Bsel <= std_logic_vector(to_unsigned(i+1,2));
                wait for 20 ns;
            end loop;            
        end loop;
    end process;
end tb_arch;