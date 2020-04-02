----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericRegisterFile
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;


-- entity declaration for a generic 5-bit register file
entity genericRegisterFile is
generic(n_sel: integer := 1); -- number of bits for selecting a register
    port(
        en: in std_logic; -- active low enable
        clk: in std_logic; -- rising edge-triggered
        rst: in std_logic; -- active low asynchronous reset
        dsel: in std_logic_vector(n_sel-1 downto 0); -- input register select
        d: in std_logic_vector(4 downto 0); -- input
        qsel: in std_logic_vector(n_sel-1 downto 0); -- output register select
        q: out std_logic_vector(4 downto 0) -- output
        );
end genericRegisterFile;


-- implementation for a generic register file
architecture struct_arch of genericRegisterFile is
    signal enable: std_logic_vector(2**n_sel-1 downto 0);
    signal reg_data: slv_array_5(2**n_sel-1 downto 0);
begin
    regs: for i in 0 to 2**n_sel -1 generate
        reg: entity work.genericRegister(ifelse_arch)
            generic map(bits=>5)
            port map(
                en=>enable(i),
                clk=>clk,
                reset=>rst,
                d=>d,
                q=>reg_data(i)
                );
    end generate regs;
    
    -- use to select which register to read from
    outmux: entity work.genericMux5(proc_arch)
        generic map(sel_bits=>n_sel)
        port map(
            sel=>qsel,
            d_in=>reg_data,
            Y=>q
            );
    
    -- use to select which register to write to
    indec: entity work.genericDecoderWithEnable(ifelse_arch)
        generic map(bits=>n_sel)
        port map(
            en=>en,
            sel=>dsel,
            y=>enable
            );
    
end struct_arch;